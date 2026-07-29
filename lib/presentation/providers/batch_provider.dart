// Batch providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';
import '../../domain/entities/barcode_content.dart';
import '../../domain/entities/batch_item.dart';
import '../../domain/entities/generation_request.dart';
import '../../domain/entities/qr_design.dart';
import '../../domain/usecases/batch_generate_usecase.dart';

class BatchState {
  const BatchState({
    this.items = const [],
    this.isProcessing = false,
    this.progress = 0,
    this.errorKey,
    this.lastExportPath,
  });

  final List<BatchItem> items;
  final bool isProcessing;
  final double progress;
  final String? errorKey;
  final String? lastExportPath;

  int get generatedCount =>
      items.where((i) => i.status == BatchItemStatus.generated).length;
  int get failedCount =>
      items.where((i) => i.status == BatchItemStatus.failed).length;

  BatchState copyWith({
    List<BatchItem>? items,
    bool? isProcessing,
    double? progress,
    String? errorKey,
    String? lastExportPath,
    bool clearError = false,
  }) {
    return BatchState(
      items: items ?? this.items,
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      lastExportPath: lastExportPath ?? this.lastExportPath,
    );
  }
}

class BatchNotifier extends StateNotifier<BatchState> {
  BatchNotifier(this._ref) : super(const BatchState());

  final Ref _ref;

  /// Adds items from pasted text (one per line).
  void addFromText(String text, {BarcodeFormat format = BarcodeFormat.qr}) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    final items = lines.asMap().entries.map(
          (e) => BatchItem(
            id: '${DateTime.now().microsecondsSinceEpoch}_${e.key}',
            input: e.value,
            format: format,
          ),
        );
    state = state.copyWith(items: [...state.items, ...items]);
  }

  Future<void> importCsv(String path) async {
    state = state.copyWith(isProcessing: true);
    final useCase = BatchGenerateUseCase();
    final r = await useCase.fromCsv(path);
    r.fold(
      onLeft: (f) => state = state.copyWith(
        isProcessing: false,
        errorKey: f.message,
      ),
      onRight: (items) => state = state.copyWith(
        isProcessing: false,
        items: [...state.items, ...items],
        clearError: true,
      ),
    );
  }

  Future<void> importExcel(String path) async {
    state = state.copyWith(isProcessing: true);
    final useCase = BatchGenerateUseCase();
    final r = await useCase.fromExcel(path);
    r.fold(
      onLeft: (f) => state = state.copyWith(
        isProcessing: false,
        errorKey: f.message,
      ),
      onRight: (items) => state = state.copyWith(
        isProcessing: false,
        items: [...state.items, ...items],
        clearError: true,
      ),
    );
  }

  Future<void> generateAll(QrDesign design) async {
    if (state.items.isEmpty) return;
    state = state.copyWith(isProcessing: true, progress: 0);

    final useCase = BatchGenerateUseCase();
    final r = await useCase.generateAll(
      state.items,
      requestBuilder: (item) => GenerationRequest(
        content: BarcodeContent(
          type: item.contentType ?? ContentType.plainText,
          raw: item.input,
        ),
        format: item.format,
        design: design,
      ),
    );

    r.fold(
      onLeft: (f) => state = state.copyWith(
        isProcessing: false,
        errorKey: f.message,
      ),
      onRight: (items) => state = state.copyWith(
        isProcessing: false,
        progress: 1.0,
        items: items,
        clearError: true,
      ),
    );
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  void updateFormat(String id, BarcodeFormat format) {
    state = state.copyWith(
      items: state.items
          .map((item) => item.id == id ? item.copyWith(format: format) : item)
          .toList(growable: false),
    );
  }

  void clear() => state = const BatchState();

  void setLastExportPath(String path) =>
      state = state.copyWith(lastExportPath: path);
}

final batchStateProvider = StateNotifierProvider<BatchNotifier, BatchState>(
    (ref) => BatchNotifier(ref));
