// Root MaterialApp widget.
// Wires up: theme provider, locale provider, router, localization.
//
// Uses Material 3 with dynamic color (Android 12+) with brand fallback,
// supports light + dark mode, and Arabic/English with full RTL switching.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../presentation/providers/app_providers.dart';
import '../presentation/router/app_router.dart';
import 'app_theme.dart';

class UniversalBarcodeApp extends ConsumerWidget {
  const UniversalBarcodeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Universal Barcode & QR Generator',
      debugShowCheckedModeBanner: false,

      // Localization
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theming
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // Router
      routerConfig: router,

      // Builder to enforce text direction per locale.
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.30,
          child: child!,
        );
      },
    );
  }
}
