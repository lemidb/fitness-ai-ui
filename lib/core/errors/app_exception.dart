class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.retryable = false});

  final String message;
  final int? statusCode;
  final bool retryable;

  @override
  String toString() => message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired. Sign in again.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found.']);
}

class DuplicateException extends AppException {
  const DuplicateException([super.message = 'That custom exercise already exists.']);
}

class ValidationException extends AppException {
  const ValidationException([super.message = 'Check the values and try again.']);
}

class ServiceUnavailableException extends AppException {
  const ServiceUnavailableException([
    super.message = 'Service temporarily unavailable. Retry in a moment.',
  ]) : super(retryable: true);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error. Check your connection.'])
    : super(retryable: true);
}
