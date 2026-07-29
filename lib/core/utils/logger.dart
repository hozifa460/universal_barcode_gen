// AppLogger: thin wrapper over the `logger` package.
// One singleton instance; debug-only logging in release builds.

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._internal();
  static final AppLogger instance = AppLogger._internal();

  final Logger _logger = Logger(
    level: kDebugMode ? Level.trace : Level.off,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  void debug(String message) => _logger.d(message);
  void info(String message) => _logger.i(message);
  void warning(String message) => _logger.w(message);
  void error(String message, Object? error, StackTrace? stack) =>
      _logger.e(message, error: error, stackTrace: stack);
  void trace(String message) => _logger.t(message);
}
