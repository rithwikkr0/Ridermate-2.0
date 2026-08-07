import 'package:flutter/foundation.dart';
import 'app_error.dart';

/// RiderMate 2.0 — Global Error Management & Exception Handler
class GlobalErrorHandler {
  static final List<AppError> _errorLog = [];

  static List<AppError> get errorLog => List.unmodifiable(_errorLog);

  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      logError(
        UnknownError(
          details.exceptionAsString(),
          code: 'FLUTTER_FRAMEWORK_ERROR',
        ),
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      logError(
        UnknownError(
          error.toString(),
          code: 'UNHANDLED_ASYNC_ERROR',
        ),
      );
      return true;
    };
  }

  static void logError(AppError error) {
    _errorLog.add(error);
    if (kDebugMode) {
      debugPrint('🚨 [RiderMate Error] ${error.code}: ${error.message}');
    }
  }

  static void clearLogs() => _errorLog.clear();
}
