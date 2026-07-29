// Settings providers.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../core/constants/qr_style.dart';

export '../../core/constants/qr_style.dart' show ErrorCorrectionLevel;
export '../../core/constants/qr_style.dart' show ExportFormat;

final settingsProvider =
    FutureProvider<AppSettings>((ref) async {
  final r = await GetSettingsUseCase().call();
  return r.getOrThrow();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier(this._ref) : super(const AppSettings());

  final Ref _ref;

  Future<void> load() async {
    final r = await GetSettingsUseCase().call();
    r.fold(onLeft: (_) {}, onRight: (s) => state = s);
  }

  Future<void> update(AppSettings settings) async {
    final r = await SaveSettingsUseCase().call(settings);
    r.fold(onLeft: (_) {}, onRight: (s) {
      state = s;
      _ref.invalidate(settingsProvider);
    },);
  }

  Future<void> setEcLevel(ErrorCorrectionLevel level) async {
    await update(state.copyWith(defaultErrorCorrection: level));
  }

  Future<void> setClipboardMonitor(bool v) async {
    await update(state.copyWith(clipboardMonitor: v));
  }

  Future<void> setAutoOpenUrls(bool v) async {
    await update(state.copyWith(autoOpenUrls: v));
  }

  Future<void> setDefaultExportSize(int size) async {
    await update(state.copyWith(defaultExportSize: size));
  }

  Future<void> setContinuousScan(bool v) async {
    await update(state.copyWith(continuousScan: v));
  }

  Future<void> setFlashlightDefault(bool v) async {
    await update(state.copyWith(flashlightDefault: v));
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>(
        (ref) => SettingsNotifier(ref),);

