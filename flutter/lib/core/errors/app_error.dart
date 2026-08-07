/// RiderMate 2.0 — AppError Sealed Hierarchy
sealed class AppError implements Exception {
  final String message;
  final String? code;

  const AppError(this.message, {this.code});
}

class NetworkError extends AppError {
  final int? statusCode;
  const NetworkError(super.message, {super.code, this.statusCode});
}

class StorageError extends AppError {
  const StorageError(super.message, {super.code});
}

class PermissionError extends AppError {
  const PermissionError(super.message, {super.code});
}

class LocationError extends AppError {
  const LocationError(super.message, {super.code});
}

class ValidationError extends AppError {
  const ValidationError(super.message, {super.code});
}

class UnknownError extends AppError {
  const UnknownError(super.message, {super.code});
}
