import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../application/training_analysis_provider.dart';
import '../data/training_analysis_dtos.dart';
import '../../../core/formatting/icon_utils.dart';

class TrainingAnalysisView extends ConsumerWidget {
  const TrainingAnalysisView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncAnalysis = ref.watch(trainingAnalysisProvider);
    final days = ref.watch(trainingAnalysisDaysProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trainingAnalysisProvider);
        await ref.read(trainingAnalysisProvider.future);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 30, label: Text('30d')),
                  ButtonSegment(value: 90, label: Text('90d')),
                  ButtonSegment(value: 365, label: Text('1yr')),
                ],
                selected: {days},
                onSelectionChanged: (set) => ref.read(trainingAnalysisDaysProvider.notifier).state = set.first,
              ),
            ),
          ),
          
          asyncAnalysis.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, st) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Analysis Error', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(e.toString().replaceAll('Exception: ', ''), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => ref.invalidate(trainingAnalysisProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      )
                    ],
                  ),
                ),
              ),
            ),
            data: (data) {
              if (data.sessionsAnalyzed == 0) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.analytics_outlined, size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text('No Training Data', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Log some workouts to see your analysis.', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  if (data.truncated)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: theme.colorScheme.onTertiaryContainer),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Showing partial results (up to 200 sessions). Narrow your date range for specific trends.',
                              style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Overview Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Sessions', value: '${data.sessionsAnalyzed}', icon: Icons.calendar_today, color: Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Total Vol', value: '${(data.totalVolumeKgReps / 1000).toStringAsFixed(1)}k', icon: Icons.monitor_weight, color: Colors.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Total Reps', value: '${data.totalReps}', icon: Icons.repeat, color: Colors.green)),
                      ],
                    ),
                  ),

                  // Recommendations
                  if (data.generalRecommendations.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('AI Recommendations', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'General rule-based guidance derived from your workout history, not medical advice.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...data.generalRecommendations.map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    )),
                  ],

                  // Exercise Progress
                  if (data.exerciseProgress.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('Key Exercise Trends', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    ...data.exerciseProgress.map((ex) => _buildProgressCard(theme, ex)),
                  ],

                  // Sessions Timeline
                  if (data.sessions.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text('Analyzed Sessions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    ...data.sessions.map((session) => _buildSessionTile(theme, session)),
                    const SizedBox(height: 48),
                  ],
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, ExerciseProgressInfo ex) {
    IconData trendIcon = Icons.trending_flat;
    Color trendColor = Colors.grey;
    if (ex.trend == 'up') {
      trendIcon = Icons.trending_up;
      trendColor = Colors.green;
    } else if (ex.trend == 'down') {
      trendIcon = Icons.trending_down;
      trendColor = Colors.red;
    }

    final changeStr = ex.estimated1rmChangePercent != null 
      ? '${ex.estimated1rmChangePercent! > 0 ? '+' : ''}${ex.estimated1rmChangePercent!.toStringAsFixed(1)}%' 
      : 'Not enough history';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(getIconForExercise(ex.exercise), color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.exercise, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('${ex.workoutCount} workouts analyzed', style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(trendIcon, size: 16, color: trendColor),
                      const SizedBox(width: 4),
                      Text(changeStr, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Latest 1RM', style: theme.textTheme.labelMedium),
                    Text('${ex.latestEstimated1rmKg.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Best 1RM', style: theme.textTheme.labelMedium),
                    Text('${ex.bestEstimated1rmKg.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vol Change', style: theme.textTheme.labelMedium),
                    Text(ex.volumeChangePercent != null ? '${ex.volumeChangePercent! > 0 ? '+' : ''}${ex.volumeChangePercent!.toStringAsFixed(1)}%' : '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(ex.recommendation, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(ThemeData theme, TrainingSessionInfo session) {
    final date = DateTime.tryParse(session.startedAt) ?? DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy').format(date);

    return ExpansionTile(
      leading: const Icon(Icons.fitness_center),
      title: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('${session.exerciseCount} exercises • ${session.totalReps} reps • ${session.volumeKgReps.toStringAsFixed(0)} kg vol'),
      children: session.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.exercise, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary)),
              const SizedBox(height: 4),
              ...entry.sets.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(width: 50, child: Text('Set ${s.setNumber}', style: theme.textTheme.labelSmall)),
                    Expanded(child: Text('${s.weightKg} kg x ${s.reps} reps', style: theme.textTheme.bodySmall)),
                    if (s.rpe != null) Expanded(child: Text('RPE ${s.rpe}', style: theme.textTheme.bodySmall)),
                    Expanded(child: Text('1RM: ${s.estimated1rmKg.toStringAsFixed(1)}', style: theme.textTheme.labelSmall, textAlign: TextAlign.right)),
                  ],
                ),
              ))
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          Text(title, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
