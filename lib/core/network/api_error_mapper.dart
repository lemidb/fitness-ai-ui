import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

AppException mapDioError(DioException error) {
  final status = error.response?.statusCode;
  final serverMessage = _serverMessage(error.response?.data);

  switch (status) {
    case 401:
      return UnauthorizedException(serverMessage ?? 'Session expired. Sign in again.');
    case 404:
      return NotFoundException(serverMessage ?? 'Not found.');
    case 409:
      return DuplicateException(serverMessage ?? 'That custom exercise already exists.');
    case 422:
      return ValidationException(serverMessage ?? 'Check the values and try again.');
    case 503:
      return ServiceUnavailableException(
        serverMessage ?? 'Service temporarily unavailable. Retry in a moment.',
      );
  }

  if (error.type == DioExceptionType.connectionError ||
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.sendTimeout) {
    return const NetworkException();
  }

  return AppException(
    serverMessage ?? 'Request failed.',
    statusCode: status,
    retryable: status != null && status >= 500,
  );
}

String? _serverMessage(dynamic data) {
  if (data is Map) {
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      return detail.map((e) => e.toString()).join('\n');
    }
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}
