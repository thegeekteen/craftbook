/// Custom exceptions for the application
class AppException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

class DatabaseException extends AppException {
  const DatabaseException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'DatabaseException: $message';
}

class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException extends AppException {
  const NotFoundException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'NotFoundException: $message';
}
