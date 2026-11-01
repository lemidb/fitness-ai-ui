import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth/auth_state.dart';
import '../../core/providers.dart';

final calendarConnectionProvider = FutureProvider<dynamic>((ref) async {
  final api = ref.watch(fitnessApiProvider);
  return await api.getAuthConnections();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateControllerProvider);
    final username = user?.userMetadata?['username'] as String?;
    final email = user?.email;
    final themeMode = ref.watch(themeModeProvider);
    final connectionAsync = ref.watch(calendarConnectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            username?.isNotEmpty == true ? username! : 'Athlete',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Text(
            email ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
              ],
              selected: {themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Units'),
            subtitle: const Text('Metric (kg)'), // Placeholder for phase 1 stretch goal
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implement unit toggle (local pref only)
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('Integrations', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          connectionAsync.when(
            loading: () => const ListTile(title: Text('Loading connections...')),
            error: (e, st) => ListTile(
              title: const Text('Error loading connections'),
              trailing: TextButton(
                onPressed: () => ref.invalidate(calendarConnectionProvider),
                child: const Text('Retry'),
              ),
            ),
            data: (data) {
              final isConnected = data != null && data['google_calendar'] == true;
              return ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Google Calendar'),
                subtitle: Text(isConnected ? 'Connected' : 'Not Connected'),
                trailing: isConnected ? const Icon(Icons.check_circle, color: Colors.green) : TextButton(
                  onPressed: () async {
                    // Logic to connect to google calendar would go here
                    // e.g. using Supabase OAuth or GoogleSignIn plugin to get token, then
                    // await ref.read(fitnessApiProvider).syncGoogleCalendar(accessToken);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google Calendar Sync triggered (requires OAuth token)')),
                    );
                  },
                  child: const Text('Connect'),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                ref.read(authStateControllerProvider.notifier).setUser(null);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          )
        ],
      ),
    );
  }
}
