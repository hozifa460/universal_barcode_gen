// Bootstrap: pre- runApp initialization.
// Initializes Hive boxes, secure storage readiness, error handlers, etc.
//
// Kept separate from main() so that integration tests can call bootstrap()
// in setUpAll without launching the Flutter UI.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';

Future<void> bootstrap() async {
  // Always wrap async bootstrap in a guard so widget binding is ready.
  WidgetsFlutterBinding.ensureInitialized();

  // Global Flutter error handler — log and never crash to a red screen.
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.instance.error('FlutterError', details.exception, details.stack);
  };

  // Isolate error handler — for errors outside the Flutter framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.instance.error('PlatformError', error, stack);
    return true;
  };

  // Initialize Hive for fast local NoSQL storage of history, folders, tags.
  await Hive.initFlutter();

  // Open all required boxes in parallel for fast startup.
  await Future.wait([
    Hive.openBox(AppConstants.historyBox),
    Hive.openBox(AppConstants.foldersBox),
    Hive.openBox(AppConstants.tagsBox),
    Hive.openBox(AppConstants.favoritesBox),
    Hive.openBox(AppConstants.presetsBox),
    Hive.openBox(AppConstants.scanHistoryBox),
    Hive.openBox(AppConstants.templatesBox),
    Hive.openBox(AppConstants.settingsBox),
  ]);

  // SharedPreferences for theme + locale + simple flags.
  await SharedPreferences.getInstance();

  // This directory is unavailable in browser builds.
  if (!kIsWeb) {
    await getApplicationDocumentsDirectory();
  }

  if (kDebugMode) {
    AppLogger.instance.info('Bootstrap complete');
  }
}
