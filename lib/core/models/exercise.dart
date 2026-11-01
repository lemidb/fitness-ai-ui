class Exercise {
  final String? id;
  final String name;
  final String muscleGroup;
  final String exerciseType;
  final double defaultWeightKg;
  final int defaultSets;
  final int defaultReps;

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    required this.exerciseType,
    required this.defaultWeightKg,
    required this.defaultSets,
    required this.defaultReps,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown Exercise',
      muscleGroup: json['muscle_group'] as String? ?? 'chest',
      exerciseType: json['exercise_type'] as String? ?? 'strength',
      defaultWeightKg: (json['default_weight_kg'] as num?)?.toDouble() ?? 50.0,
      defaultSets: (json['default_sets'] as num?)?.toInt() ?? 3,
      defaultReps: (json['default_reps'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'exercise_type': exerciseType,
      'default_weight_kg': defaultWeightKg,
      'default_sets': defaultSets,
      'default_reps': defaultReps,
    };
  }
}
