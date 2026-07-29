// GenerationServiceImpl: produces PNG bytes + SVG strings from a GenerationRequest.
//
// Uses:
//   - `pretty_qr_code` for stylable QR codes (module shape, eye shape, gradient, logo)
//   - `barcode_widget` / `barcode` for all 1D barcode formats
//   - Flutter's RenderRepaintBoundary → toImage for rasterization

import 'dart:io' show File;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/qr_style.dart';
import '../../core/errors/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/generation_request.dart';
import '../../domain/entities/qr_design.dart';
import '../../domain/services/generation_service.dart';
import 'package:qr/qr.dart';

class GenerationServiceImpl implements GenerationService {
  GenerationServiceImpl._();
  static final GenerationServiceImpl instance = GenerationServiceImpl._();

  @override
  Future<Result<GenerationResult>> generate(GenerationRequest request) async {
    try {
      if (request.format == BarcodeFormat.qr) {
        return _generateQr(request);
      }
      return _renderBarcodeViaWidget(request);
    } catch (e, s) {
      AppLogger.instance.error('GenerationService.generate', e, s);
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  @override
  Future<Result<String>> generateSvg(GenerationRequest request) async {
    try {
      if (request.format == BarcodeFormat.qr) {
        return _generateQrSvg(request);
      }
      return _generate1DSvg(request);
    } catch (e, s) {
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  // ---------------------------------------------------------------------------
  // QR
  // ---------------------------------------------------------------------------

  Future<Result<GenerationResult>> _generateQr(
      GenerationRequest request) async {
    final design = request.design;
    final ecLevel = _prettyQrEc(design.errorCorrection);
    final qrCode = QrCode.fromData(
      data: request.content.encoded,
      errorCorrectLevel: ecLevel,
    );
    final qrImage = QrImage(qrCode);
    final size = design.size.toDouble();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Background.
    if (!design.transparentBackground) {
      canvas.drawRect(
        Offset.zero & Size(size, size),
        Paint()..color = Color(design.backgroundColor),
      );
    }

    // QR readers require a quiet zone around the symbol. Keep it in module
    // units so the margin stays valid at every export size.
    final moduleSize = size / (qrImage.moduleCount + design.margin * 2);
    final quietZone = design.margin * moduleSize;
    final Paint modulePaint;
    if (design.useGradient) {
      modulePaint = Paint()
        ..shader = _buildGradient(design, size)
            .createShader(Rect.fromLTWH(0, 0, size, size));
    } else {
      modulePaint = Paint()..color = Color(design.foregroundColor);
    }

    for (var y = 0; y < qrImage.moduleCount; y++) {
      for (var x = 0; x < qrImage.moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          // Skip modules covered by finder eyes (will draw eyes separately).
          if (_isEyeArea(qrImage.moduleCount, x, y)) continue;
          final rect = Rect.fromLTWH(
            quietZone + x * moduleSize,
            quietZone + y * moduleSize,
            moduleSize,
            moduleSize,
          );
          _drawModule(canvas, rect, modulePaint, design.moduleShape);
        }
      }
    }

    // Draw the three finder eyes.
    canvas.save();
    canvas.translate(quietZone, quietZone);
    _drawEyes(canvas, qrImage.moduleCount, moduleSize, design);
    canvas.restore();

    // Draw logo if provided.
    if (design.logoPath != null) {
      await _drawLogo(canvas, size, design);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return Either.left(
        const GenerationFailure(
          message: 'error_generation_failed',
          code: 'png_encode_failed',
        ),
      );
    }

    return Either.right(
      GenerationResult(
        request: request,
        imageBytes: byteData.buffer.asUint8List(),
        width: size.toInt(),
        height: size.toInt(),
        isValid: true,
      ),
    );
  }

  bool _isEyeArea(int moduleCount, int x, int y) {
    // Three 7x7 finder eye regions + 1 module quiet zone = 8x8.
    if (x < 8 && y < 8) return true;
    if (x >= moduleCount - 8 && y < 8) return true;
    if (x < 8 && y >= moduleCount - 8) return true;
    return false;
  }

  void _drawEyes(
    Canvas canvas,
    int moduleCount,
    double moduleSize,
    QrDesign design,
  ) {
    final color = Color(design.foregroundColor);
    final positions = [
      const Offset(0, 0),
      Offset((moduleCount - 7) * moduleSize, 0),
      Offset(0, (moduleCount - 7) * moduleSize),
    ];
    for (final pos in positions) {
      final outer = Rect.fromLTWH(
        pos.dx,
        pos.dy,
        7 * moduleSize,
        7 * moduleSize,
      );
      final inner = Rect.fromLTWH(
        pos.dx + moduleSize,
        pos.dy + moduleSize,
        5 * moduleSize,
        5 * moduleSize,
      );
      final pupil = Rect.fromLTWH(
        pos.dx + 2 * moduleSize,
        pos.dy + 2 * moduleSize,
        3 * moduleSize,
        3 * moduleSize,
      );

      // Outer ring.
      final outerPaint = Paint()..color = color;
      switch (design.eyeShape) {
        case EyeShape.square:
          canvas.drawRect(outer, outerPaint);
          canvas.drawRect(
            inner,
            Paint()
              ..color = Color(
                design.transparentBackground
                    ? 0x00000000
                    : design.backgroundColor,
              ),
          );
          canvas.drawRect(pupil, outerPaint);
        case EyeShape.rounded:
          canvas.drawRRect(
            RRect.fromRectAndRadius(outer, Radius.circular(moduleSize * 1.5)),
            outerPaint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              inner,
              Radius.circular(moduleSize),
            ),
            Paint()
              ..color = Color(
                design.transparentBackground
                    ? 0x00000000
                    : design.backgroundColor,
              ),
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(pupil, Radius.circular(moduleSize)),
            outerPaint,
          );
        case EyeShape.circular:
          canvas.drawCircle(outer.center, outer.width / 2, outerPaint);
          canvas.drawCircle(
            inner.center,
            inner.width / 2,
            Paint()
              ..color = Color(
                design.transparentBackground
                    ? 0x00000000
                    : design.backgroundColor,
              ),
          );
          canvas.drawCircle(pupil.center, pupil.width / 2, outerPaint);
        case EyeShape.leaf:
          final path = Path()
            ..moveTo(outer.left, outer.top + moduleSize)
            ..lineTo(outer.topLeft.dx + moduleSize, outer.top)
            ..lineTo(outer.right, outer.top)
            ..lineTo(outer.right, outer.bottom)
            ..lineTo(outer.left, outer.bottom)
            ..close();
          canvas.drawPath(path, outerPaint);
          canvas.drawRect(
            inner,
            Paint()
              ..color = Color(
                design.transparentBackground
                    ? 0x00000000
                    : design.backgroundColor,
              ),
          );
          canvas.drawRect(pupil, outerPaint);
        case EyeShape.bars:
          for (var i = 0; i < 7; i += 2) {
            canvas.drawRect(
              Rect.fromLTWH(
                outer.left + i * moduleSize,
                outer.top,
                moduleSize,
                outer.height,
              ),
              outerPaint,
            );
          }
          canvas.drawRect(
            inner,
            Paint()
              ..color = Color(
                design.transparentBackground
                    ? 0x00000000
                    : design.backgroundColor,
              ),
          );
          canvas.drawRect(pupil, outerPaint);
      }
    }
  }

  Future<void> _drawLogo(Canvas canvas, double size, QrDesign design) async {
    try {
      final file = File(design.logoPath!);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final logoSize = size * design.logoSizeRatio;
      final offset = Offset(
        (size - logoSize) / 2,
        (size - logoSize) / 2,
      );

      // White background circle behind logo for readability.
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(size / 2, size / 2),
        logoSize / 2 + 4,
        bgPaint,
      );

      paintImage(
        canvas: canvas,
        rect: offset & Size(logoSize, logoSize),
        image: image,
        fit: BoxFit.contain,
      );
    } catch (e, s) {
      AppLogger.instance.error('drawLogo', e, s);
    }
  }

  Gradient _buildGradient(QrDesign design, double size) {
    final colors = [Color(design.gradientStart), Color(design.gradientEnd)];
    switch (design.gradientDirection) {
      case GradientDirection.horizontal:
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        );
      case GradientDirection.vertical:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        );
      case GradientDirection.diagonal:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        );
      case GradientDirection.radial:
        return RadialGradient(center: Alignment.center, colors: colors);
      case GradientDirection.sweep:
        return SweepGradient(center: Alignment.center, colors: colors);
    }
  }

  void _drawModule(Canvas canvas, Rect rect, Paint paint, ModuleShape shape) {
    switch (shape) {
      case ModuleShape.square:
        canvas.drawRect(rect, paint);
      case ModuleShape.rounded:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.width * 0.25)),
          paint,
        );
      case ModuleShape.circular:
        canvas.drawCircle(rect.center, rect.width / 2, paint);
      case ModuleShape.hexagon:
        canvas.drawPath(_hexagonPath(rect), paint);
      case ModuleShape.dots:
        canvas.drawCircle(rect.center, rect.width * 0.4, paint);
    }
  }

  Path _hexagonPath(Rect rect) {
    final path = Path();
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final r = rect.width / 2;
    for (var i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  int _prettyQrEc(ErrorCorrectionLevel level) {
    switch (level) {
      case ErrorCorrectionLevel.low:
        return QrErrorCorrectLevel.L;
      case ErrorCorrectionLevel.medium:
        return QrErrorCorrectLevel.M;
      case ErrorCorrectionLevel.quartile:
        return QrErrorCorrectLevel.Q;
      case ErrorCorrectionLevel.high:
        return QrErrorCorrectLevel.H;
    }
  }

  // ---------------------------------------------------------------------------
  // 1D + 2D barcodes (non-QR)
  // ---------------------------------------------------------------------------

  Future<Result<GenerationResult>> _renderBarcodeViaWidget(
    GenerationRequest request,
  ) async {
    final design = request.design;
    // Linear barcodes need substantially more horizontal space than height.
    // A square canvas makes thin bars hard to resolve after sharing or printing.
    final size = request.format.is1D
        ? Size(design.size.toDouble(),
            math.max(180, design.size * 0.38).toDouble())
        : Size(design.size.toDouble(), design.size.toDouble());

    final widget = BarcodeWidget(
      barcode: _barcodeFromFormat(request.format),
      data: request.content.encoded,
      color: Color(design.foregroundColor),
      backgroundColor:
          design.transparentBackground ? null : Color(design.backgroundColor),
      width: size.width,
      height: size.height,
      margin: EdgeInsets.all(design.margin.toDouble()),
      errorBuilder: (context, error) => Center(child: Text(error.toString())),
    );

    final pngBytes = await _renderWidgetToPng(widget, size);
    if (pngBytes == null) {
      return Either.left(
        const GenerationFailure(
          message: 'error_generation_failed',
          code: 'render_failed',
        ),
      );
    }
    return Either.right(
      GenerationResult(
        request: request,
        imageBytes: pngBytes,
        width: size.width.toInt(),
        height: size.height.toInt(),
        isValid: true,
      ),
    );
  }

  Future<List<int>?> _renderWidgetToPng(Widget widget, Size size) async {
    // Yield to the event loop so UI can breathe before a heavy sync render.
    await Future.delayed(const Duration(milliseconds: 10));

    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();
    final RenderView renderView = RenderView(
      view: WidgetsBinding.instance.platformDispatcher.views.first,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        physicalConstraints: BoxConstraints(
          maxWidth: size.width,
          maxHeight: size.height,
        ),
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Barcode _barcodeFromFormat(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qr:
        return Barcode.qrCode();
      case BarcodeFormat.pdf417:
        return Barcode.pdf417();
      case BarcodeFormat.dataMatrix:
        return Barcode.dataMatrix();
      case BarcodeFormat.aztec:
        return Barcode.aztec();
      case BarcodeFormat.code128:
        return Barcode.code128();
      case BarcodeFormat.code39:
        return Barcode.code39();
      case BarcodeFormat.code93:
        return Barcode.code93();
      case BarcodeFormat.codabar:
        return Barcode.codabar();
      case BarcodeFormat.itf:
        return Barcode.itf();
      case BarcodeFormat.ean13:
        return Barcode.ean13();
      case BarcodeFormat.ean8:
        return Barcode.ean8();
      case BarcodeFormat.upcA:
        return Barcode.upcA();
      case BarcodeFormat.upcE:
        return Barcode.upcE();
      case BarcodeFormat.isbn:
        return Barcode.isbn();
      case BarcodeFormat.gs1:
        return Barcode.gs128();
      case BarcodeFormat.telepen:
        return Barcode.telepen();
      case BarcodeFormat.rm4scc:
        return Barcode.rm4scc();
    }
  }

  // ---------------------------------------------------------------------------
  // SVG
  // ---------------------------------------------------------------------------

  Future<Result<String>> _generateQrSvg(GenerationRequest request) async {
    final design = request.design;
    final ecLevel = _prettyQrEc(design.errorCorrection);
    final qrCode = QrCode.fromData(
      data: request.content.encoded,
      errorCorrectLevel: ecLevel,
    );
    final moduleCount = qrCode.moduleCount;
    const moduleSize = 10;
    final total = moduleCount * moduleSize + design.margin * 2 * moduleSize;

    final fgHex =
        design.foregroundColor.toRadixString(16).padLeft(8, '0').substring(2);
    final bgHex =
        design.backgroundColor.toRadixString(16).padLeft(8, '0').substring(2);

    final buf = StringBuffer(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$total" height="$total" viewBox="0 0 $total $total">',
    );
    if (!design.transparentBackground) {
      buf.write('<rect width="$total" height="$total" fill="#$bgHex"/>');
    }
    final qrImage = QrImage(qrCode);
    for (var y = 0; y < moduleCount; y++) {
      for (var x = 0; x < moduleCount; x++) {
        if (qrImage.isDark(y, x)) {
          final px = (x + design.margin) * moduleSize;
          final py = (y + design.margin) * moduleSize;
          buf.write(
            '<rect x="$px" y="$py" width="$moduleSize" height="$moduleSize" fill="#$fgHex"/>',
          );
        }
      }
    }
    buf.write('</svg>');
    return Either.right(buf.toString());
  }

  Future<Either<Failure, String>> _generate1DSvg(
      GenerationRequest request) async {
    final bc = _barcodeFromFormat(request.format);
    final fgHex = request.design.foregroundColor
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2);
    final width = request.design.size.toDouble();
    final height = request.format.is1D
        ? math.max(180, request.design.size * 0.38).toDouble()
        : width;
    final svg = bc.toSvg(
      request.content.encoded,
      width: width,
      height: height,
      color: int.parse(fgHex, radix: 16),
    );
    return Either.right(svg);
  }
}
