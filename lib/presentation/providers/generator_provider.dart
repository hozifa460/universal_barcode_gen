// GeneratorNotifier: view-model for the generator screen.
// Holds the current content type, raw input, design, format — exposes
// live preview generation + save-to-history.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';
import '../../core/validators/content_detector.dart';
import '../../core/validators/input_validator.dart';
import '../../domain/entities/barcode_content.dart';
import '../../domain/entities/design_preset.dart';
import '../../domain/entities/generation_request.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/entities/qr_design.dart';
import '../../domain/usecases/generate_code_usecase.dart';
import 'history_provider.dart';
import 'settings_provider.dart';

class GeneratorState {
  const GeneratorState({
    this.contentType = ContentType.plainText,
    this.rawInput = '',
    this.format = BarcodeFormat.qr,
    this.design = const QrDesign(),
    this.lastResult,
    this.isGenerating = false,
    this.errorKey,
    this.lastSavedEntry,
    this.isDuplicate = false,
    this.detectedType,
  });

  final ContentType contentType;
  final String rawInput;
  final BarcodeFormat format;
  final QrDesign design;
  final GenerationResult? lastResult;
  final bool isGenerating;
  final String? errorKey;
  final HistoryEntry? lastSavedEntry;
  final bool isDuplicate;
  final ContentType? detectedType;

  /// Validation status — null = unknown, true = valid, false = invalid.
  bool? get isValid {
    if (rawInput.isEmpty) return null;
    return InputValidator.validate(contentType, rawInput) == null;
  }

  BarcodeContent get content => BarcodeContent(
        type: contentType,
        raw: rawInput,
      );

  GenerationRequest get request => GenerationRequest(
        content: content,
        format: format,
        design: design,
      );

  GeneratorState copyWith({
    ContentType? contentType,
    String? rawInput,
    BarcodeFormat? format,
    QrDesign? design,
    GenerationResult? lastResult,
    bool? isGenerating,
    String? errorKey,
    HistoryEntry? lastSavedEntry,
    bool? isDuplicate,
    ContentType? detectedType,
    bool clearError = false,
    bool clearSaved = false,
  }) {
    return GeneratorState(
      contentType: contentType ?? this.contentType,
      rawInput: rawInput ?? this.rawInput,
      format: format ?? this.format,
      design: design ?? this.design,
      lastResult: lastResult ?? this.lastResult,
      isGenerating: isGenerating ?? this.isGenerating,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
      lastSavedEntry: clearSaved ? null : (lastSavedEntry ?? this.lastSavedEntry),
      isDuplicate: isDuplicate ?? this.isDuplicate,
      detectedType: detectedType ?? this.detectedType,
    );
  }
}

class GeneratorNotifier extends StateNotifier<GeneratorState> {
  GeneratorNotifier(this._ref, this._generateUseCase)
      : super(const GeneratorState()) {
    _initDefaults();
  }

  final Ref _ref;
  final GenerateCodeUseCase _generateUseCase;

  void _initDefaults() {
    // Load default EC level from settings.
    final settingsVal = _ref.read(settingsProvider);
    settingsVal.whenData((settings) {
      state = state.copyWith(
        design: state.design.copyWith(
          errorCorrection: settings.defaultErrorCorrection,
        ),
      );
    });
  }

  void setContentType(ContentType type) {
    state = state.copyWith(contentType: type, clearError: true);
    _maybeAutoGenerate();
  }

  void setFormat(BarcodeFormat format) {
    state = state.copyWith(format: format, clearError: true);
    _maybeAutoGenerate();
  }

  /// Updates raw input + runs auto-detection.
  void setRawInput(String input) {
    final detected = input.isEmpty
        ? null
        : ContentDetector.detect(input);
    // Auto-switch content type to detected if user hasn't manually picked.
    final newType = detected != null && detected != ContentType.plainText
        ? detected
        : state.contentType;
    state = state.copyWith(
      rawInput: input,
      contentType: newType,
      detectedType: detected,
      clearError: true,
    );
    _maybeAutoGenerate();
  }

  void setDesign(QrDesign design) {
    state = state.copyWith(design: design);
    _maybeAutoGenerate();
  }

  void applyPreset(DesignPreset preset) {
    state = state.copyWith(design: preset.design);
    _maybeAutoGenerate();
  }

  void clearInput() {
    state = GeneratorState(
      design: state.design,
      format: state.format,
    );
  }

  Timer? _debounce;

  /// Live preview: only generates if input is valid.
  void _maybeAutoGenerate() {
    if (state.rawInput.isEmpty) {
      state = state.copyWith(clearSaved: true);
      return;
    }
    final err = InputValidator.validate(state.contentType, state.rawInput);
    if (err != null) {
      state = state.copyWith(errorKey: err);
      return;
    }
    
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      generate();
    });
  }

  /// Force-generate regardless of validation (used by "Generate" button).
  Future<void> generate() async {
    state = state.copyWith(isGenerating: true, clearError: true);
    final res = await _generateUseCase.call(state.request);
    res.fold(
      onLeft: (f) => state = state.copyWith(
        isGenerating: false,
        errorKey: f.message,
      ),
      onRight: (r) => state = state.copyWith(
        isGenerating: false,
        lastResult: r,
        clearSaved: true,
      ),
    );
  }

  /// Save to history. Returns true on success.
  Future<bool> save() async {
    final res = await _generateUseCase.generateAndSave(state.request);
    return res.fold(
      onLeft: (f) {
        state = state.copyWith(errorKey: f.message);
        return false;
      },
      onRight: (entry) {
        // Refresh history list.
        _ref.invalidate(historyListProvider);
        state = state.copyWith(
          lastSavedEntry: entry,
          isDuplicate: entry.id.isEmpty,
        );
        return true;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final generatorStateProvider =
    StateNotifierProvider<GeneratorNotifier, GeneratorState>((ref) {
  return GeneratorNotifier(ref, GenerateCodeUseCase());
});
