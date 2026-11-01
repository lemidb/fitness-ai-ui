class HistorySet {
  final String id;
  final int setNumber;
  final int reps;
  final double weightKg;
  final double? rpe;

  HistorySet({
    required this.id,
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.rpe,
  });

  factory HistorySet.fromJson(Map<String, dynamic> json) {
    return HistorySet(
      id: json['id']?.toString() ?? '',
      setNumber: (json['set_number'] as num?)?.toInt() ?? 1,
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      rpe: (json['rpe'] as num?)?.toDouble(),
    );
  }
}

class HistoryEntry {
  final int id;
  final String? exerciseId;
  final String exercise;
  final String exerciseType;
  final String muscleGroup;
  final int setsCount;
  final int totalReps;
  final double? rpe;
  final String? notes;
  final double volume;
  final double estimated1Rm;
  final List<HistorySet> sets;

  HistoryEntry({
    required this.id,
    this.exerciseId,
    required this.exercise,
    required this.exerciseType,
    required this.muscleGroup,
    required this.setsCount,
    required this.totalReps,
    this.rpe,
    this.notes,
    required this.volume,
    required this.estimated1Rm,
    required this.sets,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    var setsList = json['sets'] as List?;
    return HistoryEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      exerciseId: json['exercise_id']?.toString(),
      exercise: json['exercise']?.toString() ?? 'Unknown',
      exerciseType: json['exercise_type']?.toString() ?? 'strength',
      muscleGroup: json['muscle_group']?.toString() ?? 'chest',
      setsCount: (json['sets_count'] as num?)?.toInt() ?? 0,
      totalReps: (json['total_reps'] as num?)?.toInt() ?? 0,
      rpe: (json['rpe'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
      estimated1Rm: (json['estimated_1rm'] as num?)?.toDouble() ?? 0.0,
      sets: setsList != null
          ? setsList.map((e) => HistorySet.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class HistoryRecord {
  final String id;
  final String startedAt;
  final String completedAt;
  final int mood;
  final int energy;
  final int sleepQuality;
  final double? bodyweightKg;
  final String? notes;
  final int exerciseCount;
  final double totalVolume;
  final List<HistoryEntry> entries;

  HistoryRecord({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.mood,
    required this.energy,
    required this.sleepQuality,
    this.bodyweightKg,
    this.notes,
    required this.exerciseCount,
    required this.totalVolume,
    required this.entries,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    var entriesList = json['entries'] as List?;
    return HistoryRecord(
      id: json['id']?.toString() ?? '',
      startedAt: json['started_at']?.toString() ?? '',
      completedAt: json['completed_at']?.toString() ?? '',
      mood: (json['mood'] as num?)?.toInt() ?? 8,
      energy: (json['energy'] as num?)?.toInt() ?? 8,
      sleepQuality: (json['sleep_quality'] as num?)?.toInt() ?? 8,
      bodyweightKg: (json['bodyweight_kg'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
      exerciseCount: (json['exercise_count'] as num?)?.toInt() ?? 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      entries: entriesList != null
          ? entriesList.map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class HistoryResponse {
  final List<HistoryRecord> records;
  final int count;
  final int limit;
  final int offset;

  HistoryResponse({
    required this.records,
    required this.count,
    required this.limit,
    required this.offset,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    var recordsList = json['records'] as List?;
    return HistoryResponse(
      records: recordsList != null
          ? recordsList.map((e) => HistoryRecord.fromJson(e as Map<String, dynamic>)).toList()
          : [],
      count: (json['count'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 50,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }
}
