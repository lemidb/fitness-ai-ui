import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatting/units.dart';
import '../../../core/formatting/workout_math.dart';
import '../../../core/providers.dart';
import '../../exercises/data/exercise.dart';
import '../data/workout_dtos.dart';

class StagedSet {
  const StagedSet({required this.reps, required this.weightKg, this.rpe});

  final int reps;
  final double weightKg;
  final double? rpe;

  StagedSet copyWith({int? reps, double? weightKg, double? rpe, bool clearRpe = false}) {
    return StagedSet(
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      rpe: clearRpe ? null : (rpe ?? this.rpe),
    );
  }

  ({int reps, double weightKg}) get math => (reps: reps, weightKg: weightKg);
}

class StagedEntry {
  const StagedEntry({
    required this.localId,
    required this.exerciseId,
    required this.exercise,
    required this.exerciseType,
    required this.muscleGroup,
    required this.sets,
    this.rpe,
    this.notes = '',
  });

  final String localId;
  final String exerciseId;
  final String exercise;
  final String exerciseType;
  final String muscleGroup;
  final List<StagedSet> sets;
  final double? rpe;
  final String notes;

  double get volume => entryVolume(sets.map((s) => s.math));
  double get estimated1Rm => entryEstimated1Rm(sets.map((s) => s.math));

  StagedEntry copyWith({
    List<StagedSet>? sets,
    double? rpe,
    String? notes,
    String? exercise,
    String? exerciseId,
    String? exerciseType,
    String? muscleGroup,
  }) {
    return StagedEntry(
      localId: localId,
      exerciseId: exerciseId ?? this.exerciseId,
      exercise: exercise ?? this.exercise,
      exerciseType: exerciseType ?? this.exerciseType,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
    );
  }
}

class WorkoutDraft {
  const WorkoutDraft({
    required this.current,
    this.staged = const [],
    this.mood = 7,
    this.energy = 7,
    this.sleepQuality = 7,
    this.bodyweightKg,
    this.notes = '',
    this.submitting = false,
    this.error,
    this.lastResult,
  });

  final StagedEntry current;
  final List<StagedEntry> staged;
  final int mood;
  final int energy;
  final int sleepQuality;
  final double? bodyweightKg;
  final String notes;
  final bool submitting;
  final String? error;
  final WorkoutLogResponse? lastResult;

  double get liveVolume => current.volume;
  double get live1Rm => current.estimated1Rm;
  bool get canSubmitCurrent => current.exercise.trim().length >= 2 && current.sets.isNotEmpty;
  bool get canSubmitSession => staged.isNotEmpty;

  WorkoutDraft copyWith({
    StagedEntry? current,
    List<StagedEntry>? staged,
    int? mood,
    int? energy,
    int? sleepQuality,
    double? bodyweightKg,
    bool clearBodyweight = false,
    String? notes,
    bool? submitting,
    String? error,
    bool clearError = false,
    WorkoutLogResponse? lastResult,
    bool clearResult = false,
  }) {
    return WorkoutDraft(
      current: current ?? this.current,
      staged: staged ?? this.staged,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      bodyweightKg: clearBodyweight ? null : (bodyweightKg ?? this.bodyweightKg),
      notes: notes ?? this.notes,
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
      lastResult: clearResult ? null : (lastResult ?? this.lastResult),
    );
  }
}

StagedEntry emptyEntry() {
  return StagedEntry(
    localId: DateTime.now().microsecondsSinceEpoch.toString(),
    exerciseId: '',
    exercise: '',
    exerciseType: 'strength',
    muscleGroup: 'chest',
    sets: const [StagedSet(reps: 8, weightKg: 40)],
  );
}

class WorkoutController extends Notifier<WorkoutDraft> {
  @override
  WorkoutDraft build() => WorkoutDraft(current: emptyEntry());

  void applyExercise(Exercise exercise) {
    final sets = List<StagedSet>.generate(
      exercise.defaultSets.clamp(1, 100),
      (_) => StagedSet(reps: exercise.defaultReps, weightKg: exercise.defaultWeightKg),
    );
    state = state.copyWith(
      current: state.current.copyWith(
        exercise: exercise.name,
        exerciseId: exercise.id,
        exerciseType: exercise.exerciseType,
        muscleGroup: exercise.muscleGroup,
        sets: sets,
      ),
      clearResult: true,
    );
  }

