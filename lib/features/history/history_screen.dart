import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/formatting/icon_utils.dart';
import 'application/history_provider.dart';
import 'data/history_repository.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(workoutHistoryProvider),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    ref.read(historyFilterExerciseProvider.notifier).state = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search exercise...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          historyAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(e.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          ref.invalidate(workoutHistoryProvider);
                        },
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            data: (response) {
              if (response.records.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(theme));
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = response.records[index];
                    return _buildSessionCard(context, ref, theme, record);
                  },
                  childCount: response.records.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history, size: 64, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text('No History Found', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            "We couldn't find any workouts matching your criteria.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WidgetRef ref, ThemeData theme, record) {
    final date = DateTime.tryParse(record.startedAt) ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(getIconForExercise(record.entries.isNotEmpty ? record.entries.first.exercise : 'Workout'), color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formattedDate, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${record.exerciseCount} Exercises • ${record.totalVolume} kg Vol', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Session?'),
                        content: const Text('This will permanently delete this entire workout.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(historyRepositoryProvider).deleteSession(record.id);
                      ref.invalidate(workoutHistoryProvider);
                    }
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1),
          ...record.entries.map<Widget>((entry) {
            return ExpansionTile(
              title: Text(entry.exercise, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${entry.setsCount} sets x ${entry.totalReps} total reps • Vol: ${entry.volume} kg', style: theme.textTheme.labelSmall),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: entry.sets.map<Widget>((setEntry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            SizedBox(width: 40, child: Text('Set ${setEntry.setNumber}', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                            Expanded(child: Text('${setEntry.weightKg} kg', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium)),
                            Expanded(child: Text('${setEntry.reps} reps', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
