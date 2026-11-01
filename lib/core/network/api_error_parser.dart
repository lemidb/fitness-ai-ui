import 'package:dio/dio.dart';

String parseApiError(dynamic error) {
  if (error is DioException) {
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          // Pydantic validation error parsing (FastAPI)
          try {
            return detail.map((e) => e['msg']?.toString() ?? 'Validation Error').join('\\n');
          } catch (_) {
            return 'Validation error in request.';
          }
        }
        return detail.toString();
      }
    }
    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Is it running?';
    }
    return error.message ?? 'Unknown network error occurred.';
  }
  return error.toString().replaceAll('Exception: ', '');
}
