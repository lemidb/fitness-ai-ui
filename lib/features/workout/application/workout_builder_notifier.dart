import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/workout.dart';

class WorkoutBuilderState {
  final List<WorkoutEntry> entries;
  final SessionMetadata metadata;

  WorkoutBuilderState({
    required this.entries,
    required this.metadata,
  });

  WorkoutBuilderState copyWith({
    List<WorkoutEntry>? entries,
    SessionMetadata? metadata,
  }) {
    return WorkoutBuilderState(
      entries: entries ?? this.entries,
      metadata: metadata ?? this.metadata,
    );
  }
}

final workoutBuilderProvider = NotifierProvider<WorkoutBuilderNotifier, WorkoutBuilderState>(
  WorkoutBuilderNotifier.new,
);

class WorkoutBuilderNotifier extends Notifier<WorkoutBuilderState> {
  @override
  WorkoutBuilderState build() {
    return WorkoutBuilderState(
      entries: [],
      metadata: SessionMetadata(),
    );
  }

  void addExercise(Exercise exercise) {
    final newEntry = WorkoutEntry(
      exercise: exercise.name,
      exerciseId: exercise.id,
      exerciseType: exercise.exerciseType,
      muscleGroup: exercise.muscleGroup,
      sets: List.generate(
        exercise.defaultSets,
        (index) => WorkoutSet(reps: exercise.defaultReps, weightKg: exercise.defaultWeightKg),
      ),
    );
    state = state.copyWith(entries: [...state.entries, newEntry]);
  }

  void removeEntry(int entryIndex) {
    final newEntries = [...state.entries]..removeAt(entryIndex);
    state = state.copyWith(entries: newEntries);
  }

  void addSet(int entryIndex) {
    final entry = state.entries[entryIndex];
    // Copy the last set's weight/reps if available, else default
    final lastSet = entry.sets.isNotEmpty ? entry.sets.last : WorkoutSet(reps: 10, weightKg: 0);
    final newSets = [...entry.sets, WorkoutSet(reps: lastSet.reps, weightKg: lastSet.weightKg)];
    
    final newEntries = [...state.entries];
    newEntries[entryIndex] = entry.copyWith(sets: newSets);
    state = state.copyWith(entries: newEntries);
  }

  void removeSet(int entryIndex, int setIndex) {
    final entry = state.entries[entryIndex];
    if (entry.sets.length <= 1) return; // Prevent removing last set entirely
    final newSets = [...entry.sets]..removeAt(setIndex);
    
    final newEntries = [...state.entries];
    newEntries[entryIndex] = entry.copyWith(sets: newSets);
    state = state.copyWith(entries: newEntries);
  }

  void updateSet(int entryIndex, int setIndex, int newReps, double newWeight) {
    final entry = state.entries[entryIndex];
    final newSets = [...entry.sets];
    newSets[setIndex] = WorkoutSet(reps: newReps, weightKg: newWeight, rpe: newSets[setIndex].rpe);
    
    final newEntries = [...state.entries];
    newEntries[entryIndex] = entry.copyWith(sets: newSets);
    state = state.copyWith(entries: newEntries);
  }

  void updateMetadata({int? mood, int? energy, int? sleepQuality, String? notes}) {
    state = state.copyWith(
      metadata: state.metadata.copyWith(
        mood: mood,
        energy: energy,
        sleepQuality: sleepQuality,
        notes: notes,
      ),
    );
  }

  void clearSession() {
    state = WorkoutBuilderState(entries: [], metadata: SessionMetadata());
  }
}
