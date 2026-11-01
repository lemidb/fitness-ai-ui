import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/auth/auth_state.dart';
import '../../core/formatting/icon_utils.dart';
import '../history/application/history_provider.dart';
import '../calendar/application/calendar_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateControllerProvider);
    final username = user?.userMetadata?['username'] as String?;
    final email = user?.email;
    final displayName = username?.isNotEmpty == true ? username : email ?? 'Athlete';
    final theme = Theme.of(context);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final calendarAsync = ref.watch(calendarEventsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => context.go('/profile'),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sleek Hero Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'READY TO CRUSH IT?',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayName!,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.go('/workout'),
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.onPrimary,
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.fitness_center),
                          label: const Text('Start Workout Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/ai-labs'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onPrimary,
                            side: BorderSide(color: theme.colorScheme.onPrimary.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          icon: const Icon(Icons.psychology),
                          label: const Text('Open AI Labs', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Upcoming Schedule Strip (Phase 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Schedule', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => context.push('/calendar'),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: calendarAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Setup Google Calendar in Profile', style: theme.textTheme.bodySmall)),
                      data: (events) {
                        if (events.isEmpty) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy, color: theme.colorScheme.outline),
                                const SizedBox(height: 8),
                                Text('No upcoming workouts scheduled.', style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            final formattedDate = DateFormat('MMM d, h:mm a').format(event.startAt);
                            return Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                                boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.event, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(formattedDate, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary), overflow: TextOverflow.ellipsis)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const Spacer(),
                                  if (event.aiInsights != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.auto_awesome, size: 12, color: theme.colorScheme.onTertiaryContainer),
                                          const SizedBox(width: 4),
                                          Text('AI Warmup Ready', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onTertiaryContainer)),
                                        ],
                                      ),
                                    )
                                  else if (event.location != null)
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14, color: theme.colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(event.location!, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Stats Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Weekly Overview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  historyAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(
                      child: Column(
                        children: [
                          const Text('Error loading stats'),
                          TextButton(
                            onPressed: () => ref.invalidate(workoutHistoryProvider),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                    data: (response) {
                      double totalVol = 0;
                      int workouts = 0;
                      final now = DateTime.now();
                      final oneWeekAgo = now.subtract(const Duration(days: 7));
                      for (var record in response.records) {
                        final date = DateTime.tryParse(record.startedAt) ?? now;
                        if (date.isAfter(oneWeekAgo)) {
                          totalVol += record.totalVolume;
                          workouts++;
                        }
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Total Volume',
                              value: totalVol.toStringAsFixed(0),
                              unit: 'kg',
                              icon: Icons.monitor_weight_outlined,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Workouts',
                              value: workouts.toString(),
                              unit: 'sessions',
                              icon: Icons.calendar_today_outlined,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Recent Activity Sleek Empty State
                  Text('Recent Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  historyAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(
                      child: Column(
                        children: [
                          const Text('Error loading recent workouts'),
                          TextButton(
                            onPressed: () => ref.invalidate(workoutHistoryProvider),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                    data: (response) {
                      if (response.records.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_toggle_off, size: 64, color: theme.colorScheme.outline),
                              const SizedBox(height: 16),
                              Text(
                                'No Recent Workouts',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your logged workouts will appear here beautifully.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final recentRecords = response.records.take(3).toList();
                      return Column(
                        children: recentRecords.map((record) {
                          final date = DateTime.tryParse(record.startedAt) ?? DateTime.now();
                          final formattedDate = DateFormat('MMM d, yyyy').format(date);
                          final exName = record.entries.isNotEmpty ? record.entries.first.exercise : 'Workout';
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 8),
                            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: Icon(getIconForExercise(exName), color: theme.colorScheme.primary),
                              ),
                              title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${record.exerciseCount} Exercises • ${record.totalVolume} kg Vol'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.go('/history'),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

