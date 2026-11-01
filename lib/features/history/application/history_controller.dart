import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/history_dtos.dart';

class HistoryFilter {
  const HistoryFilter({this.days = 90, this.exercise = '', this.muscleGroup});

  final int days;
  final String exercise;
  final String? muscleGroup;

  HistoryFilter copyWith({int? days, String? exercise, String? muscleGroup, bool clearMuscle = false}) {
    return HistoryFilter(
      days: days ?? this.days,
      exercise: exercise ?? this.exercise,
      muscleGroup: clearMuscle ? null : (muscleGroup ?? this.muscleGroup),
    );
  }
}

class HistoryFilterNotifier extends Notifier<HistoryFilter> {
  @override
  HistoryFilter build() => const HistoryFilter();

  void setDays(int days) => state = state.copyWith(days: days);
  void setExercise(String value) => state = state.copyWith(exercise: value);
  void setMuscle(String? value) =>
      state = value == null ? state.copyWith(clearMuscle: true) : state.copyWith(muscleGroup: value);
}

final historyFilterProvider = NotifierProvider<HistoryFilterNotifier, HistoryFilter>(
  HistoryFilterNotifier.new,
);

class HistoryListState {
  const HistoryListState({
    this.records = const [],
    this.count = 0,
    this.offset = 0,
    this.limit = 50,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  final List<WorkoutSession> records;
  final int count;
  final int offset;
  final int limit;
  final bool loading;
  final bool loadingMore;
  final String? error;

  bool get canLoadMore => records.length < count;

  HistoryListState copyWith({
    List<WorkoutSession>? records,
    int? count,
    int? offset,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool clearError = false,
  }) {
    return HistoryListState(
      records: records ?? this.records,
      count: count ?? this.count,
      offset: offset ?? this.offset,
      limit: limit,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HistoryController extends Notifier<HistoryListState> {
  @override
  HistoryListState build() {
    ref.listen(historyFilterProvider, (previous, next) {
      load(reset: true);
    });
    Future.microtask(() => load(reset: true));
    return const HistoryListState(loading: true);
  }

  Future<void> load({bool reset = false}) async {
    final filter = ref.read(historyFilterProvider);
    final offset = reset ? 0 : state.records.length;
    state = state.copyWith(
      loading: reset,
      loadingMore: !reset,
      clearError: true,
      records: reset ? const [] : state.records,
    );
    try {
      final page = await ref.read(fitnessApiProvider).history(
        days: filter.days,
        exercise: filter.exercise.trim().isEmpty ? null : filter.exercise.trim(),
        muscleGroup: filter.muscleGroup,
        limit: state.limit,
        offset: offset,
      );
      state = state.copyWith(
        records: reset ? page.records : [...state.records, ...page.records],
        count: page.count,
        offset: page.offset,
        loading: false,
        loadingMore: false,
      );
    } catch (error) {
      state = state.copyWith(loading: false, loadingMore: false, error: error.toString());
    }
  }

  Future<void> deleteSession(String id) async {
    await ref.read(fitnessApiProvider).deleteSession(id);
    await load(reset: true);
  }

  Future<void> deleteEntry(int id) async {
    await ref.read(fitnessApiProvider).deleteEntry(id);
    await load(reset: true);
  }

  String toCsv() {
    final buffer = StringBuffer('date,exercise,sets,reps,weight_kg,volume,rpe\n');
    for (final session in state.records) {
      for (final entry in session.entries) {
        for (final set in entry.sets) {
          buffer.writeln(
            '${session.startedAt.toIso8601String()},${entry.exercise},${set.setNumber},${set.reps},${set.weightKg},${set.reps * set.weightKg},${set.rpe ?? ''}',
          );
        }
      }
    }
    return buffer.toString();
  }
}

final historyControllerProvider = NotifierProvider<HistoryController, HistoryListState>(
  HistoryController.new,
);

final recentHistoryProvider = FutureProvider<HistoryPage?>((ref) async {
  final session = await ref.watch(authSessionProvider.future);
  if (session == null) return null;
  return ref.watch(fitnessApiProvider).history(days: 90, limit: 20, offset: 0);
});
