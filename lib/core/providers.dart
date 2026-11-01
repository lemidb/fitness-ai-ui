import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/auth_me.dart';
import 'auth/auth_repository.dart';
import 'auth/auth_session.dart';
import 'config/app_config.dart';
import 'formatting/units.dart';
import 'network/fitness_api.dart';

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnvironment());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return createAuthRepository(ref.watch(appConfigProvider));
});

final authSessionProvider = StreamProvider<AuthSession?>((ref) {
  return ref.watch(authRepositoryProvider).sessionChanges;
});

final fitnessApiProvider = Provider<FitnessApi>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return FitnessApi(
    config: ref.watch(appConfigProvider),
    auth: repo,
    onSessionExpired: () {
      repo.signOut();
    },
  );
});

final authMeProvider = FutureProvider<AuthMe?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) return null;
  return ref.watch(fitnessApiProvider).me();
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

class WeightUnitNotifier extends Notifier<WeightUnit> {
  static const _key = 'weight_unit';

  @override
  WeightUnit build() {
    ref.listen(sharedPreferencesProvider, (previous, next) {
      next.whenData((prefs) {
        final raw = prefs.getString(_key);
        if (raw == 'lb') state = WeightUnit.lb;
      });
    });
    return WeightUnit.kg;
  }

  Future<void> setUnit(WeightUnit unit) async {
    state = unit;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_key, unit == WeightUnit.kg ? 'kg' : 'lb');
  }
}

final weightUnitProvider = NotifierProvider<WeightUnitNotifier, WeightUnit>(
  WeightUnitNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    ref.listen(sharedPreferencesProvider, (previous, next) {
      next.whenData((prefs) {
        final raw = prefs.getString(_key);
        if (raw == 'dark') state = ThemeMode.dark;
        else if (raw == 'light') state = ThemeMode.light;
      });
    });
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    String modeStr = 'system';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    await prefs.setString(_key, modeStr);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

