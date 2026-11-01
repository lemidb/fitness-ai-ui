import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Basic 401 handling - we'd ideally attempt a refresh here if possible,
      // but Supabase usually auto-refreshes. If it fails, sign out.
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null || session.isExpired) {
        await Supabase.instance.client.auth.signOut();
      }
    }
    super.onError(err, handler);
  }
}
