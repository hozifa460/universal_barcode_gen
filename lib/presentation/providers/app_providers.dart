// App-level providers: theme mode, locale, settings.
// These persist via SharedPreferences and rebuild the MaterialApp when changed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// SharedPreferences provider — lazily initialized singleton.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// ThemeMode (system / light / dark) — persisted.
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(AppConstants.prefThemeMode);
    if (stored != null) {
      state = switch (stored) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setString(
      AppConstants.prefThemeMode,
      mode.name,
    );
  }
}

/// Locale provider — persists 'en' / 'ar'.
final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._ref) : super(const Locale('en')) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    final stored = prefs.getString(AppConstants.prefLocale);
    if (stored != null) {
      state = Locale(stored);
    }
  }

  Future<void> set(Locale locale) async {
    state = locale;
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setString(AppConstants.prefLocale, locale.languageCode);
  }

  Future<void> toggle() async {
    final next =
        state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    await set(next);
  }
}
