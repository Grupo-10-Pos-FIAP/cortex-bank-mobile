import 'package:cortex_bank_mobile/core/errors/failure.dart';

/// Base type for operations that can succeed or fail.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        FailureResult() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        FailureResult(:final failure) => failure,
      };

  R fold<R>(R Function(T value) onSuccess, R Function(Failure failure) onFailure) {
    return switch (this) {
      Success(:final value) => onSuccess(value),
      FailureResult(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
