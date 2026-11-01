class TrainingAnalysisResponse {
  final int periodDays;
  final String generatedAt;
  final int sessionsAnalyzed;
  final bool truncated;
  final double totalVolumeKgReps;
  final int totalReps;
  final List<TrainingSessionInfo> sessions;
  final List<ExerciseProgressInfo> exerciseProgress;
  final List<String> generalRecommendations;

  TrainingAnalysisResponse({
    required this.periodDays,
    required this.generatedAt,
    required this.sessionsAnalyzed,
    required this.truncated,
    required this.totalVolumeKgReps,
    required this.totalReps,
    required this.sessions,
    required this.exerciseProgress,
    required this.generalRecommendations,
  });

  factory TrainingAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return TrainingAnalysisResponse(
      periodDays: json['period_days'] as int? ?? 365,
      generatedAt: json['generated_at'] as String? ?? '',
      sessionsAnalyzed: json['sessions_analyzed'] as int? ?? 0,
      truncated: json['truncated'] as bool? ?? false,
      totalVolumeKgReps: (json['total_volume_kg_reps'] as num?)?.toDouble() ?? 0.0,
      totalReps: json['total_reps'] as int? ?? 0,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((e) => TrainingSessionInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      exerciseProgress: (json['exercise_progress'] as List<dynamic>?)
              ?.map((e) => ExerciseProgressInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generalRecommendations: (json['general_recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class TrainingSessionInfo {
  final String id;
  final String startedAt;
  final int exerciseCount;
  final double volumeKgReps;
  final int totalReps;
  final Map<String, dynamic>? sessionMetadata;
  final List<TrainingEntryInfo> entries;

  TrainingSessionInfo({
    required this.id,
    required this.startedAt,
    required this.exerciseCount,
    required this.volumeKgReps,
    required this.totalReps,
    this.sessionMetadata,
    required this.entries,
  });

  factory TrainingSessionInfo.fromJson(Map<String, dynamic> json) {
    return TrainingSessionInfo(
      id: json['id'] as String? ?? '',
      startedAt: json['started_at'] as String? ?? '',
      exerciseCount: json['exercise_count'] as int? ?? 0,
      volumeKgReps: (json['volume_kg_reps'] as num?)?.toDouble() ?? 0.0,
      totalReps: json['total_reps'] as int? ?? 0,
      sessionMetadata: json['session_metadata'] as Map<String, dynamic>?,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => TrainingEntryInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TrainingEntryInfo {
  final String exercise;
  final List<TrainingSetInfo> sets;

  TrainingEntryInfo({
    required this.exercise,
    required this.sets,
  });

  factory TrainingEntryInfo.fromJson(Map<String, dynamic> json) {
    return TrainingEntryInfo(
      exercise: json['exercise'] as String? ?? 'Unknown',
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => TrainingSetInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TrainingSetInfo {
  final int setNumber;
  final int reps;
  final double weightKg;
  final double? rpe;
  final double volumeKgReps;
  final double estimated1rmKg;

  TrainingSetInfo({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.rpe,
    required this.volumeKgReps,
    required this.estimated1rmKg,
  });

  factory TrainingSetInfo.fromJson(Map<String, dynamic> json) {
    return TrainingSetInfo(
      setNumber: json['set_number'] as int? ?? 1,
      reps: json['reps'] as int? ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      rpe: (json['rpe'] as num?)?.toDouble(),
      volumeKgReps: (json['volume_kg_reps'] as num?)?.toDouble() ?? 0.0,
      estimated1rmKg: (json['estimated_1rm_kg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ExerciseProgressInfo {
  final String exercise;
  final String trend;
  final int workoutCount;
  final double latestEstimated1rmKg;
  final double bestEstimated1rmKg;
  final double? estimated1rmChangePercent;
  final double? volumeChangePercent;
  final String recommendation;

  ExerciseProgressInfo({
    required this.exercise,
    required this.trend,
    required this.workoutCount,
    required this.latestEstimated1rmKg,
    required this.bestEstimated1rmKg,
    this.estimated1rmChangePercent,
    this.volumeChangePercent,
    required this.recommendation,
  });

  factory ExerciseProgressInfo.fromJson(Map<String, dynamic> json) {
    return ExerciseProgressInfo(
      exercise: json['exercise'] as String? ?? '',
      trend: json['trend'] as String? ?? 'flat',
      workoutCount: json['workout_count'] as int? ?? 0,
      latestEstimated1rmKg: (json['latest_estimated_1rm_kg'] as num?)?.toDouble() ?? 0.0,
      bestEstimated1rmKg: (json['best_estimated_1rm_kg'] as num?)?.toDouble() ?? 0.0,
      estimated1rmChangePercent: (json['estimated_1rm_change_percent'] as num?)?.toDouble(),
      volumeChangePercent: (json['volume_change_percent'] as num?)?.toDouble(),
      recommendation: json['recommendation'] as String? ?? '',
    );
  }
}
