import 'app_error.dart';

/// RiderMate 2.0 — Functional Result[T] Wrapper
sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppError error) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  AppError? get errorOrNull => isFailure ? (this as Failure<T>).error : null;

  T? get data => dataOrNull;
  AppError? get error => errorOrNull;
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}
