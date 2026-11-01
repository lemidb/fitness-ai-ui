class WorkoutSet {
  final int reps;
  final double weightKg;
  final double? rpe;

  WorkoutSet({
    required this.reps,
    required this.weightKg,
    this.rpe,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      reps: (json['reps'] as num?)?.toInt() ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      rpe: (json['rpe'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight_kg': weightKg,
      if (rpe != null) 'rpe': rpe,
    };
  }
}

class WorkoutEntry {
  final String exercise;
  final String? exerciseId;
  final String exerciseType;
  final String muscleGroup;
  final double? rpe;
  final String? notes;
  final int? formScore;
  final int? rangeOfMotion;
  final Map<String, dynamic>? deviceData;
  final List<WorkoutSet> sets;

  WorkoutEntry({
    required this.exercise,
    this.exerciseId,
    required this.exerciseType,
    required this.muscleGroup,
    this.rpe,
    this.notes,
    this.formScore,
    this.rangeOfMotion,
    this.deviceData,
    required this.sets,
  });

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    var setsList = json['sets'] as List?;
    return WorkoutEntry(
      exercise: json['exercise'] as String? ?? 'Unknown',
      exerciseId: json['exercise_id'] as String?,
      exerciseType: json['exercise_type'] as String? ?? 'strength',
      muscleGroup: json['muscle_group'] as String? ?? 'chest',
      rpe: (json['rpe'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      formScore: (json['form_score'] as num?)?.toInt(),
      rangeOfMotion: (json['range_of_motion'] as num?)?.toInt(),
      deviceData: json['device_data'] as Map<String, dynamic>?,
      sets: setsList != null
          ? setsList.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise,
      if (exerciseId != null) 'exercise_id': exerciseId,
      'exercise_type': exerciseType,
      'muscle_group': muscleGroup,
      if (rpe != null) 'rpe': rpe,
      if (notes != null) 'notes': notes,
      if (formScore != null) 'form_score': formScore,
      if (rangeOfMotion != null) 'range_of_motion': rangeOfMotion,
      if (deviceData != null) 'device_data': deviceData,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }

  // Helper copyWith for state immutability
  WorkoutEntry copyWith({
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutEntry(
      exercise: exercise,
      exerciseId: exerciseId,
      exerciseType: exerciseType,
      muscleGroup: muscleGroup,
      rpe: rpe,
      notes: notes ?? this.notes,
      formScore: formScore,
      rangeOfMotion: rangeOfMotion,
      deviceData: deviceData,
      sets: sets ?? this.sets,
    );
  }
}

class SessionMetadata {
  final int mood;
  final int energy;
  final int sleepQuality;
  final double? bodyweightKg;
  final String? notes;

  SessionMetadata({
    this.mood = 8,
    this.energy = 8,
    this.sleepQuality = 8,
    this.bodyweightKg,
    this.notes,
  });

  factory SessionMetadata.fromJson(Map<String, dynamic> json) {
    return SessionMetadata(
      mood: (json['mood'] as num?)?.toInt() ?? 8,
      energy: (json['energy'] as num?)?.toInt() ?? 8,
      sleepQuality: (json['sleep_quality'] as num?)?.toInt() ?? 8,
      bodyweightKg: (json['bodyweight_kg'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood': mood,
      'energy': energy,
      'sleep_quality': sleepQuality,
      if (bodyweightKg != null) 'bodyweight_kg': bodyweightKg,
      if (notes != null) 'notes': notes,
    };
  }

  SessionMetadata copyWith({
    int? mood,
    int? energy,
    int? sleepQuality,
    double? bodyweightKg,
    String? notes,
  }) {
    return SessionMetadata(
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      bodyweightKg: bodyweightKg ?? this.bodyweightKg,
      notes: notes ?? this.notes,
    );
  }
}

class WorkoutPayload {
  final String startedAt;
  final List<WorkoutEntry> entries;
  final SessionMetadata sessionMetadata;

  WorkoutPayload({
    required this.startedAt,
    required this.entries,
    required this.sessionMetadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'started_at': startedAt,
      'entries': entries.map((e) => e.toJson()).toList(),
      'session_metadata': sessionMetadata.toJson(),
    };
  }
}
