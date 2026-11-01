import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/workout.dart';
import '../exercises/presentation/exercise_picker_sheet.dart';
import '../ai_labs/application/training_analysis_provider.dart';
import 'application/workout_builder_notifier.dart';
import 'data/workout_repository.dart';

class LogWorkoutScreen extends ConsumerWidget {
  const LogWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final builderState = ref.watch(workoutBuilderProvider);
    final entries = builderState.entries;
    final metadata = builderState.metadata;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          if (entries.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Save Session', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () async {
                try {
                  final payload = WorkoutPayload(
                    startedAt: DateTime.now().toIso8601String(),
                    entries: entries,
                    sessionMetadata: metadata,
                  );
                  await ref.read(workoutRepositoryProvider).logWorkout(payload);
                  ref.read(workoutBuilderProvider.notifier).clearSession();
                  // Invalidate training analysis to refresh after workout
                  ref.invalidate(trainingAnalysisProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Session Saved Successfully!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                   if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: entries.isEmpty
          ? _buildEmptyState(context, theme)
          : ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                ...entries.asMap().entries.map((e) => _buildEntryCard(context, ref, theme, e.key, e.value)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FilledButton.tonalIcon(
                    onPressed: () => showExercisePicker(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Exercise'),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('Session Check-in', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                _buildVitalsSlider(context, ref, 'Mood', Icons.sentiment_satisfied, metadata.mood, (val) => ref.read(workoutBuilderProvider.notifier).updateMetadata(mood: val)),
                _buildVitalsSlider(context, ref, 'Energy', Icons.bolt, metadata.energy, (val) => ref.read(workoutBuilderProvider.notifier).updateMetadata(energy: val)),
                _buildVitalsSlider(context, ref, 'Sleep', Icons.bedtime, metadata.sleepQuality, (val) => ref.read(workoutBuilderProvider.notifier).updateMetadata(sleepQuality: val)),
              ],
            ),
      floatingActionButton: entries.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showExercisePicker(context),
              icon: const Icon(Icons.add),
              label: const Text('Exercise'),
            ),
    );
  }

  Widget _buildEntryCard(BuildContext context, WidgetRef ref, ThemeData theme, int entryIndex, WorkoutEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.exercise,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save'),
                  onPressed: () async {
                    try {
                      final payload = WorkoutPayload(
                        startedAt: DateTime.now().toIso8601String(),
                        entries: [entry],
                        sessionMetadata: ref.read(workoutBuilderProvider).metadata,
                      );
                      await ref.read(workoutRepositoryProvider).logWorkout(payload);
                      ref.read(workoutBuilderProvider.notifier).removeEntry(entryIndex);
                      // Invalidate training analysis to refresh after workout
                      ref.invalidate(trainingAnalysisProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Exercise Saved Successfully!'), backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => ref.read(workoutBuilderProvider.notifier).removeEntry(entryIndex),
                )
              ],
            ),
            const SizedBox(height: 16),
            // Sets Table Header
            Row(
              children: [
                const SizedBox(width: 32, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold))),
                const Expanded(child: Center(child: Text('KG', style: TextStyle(fontWeight: FontWeight.bold)))),
                const Expanded(child: Center(child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)))),
                const SizedBox(width: 36), // For delete icon
              ],
            ),
            const Divider(),
            // Sets Rows
            ...entry.sets.asMap().entries.map((setEntry) {
              final setIndex = setEntry.key;
              final workoutSet = setEntry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(width: 32, child: Text('${setIndex + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    // Weight
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: () => ref.read(workoutBuilderProvider.notifier).updateSet(entryIndex, setIndex, workoutSet.reps, (workoutSet.weightKg - 2.5).clamp(0, 999)),
                            ),
                            Expanded(
                              child: _NumberInputField(
                                initialValue: workoutSet.weightKg,
                                isDecimal: true,
                                onChanged: (val) => ref.read(workoutBuilderProvider.notifier).updateSet(entryIndex, setIndex, workoutSet.reps, val.clamp(0, 999)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: () => ref.read(workoutBuilderProvider.notifier).updateSet(entryIndex, setIndex, workoutSet.reps, workoutSet.weightKg + 2.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Reps
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: () => ref.read(workoutBuilderProvider.notifier).updateSet(entryIndex, setIndex, (workoutSet.reps - 1).clamp(0, 999), workoutSet.weightKg),
                            ),
                            Expanded(
                              child: _NumberInputField(
                                initialValue: workoutSet.reps.toDouble(),
                                isDecimal: false,
                                onChanged: (val) => ref.read(workoutBuilderProvider.notifier).updateSet(entryIndex, setIndex, val.toInt().clamp(0, 999), workoutSet.weightKg),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                              onPressed: () => ref.read(workoutBuilderProvider.notifier).updateSet(entryIndex, setIndex, workoutSet.reps + 1, workoutSet.weightKg),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => ref.read(workoutBuilderProvider.notifier).removeSet(entryIndex, setIndex),
                      ),
                    )
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => ref.read(workoutBuilderProvider.notifier).addSet(entryIndex),
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => showExercisePicker(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
                    child: Icon(Icons.add_task, size: 48, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text('Start Your Workout', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tap to search the library and add your first exercise.', textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsSlider(BuildContext context, WidgetRef ref, String title, IconData icon, int value, Function(int) onChanged) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleSmall),
              const Spacer(),
              Text('$value / 10', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: theme.colorScheme.primary,
            onChanged: (val) => onChanged(val.toInt()),
          ),
        ],
      ),
    );
  }
}

class _NumberInputField extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final bool isDecimal;

  const _NumberInputField({
    required this.initialValue,
    required this.onChanged,
    this.isDecimal = false,
  });

  @override
  State<_NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<_NumberInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.isDecimal 
        ? widget.initialValue.toString() 
        : widget.initialValue.toInt().toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _NumberInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      final newText = widget.isDecimal 
        ? widget.initialValue.toString() 
        : widget.initialValue.toInt().toString();
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onSubmitted: (val) {
        final number = double.tryParse(val) ?? 0;
        widget.onChanged(number);
      },
      onTapOutside: (_) {
        final number = double.tryParse(_controller.text) ?? 0;
        widget.onChanged(number);
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

