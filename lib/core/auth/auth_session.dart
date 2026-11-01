class AuthSession {
  const AuthSession({
    required this.userId,
    required this.email,
    required this.accessToken,
    this.username,
  });

  final String userId;
  final String email;
  final String accessToken;
  final String? username;
}

class SignUpResult {
  const SignUpResult({required this.needsEmailConfirmation, this.session});

  final bool needsEmailConfirmation;
  final AuthSession? session;
}
