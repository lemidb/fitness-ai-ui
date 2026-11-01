import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.apiBaseUrl,
  });

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String apiBaseUrl;

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      supabaseUrl: const String.fromEnvironment('SUPABASE_URL').isNotEmpty 
          ? const String.fromEnvironment('SUPABASE_URL') 
          : dotenv.env['SUPABASE_URL'] ?? '',
      supabasePublishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY')
          : dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
      apiBaseUrl: const String.fromEnvironment('API_BASE_URL').isNotEmpty
          ? const String.fromEnvironment('API_BASE_URL')
          : dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000',
    );
  }

  bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  bool get isApiConfigured => apiBaseUrl.isNotEmpty;
}
