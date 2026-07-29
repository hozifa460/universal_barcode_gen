// Converter providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';
import '../../core/validators/content_detector.dart';
import '../../domain/entities/barcode_content.dart';
import '../../domain/entities/generation_request.dart';
import '../../domain/entities/qr_design.dart';
import '../../domain/usecases/universal_converter_usecase.dart';

class ConverterState {
  const ConverterState({
    this.rawInput = '',
    this.detectedType,
    this.recommendedFormat,
    this.compatibleFormats = const [],
    this.results = const [],
    this.isGenerating = false,
    this.errorKey,
  });

  final String rawInput;
  final ContentType? detectedType;
  final BarcodeFormat? recommendedFormat;
  final List<BarcodeFormat> compatibleFormats;
  final List<GenerationResult> results;
  final bool isGenerating;
  final String? errorKey;

  ConverterState copyWith({
    String? rawInput,
    ContentType? detectedType,
    BarcodeFormat? recommendedFormat,
    List<BarcodeFormat>? compatibleFormats,
    List<GenerationResult>? results,
    bool? isGenerating,
    String? errorKey,
    bool clearError = false,
  }) {
    return ConverterState(
      rawInput: rawInput ?? this.rawInput,
      detectedType: detectedType ?? this.detectedType,
      recommendedFormat: recommendedFormat ?? this.recommendedFormat,
      compatibleFormats: compatibleFormats ?? this.compatibleFormats,
      results: results ?? this.results,
      isGenerating: isGenerating ?? this.isGenerating,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }
}

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier(this._useCase) : super(const ConverterState());

  final UniversalConverterUseCase _useCase;

  void setRawInput(String input) {
    if (input.isEmpty) {
      state = const ConverterState();
      return;
    }
    final detected = _useCase.detect(input);
    final content = BarcodeContent(
      type: detected,
      raw: input,
    );
    final compatible = _useCase.compatibleFormats(content);
    final recommended = _useCase.recommendFormat(
      content,
      CodePurpose.general,
    );
    state = ConverterState(
      rawInput: input,
      detectedType: detected,
      compatibleFormats: compatible,
      recommendedFormat: recommended,
    );
  }

  Future<void> generateAll(QrDesign design) async {
    if (state.rawInput.isEmpty) return;
    state = state.copyWith(isGenerating: true);
    final content = BarcodeContent(
      type: state.detectedType ?? ContentType.plainText,
      raw: state.rawInput,
    );
    final r = await _useCase.generateAll(content: content, design: design);
    r.fold(
      onLeft: (f) => state = state.copyWith(
        isGenerating: false,
        errorKey: f.message,
      ),
      onRight: (results) => state = state.copyWith(
        isGenerating: false,
        results: results,
        clearError: true,
      ),
    );
  }
}

final converterStateProvider =
    StateNotifierProvider<ConverterNotifier, ConverterState>(
        (ref) => ConverterNotifier(UniversalConverterUseCase()),);

final contentDetectorProvider =
    Provider<ContentType Function(String)>((ref) {
  return ContentDetector.detect;
});
