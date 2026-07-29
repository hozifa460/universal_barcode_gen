// ExportServiceImpl: PNG / SVG / PDF / high-res export.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/errors/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/service_locator.dart';
import '../../data/datasources/file_data_source.dart';
import '../../domain/services/scanner_service.dart';

class ExportServiceImpl implements ExportService {
  ExportServiceImpl._();
  static final ExportServiceImpl instance = ExportServiceImpl._();

  @override
  Future<Either<Failure, String>> exportPng({
    required List<int> bytes,
    String? filename,
  }) async {
    try {
      final name = filename ??
          FileDataSource.instance.generateFilename(
            prefix: 'barcode',
            extension: 'png',
          );

      // Save temporarily first
      final res = await FileDataSource.instance
          .saveBytes(filename: name, bytes: bytes, subdir: 'exports');

      return await res.fold(
        onLeft: (f) => Either.left(f),
        onRight: (String path) async {
          if (_supportsGalleryExport) {
            final hasAccess = await Gal.hasAccess(toAlbum: true);
            if (!hasAccess) {
              await Gal.requestAccess(toAlbum: true);
            }
            await Gal.putImage(path);
          }
          return Either.right(path);
        },
      );
    } catch (e, s) {
      AppLogger.instance.error('exportPng', e, s);
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, String>> exportSvg({
    required String svg,
    String? filename,
  }) async {
    final name = filename ??
        FileDataSource.instance.generateFilename(
          prefix: 'barcode',
          extension: 'svg',
        );
    return FileDataSource.instance
        .saveString(filename: name, content: svg, subdir: 'exports');
  }

  @override
  Future<Either<Failure, String>> exportPdf({
    required List<List<int>> images,
    List<String>? labels,
    String? filename,
    PdfPaperSize paperSize = PdfPaperSize.a4,
  }) async {
    try {
      if (images.isEmpty) {
        return Either.left(
          const ExportFailure(
            message: 'error_export_failed',
            code: 'no_images',
          ),
        );
      }
      final pdf = pw.Document();
      final pageSize = PdfPageFormat(
        paperSize.widthPt.toDouble(),
        paperSize.heightPt.toDouble(),
        marginLeft: 24,
        marginRight: 24,
        marginTop: 24,
        marginBottom: 24,
      );

      const perPage = 6;
      for (var i = 0; i < images.length; i += perPage) {
        final chunk = images.sublist(
          i,
          (i + perPage).clamp(0, images.length),
        );
        final labelChunk =
            labels?.sublist(i, (i + perPage).clamp(0, labels.length));

        pdf.addPage(
          pw.MultiPage(
            pageFormat: pageSize,
            header: (ctx) => pw.Text(
              'Barcode Export',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            build: (ctx) {
              final widgets = <pw.Widget>[];
              for (var j = 0; j < chunk.length; j++) {
                final img = pw.MemoryImage(Uint8List.fromList(chunk[j]));
                widgets.add(
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Image(img, height: 140),
                        if (labelChunk != null && j < labelChunk.length)
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(top: 4),
                            child: pw.Text(
                              labelChunk[j],
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return [
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: widgets,
                ),
              ];
            },
          ),
        );
      }

      final bytes = await pdf.save();
      final name = filename ??
          FileDataSource.instance.generateFilename(
            prefix: 'barcodes_export',
            extension: 'pdf',
          );
      return FileDataSource.instance
          .saveBytes(filename: name, bytes: bytes, subdir: 'exports');
    } catch (e, s) {
      AppLogger.instance.error('exportPdf', e, s);
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  @override
  Future<Either<Failure, String>> exportHighRes({
    required GenerationRequest request,
    int size = 8192,
  }) async {
    try {
      final newReq = GenerationRequest(
        content: request.content,
        format: request.format,
        design: request.design.copyWith(size: size),
      );
      final gen =
          await ServiceLocator.instance.generationService.generate(newReq);
      return await gen.fold(
        onLeft: (Failure f) => Either.left(f),
        onRight: (GenerationResult r) async {
          final name = FileDataSource.instance.generateFilename(
            prefix: 'barcode_8k',
            extension: 'png',
          );
          final res = await FileDataSource.instance.saveBytes(
              filename: name, bytes: r.imageBytes, subdir: 'exports');

          return await res.fold(
            onLeft: (f) => Either.left(f),
            onRight: (String path) async {
              if (_supportsGalleryExport) {
                final hasAccess = await Gal.hasAccess(toAlbum: true);
                if (!hasAccess) {
                  await Gal.requestAccess(toAlbum: true);
                }
                await Gal.putImage(path);
              }
              return Either.right(path);
            },
          );
        },
      );
    } catch (e, s) {
      AppLogger.instance.error('exportHighRes', e, s);
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  bool get _supportsGalleryExport =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
