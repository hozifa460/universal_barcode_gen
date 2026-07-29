// Scan providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/scan_usecases.dart';
import 'settings_provider.dart';

final scanHistoryProvider =
    FutureProvider<List<ScanResult>>((ref) async {
  final r = await GetScanHistoryUseCase().call();
  return r.getOrThrow();
});

class ScannerState {
  const ScannerState({
    this.isFlashOn = false,
    this.isContinuous = false,
    this.isScanning = false,
    this.lastResult,
    this.errorKey,
  });
  final bool isFlashOn;
  final bool isContinuous;
  final bool isScanning;
  final ScanResult? lastResult;
  final String? errorKey;

  ScannerState copyWith({
    bool? isFlashOn,
    bool? isContinuous,
    bool? isScanning,
    ScanResult? lastResult,
    String? errorKey,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return ScannerState(
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isContinuous: isContinuous ?? this.isContinuous,
      isScanning: isScanning ?? this.isScanning,
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._ref) : super(const ScannerState()) {
    _initDefaults();
  }

  final Ref _ref;

  void _initDefaults() {
    final settingsVal = _ref.read(settingsProvider);
    settingsVal.whenData((settings) {
      state = ScannerState(
        isFlashOn: settings.flashlightDefault,
        isContinuous: settings.continuousScan,
      );
    });
  }

  void toggleFlash() =>
      state = state.copyWith(isFlashOn: !state.isFlashOn);
  void toggleContinuous() =>
      state = state.copyWith(isContinuous: !state.isContinuous);
  void setScanning(bool v) => state = state.copyWith(isScanning: v);
  void clearError() => state = state.copyWith(clearError: true);

  Future<void> saveResult(ScanResult result) async {
    final r = await SaveScanResultUseCase().call(result);
    r.fold(
      onLeft: (f) => state = state.copyWith(errorKey: f.message),
      onRight: (res) {
        _ref.invalidate(scanHistoryProvider);
        state = state.copyWith(lastResult: res);
      },
    );
  }

  Future<void> deleteResult(String id) async {
    await DeleteScanResultUseCase().call(id);
    _ref.invalidate(scanHistoryProvider);
  }

  Future<void> clearAll() async {
    await ClearScanHistoryUseCase().call();
    _ref.invalidate(scanHistoryProvider);
  }
}

final scannerStateProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>(
        (ref) => ScannerNotifier(ref),);
