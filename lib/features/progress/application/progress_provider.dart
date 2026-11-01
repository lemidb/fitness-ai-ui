import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/progress.dart';
import '../data/progress_repository.dart';

final selectedProgressExerciseProvider = StateProvider<Exercise?>((ref) => null);
final progressDaysFilterProvider = StateProvider<int>((ref) => 90);

final exerciseProgressProvider = FutureProvider<ProgressData?>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final exercise = ref.watch(selectedProgressExerciseProvider);
  final days = ref.watch(progressDaysFilterProvider);

  if (exercise == null) return null;
  
  return repo.getProgress(exercise.name, days);
});
