import '../../core/constants/barcode_format.dart';
import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/service_locator.dart';
import '../../core/validators/content_detector.dart';
import '../entities/batch_item.dart';
import '../entities/generation_request.dart';

class BatchGenerateUseCase {
  Future<Result<List<BatchItem>>> fromCsv(String path) async {
    final rows = await ServiceLocator.instance.batchService.readCsv(path);
    return rows.map(_itemsFromRows);
  }

  Future<Result<List<BatchItem>>> fromExcel(String path) async {
    final rows = await ServiceLocator.instance.batchService.readExcel(path);
    return rows.map(_itemsFromRows);
  }

  Future<Result<List<BatchItem>>> generateAll(
    List<BatchItem> items, {
    required GenerationRequest Function(BatchItem) requestBuilder,
  }) async {
    try {
      final updated = <BatchItem>[];
      for (final item in items) {
        final result = await ServiceLocator.instance.generationService
            .generate(requestBuilder(item));
        updated.add(result.fold(
          onLeft: (failure) => item.copyWith(
            status: BatchItemStatus.failed,
            error: failure.message,
          ),
          onRight: (_) => item.copyWith(
            status: BatchItemStatus.generated,
            clearError: true,
          ),
        ));
      }
      return Either.right(updated);
    } catch (error) {
      return Either.left(UnknownFailure(message: error.toString()));
    }
  }

  List<BatchItem> _itemsFromRows(List<List<String>> rows) {
    return rows
        .where((row) => row.isNotEmpty && row.first.trim().isNotEmpty)
        .map((row) {
      final input = row.first.trim();
      final label =
          row.length > 1 && row[1].trim().isNotEmpty ? row[1].trim() : null;
      final format =
          row.length > 2 ? _formatFromCell(row[2]) : BarcodeFormat.qr;
      return BatchItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_${input.hashCode}',
        input: input,
        label: label,
        format: format,
        contentType: ContentDetector.detect(input),
      );
    }).toList(growable: false);
  }

  BarcodeFormat _formatFromCell(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('-', '');
    return BarcodeFormat.values.firstWhere(
      (format) =>
          format.name.toLowerCase() == normalized ||
          format.codeKey.toLowerCase() == normalized,
      orElse: () => BarcodeFormat.qr,
    );
  }
}
