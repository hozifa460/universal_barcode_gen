// Universal Barcode & QR Generator
// Production-grade Flutter application
// Architecture: Clean Architecture + MVVM + Riverpod
//
// Entry point. Bootstraps the app, initializes Hive local storage,
// loads locale + theme preferences, and runs the MaterialApp.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  await bootstrap();

  // Lock orientation to portrait for phones, allow tablet rotation handled per-screen.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Use transparent system bars so Material 3 surface tint shows through.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: UniversalBarcodeApp(),
    ),
  );
}
