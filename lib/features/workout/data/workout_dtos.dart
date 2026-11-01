import '../../../core/formatting/json_numbers.dart';

class WorkoutSetPayload {
  const WorkoutSetPayload({required this.reps, required this.weightKg, this.rpe});

  final int reps;
  final double weightKg;
  final double? rpe;

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight_kg': weightKg,
    if (rpe != null) 'rpe': rpe,
  };
}

class WorkoutEntryPayload {
  const WorkoutEntryPayload({
    required this.exercise,
    required this.exerciseId,
    required this.exerciseType,
    required this.muscleGroup,
    required this.sets,
    this.rpe,
    this.notes,
    this.formScore,
    this.rangeOfMotion,
    this.deviceData = const {},
  });

  final String exercise;
  final String exerciseId;
  final String exerciseType;
  final String muscleGroup;
  final List<WorkoutSetPayload> sets;
  final double? rpe;
  final String? notes;
  final int? formScore;
  final int? rangeOfMotion;
  final Map<String, dynamic> deviceData;

  Map<String, dynamic> toJson() => {
    'exercise': exercise,
    'exercise_id': exerciseId,
    'exercise_type': exerciseType,
    'muscle_group': muscleGroup,
    'rpe': rpe,
    'notes': notes,
    'form_score': formScore,
    'range_of_motion': rangeOfMotion,
    'device_data': deviceData,
    'sets': sets.map((s) => s.toJson()).toList(),
  };
}

class SessionMetadataPayload {
  const SessionMetadataPayload({
    this.mood,
    this.energy,
    this.sleepQuality,
    this.bodyweightKg,
    this.notes,
  });

  final int? mood;
  final int? energy;
  final int? sleepQuality;
  final double? bodyweightKg;
  final String? notes;

  Map<String, dynamic> toJson() => {
    if (mood != null) 'mood': mood,
    if (energy != null) 'energy': energy,
    if (sleepQuality != null) 'sleep_quality': sleepQuality,
    if (bodyweightKg != null) 'bodyweight_kg': bodyweightKg,
    if (notes != null) 'notes': notes,
  };
}

class WorkoutLogRequest {
  const WorkoutLogRequest({
    required this.startedAt,
    required this.entries,
    this.sessionMetadata,
  });

  final DateTime startedAt;
  final List<WorkoutEntryPayload> entries;
  final SessionMetadataPayload? sessionMetadata;

  Map<String, dynamic> toJson() => {
    'started_at': startedAt.toUtc().toIso8601String(),
    'entries': entries.map((e) => e.toJson()).toList(),
    if (sessionMetadata != null) 'session_metadata': sessionMetadata!.toJson(),
  };
}

class WorkoutInsight {
  const WorkoutInsight({
    required this.exercise,
    required this.isPr,
    required this.prevMaxKg,
    required this.formQuality,
    required this.suggestion,
  });

  final String exercise;
  final bool isPr;
  final double prevMaxKg;
  final String formQuality;
  final String suggestion;

  factory WorkoutInsight.fromJson(Map<String, dynamic> json) {
    return WorkoutInsight(
      exercise: json['exercise'] as String? ?? '',
      isPr: json['is_pr'] as bool? ?? false,
      prevMaxKg: asDouble(json['prev_max_kg']),
      formQuality: json['form_quality'] as String? ?? 'not_recorded',
      suggestion: json['suggestion'] as String? ?? '',
    );
  }
}

class WorkoutLogResponse {
  const WorkoutLogResponse({
    required this.status,
    required this.sessionId,
    required this.loggedEntries,
    required this.totalVolume,
    required this.insights,
    required this.timestamp,
  });

  final String status;
  final String sessionId;
  final int loggedEntries;
  final double totalVolume;
  final List<WorkoutInsight> insights;
  final String timestamp;

  factory WorkoutLogResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutLogResponse(
      status: json['status'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? '',
      loggedEntries: asInt(json['logged_entries']),
      totalVolume: asDouble(json['total_volume']),
      insights: (json['insights'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(WorkoutInsight.fromJson)
          .toList(),
      timestamp: json['timestamp'] as String? ?? '',
    );
  }
}
