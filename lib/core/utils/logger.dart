import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Global logger instance for consistent logging across the app.
final log = AppLogger.instance;

/// Lightweight wrapper around the [logger] package for unified logging.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: (DateTime time) => time.toIso8601String(),
    ),
  );

  static final AppLogger instance = AppLogger._();

  /// Logs a debug message (only visible in debug mode).
  void d(String message) {
    if (kDebugMode) _logger.d(message);
  }

  /// Logs a general info message.
  void i(String message) {
    _logger.i(message);
  }

  /// Logs a warning.
  void w(String message) {
    _logger.w(message);
  }

  /// Logs an error and optionally sends it to Crashlytics (release mode).
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Skip logging to Crashlytics on web or debug
    if (kIsWeb || kDebugMode) return;

    // Forward to Firebase Crashlytics
    final crashlytics = FirebaseCrashlytics.instance;
    crashlytics.recordError(
      error ?? message,
      stackTrace,
      reason: message,
      printDetails: false,
      fatal: false,
    );
  }
}
