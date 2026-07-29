import 'dart:typed_data';
// PrintServiceImpl: OS print dialog integration via the `printing` package.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/errors/either.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/logger.dart';

class PrintServiceImpl {
  PrintServiceImpl._();
  static final PrintServiceImpl instance = PrintServiceImpl._();

  Future<Either<Failure, void>> printImage(List<int> pngBytes, {String? label}) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Image(pw.MemoryImage(Uint8List.fromList(pngBytes)), height: 300),
                  if (label != null)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 12),
                      child: pw.Text(label),
                    ),
                ],
              ),
            );
          },
        ),
      );
      final bytes = await pdf.save();
      await Printing.layoutPdf(onLayout: (format) => bytes);
      return Either.right(null);
    } catch (e, s) {
      AppLogger.instance.error('printImage', e, s);
      return Either.left(ExceptionMapper.map(e, s));
    }
  }

  Future<Either<Failure, void>> printPdf(List<int> pdfBytes) async {
    try {
      await Printing.layoutPdf(onLayout: (format) => Uint8List.fromList(pdfBytes));
      return Either.right(null);
    } catch (e, s) {
      AppLogger.instance.error('printPdf', e, s);
      return Either.left(ExceptionMapper.map(e, s));
    }
  }
}
