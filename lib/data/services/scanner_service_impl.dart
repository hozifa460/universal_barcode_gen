// ScannerServiceImpl: full camera scanner implementation using mobile_scanner.
//
// Provides:
//   - Live camera stream → ScanResult stream
//   - Image file detection (single + multi-code)
//   - Flashlight toggle
//   - Continuous mode support
//   - All 1D + 2D barcode formats supported by mobile_scanner

import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/constants/barcode_format.dart' as app;
import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../core/validators/content_detector.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/services/scanner_service.dart';

class ScannerServiceImpl implements ScannerService {
  ScannerServiceImpl._();
  static final ScannerServiceImpl instance = ScannerServiceImpl._();

  final StreamController<ScanResult> _controller =
      StreamController<ScanResult>.broadcast();
  MobileScannerController? _controllerInstance;
  bool _initialized = false;

  /// Returns the underlying MobileScannerController (used by the UI widget).
  MobileScannerController? get mobileScannerController => _controllerInstance;

  @override
  Future<Result<bool>> initialize() async {
    try {
      if (_initialized) return Either.right(true);
      _controllerInstance = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: _allFormats(),
      );
      _initialized = true;
      return Either.right(true);
    } catch (e, s) {
      AppLogger.instance.error('Scanner.initialize', e, s);
      return Either.left(
        const ScannerFailure(
          message: 'error_camera_permission',
          code: 'init_failed',
        ),
      );
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _controllerInstance?.dispose();
    } catch (_) {}
    _controllerInstance = null;
    _initialized = false;
    await _controller.close();
  }

  @override
  Future<Result<List<ScanResult>>> detectFromFile(String path) async {
    try {
      final controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: _allFormats(),
      );
      try {
        // mobile_scanner 5.x returns the detected capture for a still image.
        final capture = await controller.analyzeImage(path);
        if (capture == null) return Either.right(const []);

        final scannedAt = DateTime.now();
        return Either.right(
          capture.barcodes
              .where((barcode) => barcode.rawValue?.isNotEmpty == true)
              .map((barcode) => _toScanResult(barcode, scannedAt))
              .toList(growable: false),
        );
      } finally {
        await controller.dispose();
      }
    } catch (e, s) {
      AppLogger.instance.error('detectFromFile', e, s);
      return Either.left(
        const ScannerFailure(
          message: 'error_unknown',
          code: 'detect_failed',
        ),
      );
    }
  }

  @override
  Stream<ScanResult> get scanStream => _controller.stream;

  /// Pushes a detected code into the stream. Called by the UI when
  /// MobileScanner's onDetect fires.
  void emitDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue?.isNotEmpty == true) {
        _controller.add(_toScanResult(barcode, DateTime.now()));
      }
    }
  }

  ScanResult _toScanResult(Barcode barcode, DateTime scannedAt) {
    final raw = barcode.rawValue!;
    return ScanResult(
      id: '${scannedAt.microsecondsSinceEpoch}_${barcode.format.name}',
      rawValue: raw,
      format: _mapFormat(barcode.format),
      detectedType: ContentDetector.detect(raw),
      scannedAt: scannedAt,
    );
  }

  /// Toggles flashlight if controller is available.
  Future<void> toggleFlash() async {
    try {
      await _controllerInstance?.toggleTorch();
    } catch (e, s) {
      AppLogger.instance.error('toggleFlash', e, s);
    }
  }

  /// Switches front/back camera.
  Future<void> switchCamera() async {
    try {
      await _controllerInstance?.switchCamera();
    } catch (e, s) {
      AppLogger.instance.error('switchCamera', e, s);
    }
  }

  /// Starts the camera.
  Future<void> start() async {
    try {
      await _controllerInstance?.start();
    } catch (e, s) {
      AppLogger.instance.error('start', e, s);
    }
  }

  /// Stops the camera.
  Future<void> stop() async {
    try {
      await _controllerInstance?.stop();
    } catch (e, s) {
      AppLogger.instance.error('stop', e, s);
    }
  }

  List<BarcodeFormat> _allFormats() {
    // Enable every supported format.
    return const [
      BarcodeFormat.aztec,
      BarcodeFormat.codabar,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.code128,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.itf,
      BarcodeFormat.pdf417,
      BarcodeFormat.qrCode,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ];
  }

  app.BarcodeFormat _mapFormat(BarcodeFormat fmt) {
    switch (fmt) {
      case BarcodeFormat.aztec:
        return app.BarcodeFormat.aztec;
      case BarcodeFormat.codabar:
        return app.BarcodeFormat.codabar;
      case BarcodeFormat.code39:
        return app.BarcodeFormat.code39;
      case BarcodeFormat.code93:
        return app.BarcodeFormat.code93;
      case BarcodeFormat.code128:
        return app.BarcodeFormat.code128;
      case BarcodeFormat.dataMatrix:
        return app.BarcodeFormat.dataMatrix;
      case BarcodeFormat.ean8:
        return app.BarcodeFormat.ean8;
      case BarcodeFormat.ean13:
        return app.BarcodeFormat.ean13;
      case BarcodeFormat.itf:
        return app.BarcodeFormat.itf;
      case BarcodeFormat.pdf417:
        return app.BarcodeFormat.pdf417;
      case BarcodeFormat.qrCode:
        return app.BarcodeFormat.qr;
      case BarcodeFormat.upcA:
        return app.BarcodeFormat.upcA;
      case BarcodeFormat.upcE:
        return app.BarcodeFormat.upcE;
      default:
        return app.BarcodeFormat.qr;
    }
  }
}
