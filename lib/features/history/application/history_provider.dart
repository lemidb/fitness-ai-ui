import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/history.dart';
import '../data/history_repository.dart';

final historyFilterDaysProvider = StateProvider<int>((ref) => 90);
final historyFilterExerciseProvider = StateProvider<String?>((ref) => null);

final workoutHistoryProvider = FutureProvider<HistoryResponse>((ref) async {
  final repo = ref.watch(historyRepositoryProvider);
  final days = ref.watch(historyFilterDaysProvider);
  final exercise = ref.watch(historyFilterExerciseProvider);
  
  return repo.getHistory(
    days: days,
    exercise: exercise,
    limit: 50,
    offset: 0,
  );
});
