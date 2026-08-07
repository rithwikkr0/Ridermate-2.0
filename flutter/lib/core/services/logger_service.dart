import 'package:flutter/foundation.dart';

abstract class LoggerService {
  void debug(String message, [dynamic error, StackTrace? stackTrace]);
  void info(String message);
  void warning(String message, [dynamic error, StackTrace? stackTrace]);
  void error(String message, [dynamic error, StackTrace? stackTrace]);
}

class AppLoggerService implements LoggerService {
  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🐛 [DEBUG] $message ${error ?? ''}');
    }
  }

  @override
  void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [INFO] $message');
    }
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('⚠️ [WARN] $message ${error ?? ''}');
    }
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('🚨 [ERROR] $message ${error ?? ''}');
      if (stackTrace != null) print(stackTrace);
    }
  }
}
