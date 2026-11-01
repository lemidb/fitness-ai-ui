import '../../../core/formatting/json_numbers.dart';

class HistorySet {
  const HistorySet({
    required this.id,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.rpe,
  });

  final String id;
  final int setNumber;
  final int reps;
  final double weightKg;
  final double? rpe;

  factory HistorySet.fromJson(Map<String, dynamic> json) {
    return HistorySet(
      id: json['id']?.toString() ?? '',
      setNumber: asInt(json['set_number'], fallback: 1),
      reps: asInt(json['reps']),
      weightKg: asDouble(json['weight_kg']),
      rpe: asNullableDouble(json['rpe']),
    );
  }
}

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.exerciseId,
    required this.exercise,
    required this.exerciseType,
    required this.muscleGroup,
    required this.setsCount,
    required this.totalReps,
    required this.volume,
    required this.estimated1Rm,
    required this.sets,
    this.rpe,
    this.notes,
    this.formScore,
    this.rangeOfMotion,
  });

  final int id;
  final String? exerciseId;
  final String exercise;
  final String exerciseType;
  final String muscleGroup;
  final int setsCount;
  final int totalReps;
  final double? rpe;
  final String? notes;
  final dynamic formScore;
  final dynamic rangeOfMotion;
  final double volume;
  final double estimated1Rm;
  final List<HistorySet> sets;

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: asInt(json['id']),
      exerciseId: json['exercise_id'] as String?,
      exercise: json['exercise'] as String? ?? '',
      exerciseType: json['exercise_type'] as String? ?? 'strength',
      muscleGroup: json['muscle_group'] as String? ?? '',
      setsCount: asInt(json['sets_count']),
      totalReps: asInt(json['total_reps']),
      rpe: asNullableDouble(json['rpe']),
      notes: json['notes'] as String?,
      formScore: json['form_score'],
      rangeOfMotion: json['range_of_motion'],
      volume: asDouble(json['volume']),
      estimated1Rm: asDouble(json['estimated_1rm']),
      sets: (json['sets'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(HistorySet.fromJson)
          .toList(),
    );
  }
}

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.exerciseCount,
    required this.totalVolume,
    required this.entries,
    this.mood,
    this.energy,
    this.sleepQuality,
    this.bodyweightKg,
    this.notes,
  });

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? mood;
  final int? energy;
  final int? sleepQuality;
  final double? bodyweightKg;
  final String? notes;
  final int exerciseCount;
  final double totalVolume;
  final List<HistoryEntry> entries;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id']?.toString() ?? '',
      startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ?? DateTime.now(),
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      mood: asNullableInt(json['mood']),
      energy: asNullableInt(json['energy']),
      sleepQuality: asNullableInt(json['sleep_quality']),
      bodyweightKg: asNullableDouble(json['bodyweight_kg']),
      notes: json['notes'] as String?,
      exerciseCount: asInt(json['exercise_count']),
      totalVolume: asDouble(json['total_volume']),
      entries: (json['entries'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(HistoryEntry.fromJson)
          .toList(),
    );
  }
}

class HistoryPage {
  const HistoryPage({
    required this.records,
    required this.count,
    required this.limit,
    required this.offset,
  });

  final List<WorkoutSession> records;
  final int count;
  final int limit;
  final int offset;

  factory HistoryPage.fromJson(Map<String, dynamic> json) {
    return HistoryPage(
      records: (json['records'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WorkoutSession.fromJson)
          .toList(),
      count: asInt(json['count']),
      limit: asInt(json['limit'], fallback: 50),
      offset: asInt(json['offset']),
    );
  }
}
