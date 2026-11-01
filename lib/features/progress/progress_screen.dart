import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/formatting/icon_utils.dart';
import '../exercises/presentation/exercise_picker_sheet.dart';
import 'application/progress_provider.dart';
import '../../core/models/progress.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedEx = ref.watch(selectedProgressExerciseProvider);
    final progressAsync = ref.watch(exerciseProgressProvider);
    final days = ref.watch(progressDaysFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Progress'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Select Exercise
          InkWell(
            onTap: () async {
               // We reuse the picker sheet. But we need a custom callback or global read?
               // Since exercise picker sheet currently adds to workoutBuilder directly, 
               // let's build a dedicated simple dropdown or a custom sheet if needed.
               // For now, let's open the same sheet but intercept the selection.
               // To avoid coupling, we will use a dialog for simplicity.
               _showExerciseSelector(context, ref, theme);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(selectedEx != null ? getIconForExercise(selectedEx.name, muscleGroup: selectedEx.muscleGroup) : Icons.fitness_center, color: theme.colorScheme.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      selectedEx?.name ?? 'Select an Exercise...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: selectedEx != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          if (selectedEx != null) ...[
            // Days Filter
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 30, label: Text('30d')),
                ButtonSegment(value: 90, label: Text('90d')),
                ButtonSegment(value: 365, label: Text('1yr')),
              ],
              selected: {days},
              onSelectionChanged: (Set<int> newSelection) {
                ref.read(progressDaysFilterProvider.notifier).state = newSelection.first;
              },
            ),
            const SizedBox(height: 24),
            
            progressAsync.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
              error: (e, st) {
                final msg = e.toString().replaceAll('Exception: ', '');
                // 404 is technically an empty state for progress
                if (msg.toLowerCase().contains('not found')) {
                  return _buildEmptyState(theme, 'No data yet for ${selectedEx.name}. Log a workout first!');
                }
                return Center(
                  child: Column(
                    children: [
                      Text(msg, style: TextStyle(color: theme.colorScheme.error)),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => ref.invalidate(exerciseProgressProvider),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              },
              data: (data) {
                if (data == null) return const SizedBox.shrink();
                if (data.points.isEmpty) return _buildEmptyState(theme, 'No data yet for ${selectedEx.name}.');
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatsGrid(theme, data),
                    const SizedBox(height: 24),
                    Text('Strength Progression', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildChart(theme, data),
                  ],
                );
              },
            )
          ] else ...[
             const SizedBox(height: 32),
             _buildEmptyState(theme, 'Select an exercise above to generate strength regression charts, volume trends, and PR showcases.'),
          ]
        ],
      ),
    );
  }

  void _showExerciseSelector(BuildContext context, WidgetRef ref, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const ExercisePickerForProgress(),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_graph, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text('No Data Available', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, ProgressData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _statTile(theme, 'Max Weight', '${data.maxWeight} kg', Icons.fitness_center),
        _statTile(theme, 'Avg Weight', '${data.avgWeight.toStringAsFixed(1)} kg', Icons.calculate),
        _statTile(theme, 'Max Volume', '${data.maxVolume} kg', Icons.stacked_bar_chart),
        _statTile(theme, 'Sessions', '${data.totalWorkouts}', Icons.calendar_today),
      ],
    );
  }

  Widget _statTile(ThemeData theme, String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const Spacer(),
          Text(val, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme, ProgressData data) {
    if (data.points.isEmpty) return const SizedBox.shrink();

    final spots = data.points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.maxWeight);
    }).toList();

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom picker for progress to avoid adding to workout builder
class ExercisePickerForProgress extends ConsumerStatefulWidget {
  const ExercisePickerForProgress({super.key});

  @override
  ConsumerState<ExercisePickerForProgress> createState() => _ExercisePickerForProgressState();
}

class _ExercisePickerForProgressState extends ConsumerState<ExercisePickerForProgress> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('Select Exercise', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            onChanged: (val) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                ref.read(exerciseSearchProvider.notifier).state = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search library...', prefixIcon: const Icon(Icons.search), filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: exercisesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text(e.toString().replaceAll('Exception: ', ''))),
            data: (exercises) {
              return ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return ListTile(
                    leading: Icon(getIconForExercise(ex.name, muscleGroup: ex.muscleGroup), color: theme.colorScheme.primary),
                    title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(ex.muscleGroup.toUpperCase(), style: theme.textTheme.labelSmall),
                    onTap: () {
                      ref.read(selectedProgressExerciseProvider.notifier).state = ex;
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
