import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_interceptor.dart';

// Manually define the provider to avoid build_runner/generator crashes
final dioClientProvider = Provider<Dio>((ref) {
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
  
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(AuthInterceptor());
  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true)); 

  return dio;
});
