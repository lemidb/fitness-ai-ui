import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/exercise.dart';

class ExerciseFilter {
  const ExerciseFilter({this.search = '', this.muscleGroup, this.exerciseType});

  final String search;
  final String? muscleGroup;
  final String? exerciseType;

  ExerciseFilter copyWith({
    String? search,
    String? muscleGroup,
    String? exerciseType,
    bool clearMuscle = false,
    bool clearType = false,
  }) {
    return ExerciseFilter(
      search: search ?? this.search,
      muscleGroup: clearMuscle ? null : (muscleGroup ?? this.muscleGroup),
      exerciseType: clearType ? null : (exerciseType ?? this.exerciseType),
    );
  }

  bool get isEmpty => search.isEmpty && muscleGroup == null && exerciseType == null;
}

class ExerciseFilterNotifier extends Notifier<ExerciseFilter> {
  @override
  ExerciseFilter build() => const ExerciseFilter();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setMuscle(String? value) =>
      state = value == null ? state.copyWith(clearMuscle: true) : state.copyWith(muscleGroup: value);
  void setType(String? value) =>
      state = value == null ? state.copyWith(clearType: true) : state.copyWith(exerciseType: value);
  void clear() => state = const ExerciseFilter();
}

final exerciseFilterProvider = NotifierProvider<ExerciseFilterNotifier, ExerciseFilter>(
  ExerciseFilterNotifier.new,
);

final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final filter = ref.watch(exerciseFilterProvider);
  return ref.watch(fitnessApiProvider).listExercises(
    search: filter.search.trim().isEmpty ? null : filter.search.trim(),
    muscleGroup: filter.muscleGroup,
    exerciseType: filter.exerciseType,
  );
});

final createdCustomIdsProvider = StateProvider<Set<String>>((ref) => <String>{});
