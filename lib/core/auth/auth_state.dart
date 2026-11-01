import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthStateController extends Notifier<User?> {
  @override
  User? build() {
    // Return the current user on initialization
    return Supabase.instance.client.auth.currentUser;
  }

  void setUser(User? user) {
    state = user;
  }
}

// Manually define the provider to avoid build_runner/generator crashes
final authStateControllerProvider = NotifierProvider<AuthStateController, User?>(
  AuthStateController.new,
);
