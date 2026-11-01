class AuthMe {
  const AuthMe({required this.userId, required this.email, this.username});

  final String userId;
  final String email;
  final String? username;

  factory AuthMe.fromJson(Map<String, dynamic> json) {
    return AuthMe(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
    );
  }

  String get displayName {
    final name = username?.trim();
    if (name != null && name.isNotEmpty) return name;
    final local = email.split('@').first;
    return local.isEmpty ? 'Athlete' : local;
  }
}
