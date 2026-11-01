import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../application/calendar_provider.dart';
import '../../../core/formatting/icon_utils.dart';
import 'create_event_sheet.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(calendarEventsProvider);
    final daysAhead = ref.watch(calendarDaysAheadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Go to Profile to connect Google Calendar.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 Days')),
                ButtonSegment(value: 14, label: Text('14 Days')),
                ButtonSegment(value: 30, label: Text('30 Days')),
              ],
              selected: {daysAhead},
              onSelectionChanged: (set) => ref.read(calendarDaysAheadProvider.notifier).state = set.first,
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(e.toString().replaceAll('Exception: ', '')),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.invalidate(calendarEventsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('No upcoming workouts scheduled.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final date = DateFormat('EEEE, MMM d • h:mm a').format(event.startAt);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Icon(getIconForExercise(event.title), color: theme.colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      Text(date, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
                                    ],
                                  ),
                                ),
                                if (event.estimatedDurationMin != null)
                                  Text('${event.estimatedDurationMin}m', style: theme.textTheme.labelSmall),
                              ],
                            ),
                            if (event.location != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 8),
                                  Text(event.location!, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ],
                            if (event.aiInsights != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.auto_awesome, size: 16, color: theme.colorScheme.secondary),
                                        const SizedBox(width: 8),
                                        Text('AI Warm-up Routine', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.secondary)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(event.aiInsights.toString(), style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: theme.colorScheme.surface,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            builder: (ctx) => const CreateEventSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
