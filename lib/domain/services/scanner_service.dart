// ScannerService contract: scans camera stream + image files.
// Implemented in Batch 7.

import '../../core/errors/either.dart';
import '../entities/generation_request.dart';
import '../entities/scan_result.dart';
export '../entities/generation_request.dart' show GenerationRequest, GenerationResult;

abstract class ScannerService {
  /// Initializes the camera. Returns true if successful.
  Future<Result<bool>> initialize();

  /// Releases camera resources.
  Future<void> dispose();

  /// Detects codes in a single image file at [path].
  /// Returns one or more raw values.
  Future<Result<List<ScanResult>>> detectFromFile(String path);

  /// Returns the stream of scanned codes from the live camera.
  Stream<ScanResult> get scanStream;
}

abstract class ExportService {
  /// Saves a PNG to disk, returns path.
  Future<Result<String>> exportPng({
    required List<int> bytes,
    String? filename,
  });

  /// Saves an SVG file to disk, returns path.
  Future<Result<String>> exportSvg({
    required String svg,
    String? filename,
  });

  /// Builds and saves a PDF containing one or more code images.
  Future<Result<String>> exportPdf({
    required List<List<int>> images,
    List<String>? labels,
    String? filename,
    PdfPaperSize paperSize = PdfPaperSize.a4,
  });

  /// Saves a high-resolution (up to 8K) PNG.
  Future<Result<String>> exportHighRes({
    required GenerationRequest request,
    int size = 8192,
  });
}

abstract class BatchService {
  /// Generates multiple codes in one go.
  Future<Result<List<GenerationResult>>> generateAll(
    List<GenerationRequest> requests,
  );

  /// Reads a CSV file and returns rows.
  Future<Result<List<List<String>>>> readCsv(String path);

  /// Reads an Excel file and returns rows.
  Future<Result<List<List<String>>>> readExcel(String path);
}

abstract class PrintService {
  Future<Result<void>> printImage(List<int> pngBytes, {String? label});
  Future<Result<void>> printPdf(List<int> pdfBytes);
}


enum PdfPaperSize {
  a4('A4', 595, 842),
  a5('A5', 420, 595),
  letter('Letter', 612, 792),
  legal('Legal', 612, 1008),
  label40x30('Label 40×30mm', 113, 85),
  label50x30('Label 50×30mm', 142, 85),
  label70x50('Label 70×50mm', 198, 142);

  final String label;
  final int widthPt;
  final int heightPt;
  const PdfPaperSize(this.label, this.widthPt, this.heightPt);
}
