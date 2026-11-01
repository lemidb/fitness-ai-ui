import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import 'auth_session.dart';

abstract class AuthRepository {
  AuthSession? get currentSession;
  Stream<AuthSession?> get sessionChanges;
  Future<AuthSession> signIn({required String email, required String password});
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    String? username,
  });
  Future<void> signOut();
  Future<bool> refreshSession();
  String? get accessToken;
}

class UnconfiguredAuthRepository implements AuthRepository {
  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthSession?> get sessionChanges async* {
    yield null;
  }

  @override
  String? get accessToken => null;

  @override
  Future<bool> refreshSession() async => false;

  @override
  Future<AuthSession> signIn({required String email, required String password}) {
    throw const AppException(
      'Supabase is not configured. Pass SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY via --dart-define.',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    String? username,
  }) {
    throw const AppException(
      'Supabase is not configured. Pass SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY via --dart-define.',
    );
  }
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  static AuthSession? fromSupabase(Session? session) {
    if (session == null) return null;
    final user = session.user;
    final metadata = user.userMetadata ?? {};
    final username = (metadata['username'] ?? metadata['name']) as String?;
    return AuthSession(
      userId: user.id,
      email: user.email ?? '',
      accessToken: session.accessToken,
      username: username,
    );
  }

  @override
  AuthSession? get currentSession => fromSupabase(_client.auth.currentSession);

  @override
  Stream<AuthSession?> get sessionChanges async* {
    yield currentSession;
    yield* _client.auth.onAuthStateChange.map((event) => fromSupabase(event.session));
  }

  @override
  String? get accessToken => _client.auth.currentSession?.accessToken;

  @override
  Future<AuthSession> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final session = fromSupabase(response.session);
      if (session == null) {
        throw const AppException('Sign in succeeded but no session was returned.');
      }
      return session;
    } on AuthException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final data = <String, dynamic>{};
      final trimmed = username?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        data['username'] = trimmed;
        data['name'] = trimmed;
      }
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: data.isEmpty ? null : data,
      );
      final session = fromSupabase(response.session);
      return SignUpResult(
        needsEmailConfirmation: session == null,
        session: session,
      );
    } on AuthException catch (error) {
      throw AppException(error.message);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<bool> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response.session != null;
    } on AuthException {
      return false;
    }
  }
}

AuthRepository createAuthRepository(AppConfig config) {
  if (!config.isSupabaseConfigured) {
    return UnconfiguredAuthRepository();
  }
  return SupabaseAuthRepository(Supabase.instance.client);
}