  void setExerciseName(String name) {
    state = state.copyWith(current: state.current.copyWith(exercise: name));
  }

  void updateSet(int index, StagedSet set) {
    final sets = [...state.current.sets];
    if (index < 0 || index >= sets.length) return;
    sets[index] = set;
    state = state.copyWith(current: state.current.copyWith(sets: sets));
  }

  void addSet() {
    final last = state.current.sets.isEmpty
        ? const StagedSet(reps: 8, weightKg: 40)
        : state.current.sets.last;
    state = state.copyWith(current: state.current.copyWith(sets: [...state.current.sets, last]));
  }

  void removeSet(int index) {
    if (state.current.sets.length <= 1) return;
    final sets = [...state.current.sets]..removeAt(index);
    state = state.copyWith(current: state.current.copyWith(sets: sets));
  }

  void setCurrentRpe(double rpe) {
    state = state.copyWith(current: state.current.copyWith(rpe: rpe));
  }

  void setCurrentNotes(String notes) {
    state = state.copyWith(current: state.current.copyWith(notes: notes));
  }

  void addCurrentToSession() {
    if (!state.canSubmitCurrent) return;
    state = state.copyWith(
      staged: [...state.staged, state.current],
      current: emptyEntry(),
    );
  }

  void removeStaged(String localId) {
    state = state.copyWith(staged: state.staged.where((e) => e.localId != localId).toList());
  }

  void setMood(int value) => state = state.copyWith(mood: value);
  void setEnergy(int value) => state = state.copyWith(energy: value);
  void setSleep(int value) => state = state.copyWith(sleepQuality: value);
  void setNotes(String value) => state = state.copyWith(notes: value);
  void setBodyweightKg(double? value) =>
      state = value == null ? state.copyWith(clearBodyweight: true) : state.copyWith(bodyweightKg: value);

  WorkoutLogRequest _request(List<StagedEntry> entries) {
    return WorkoutLogRequest(
      startedAt: DateTime.now().toUtc(),
      entries: entries
          .map(
            (entry) => WorkoutEntryPayload(
              exercise: entry.exercise,
              exerciseId: entry.exerciseId.isEmpty ? entry.exercise : entry.exerciseId,
              exerciseType: entry.exerciseType,
              muscleGroup: entry.muscleGroup,
              rpe: entry.rpe,
              notes: entry.notes.isEmpty ? null : entry.notes,
              sets: entry.sets
                  .map((set) => WorkoutSetPayload(reps: set.reps, weightKg: set.weightKg, rpe: set.rpe))
                  .toList(),
            ),
          )
          .toList(),
      sessionMetadata: SessionMetadataPayload(
        mood: state.mood,
        energy: state.energy,
        sleepQuality: state.sleepQuality,
        bodyweightKg: state.bodyweightKg,
        notes: state.notes.isEmpty ? null : state.notes,
      ),
    );
  }

  Future<void> logCurrent() async {
    if (!state.canSubmitCurrent) {
      state = state.copyWith(error: 'Add an exercise and at least one set.');
      return;
    }
    await _submit([state.current], clearCurrent: true);
  }

  Future<void> saveSession() async {
    if (!state.canSubmitSession) {
      state = state.copyWith(error: 'Add at least one exercise to the session builder.');
      return;
    }
    await _submit(state.staged, clearStaged: true);
  }

  Future<void> _submit(List<StagedEntry> entries, {bool clearCurrent = false, bool clearStaged = false}) async {
    state = state.copyWith(submitting: true, clearError: true, clearResult: true);
    try {
      final result = await ref.read(fitnessApiProvider).logWorkout(_request(entries));
      state = WorkoutDraft(
        current: clearCurrent ? emptyEntry() : state.current,
        staged: clearStaged ? const [] : state.staged,
        lastResult: result,
      );
    } catch (error) {
      state = state.copyWith(submitting: false, error: error.toString());
    }
  }
}

final workoutControllerProvider = NotifierProvider<WorkoutController, WorkoutDraft>(
  WorkoutController.new,
);

double displayWeight(double kg, WeightUnit unit) => kgToDisplay(kg, unit);
double storedKg(double display, WeightUnit unit) => displayToKg(display, unit);
