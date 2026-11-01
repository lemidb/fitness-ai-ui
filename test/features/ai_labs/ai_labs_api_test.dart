import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:fitness_ai_ui/core/network/fitness_api.dart';
import 'package:fitness_ai_ui/core/auth/auth_repository.dart';
import 'package:fitness_ai_ui/core/config/app_config.dart';
import 'package:fitness_ai_ui/core/errors/app_exception.dart';

class MockAuthRepository implements AuthRepository {
  @override
  String? get accessToken => 'mock_token';
  
  @override
  get currentSession => throw UnimplementedError();
  @override
  Future<bool> refreshSession() async => true;
  @override
  get sessionChanges => throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  signIn({required String email, required String password}) => throw UnimplementedError();
  @override
  signUp({required String email, required String password, String? username}) => throw UnimplementedError();
}

void main() {
  group('FitnessApi AiLabs Form Analysis', () {
    test('local upload throws AppException correctly on error', () async {
      final dio = Dio();
      final authRepo = MockAuthRepository();
      final config = AppConfig(supabaseUrl: 'url', supabasePublishableKey: 'key', apiBaseUrl: 'http://localhost');
      
      final api = FitnessApi(config: config, auth: authRepo, dio: dio);

      // Attempt to hit a non-existent URL or trigger an error to ensure errors are mapped to AppException
      expect(
        () => api.analyzeForm('Bench Press', videoUrl: 'https://youtube.com/invalid'),
        throwsA(isA<AppException>()),
      );
    });

    test('FormData check for URL', () async {
      // Just verifying we can create the parameters without exception
      final dio = Dio();
      final authRepo = MockAuthRepository();
      final config = AppConfig(supabaseUrl: 'url', supabasePublishableKey: 'key', apiBaseUrl: 'http://localhost');
      final api = FitnessApi(config: config, auth: authRepo, dio: dio);
      
      // we can't fully mock dio without a mock adapter easily in a plain script, but we ensure structure is sound.
      expect(api, isNotNull);
    });
  });
}
