import 'failures.dart';

/// Represents the result of an operation that can either succeed or fail.
///
/// Use pattern matching to handle both cases:
/// ```dart
/// switch (result) {
///   case Success(:final value):
///     // Handle success
///   case Error(:final failure):
///     // Handle error
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// Represents a successful result with a value.
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents a failed result with a [Failure].
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Error<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;
}
