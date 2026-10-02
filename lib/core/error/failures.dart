import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Database-related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Network-related failures (for future sync)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
