import '../../../core/formatting/json_numbers.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.exerciseType,
    required this.defaultWeightKg,
    required this.defaultSets,
    required this.defaultReps,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String exerciseType;
  final double defaultWeightKg;
  final int defaultSets;
  final int defaultReps;

  bool get isLikelySharedCatalog => id.startsWith('ex-');

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscle_group'] as String? ?? 'full_body',
      exerciseType: json['exercise_type'] as String? ?? 'strength',
      defaultWeightKg: asDouble(json['default_weight_kg'], fallback: 50),
      defaultSets: asInt(json['default_sets'], fallback: 3),
      defaultReps: asInt(json['default_reps'], fallback: 10),
    );
  }

  Map<String, dynamic> toCreateBody() => {
    'name': name,
    'muscle_group': muscleGroup,
    'exercise_type': exerciseType,
    'default_weight_kg': defaultWeightKg,
    'default_sets': defaultSets,
    'default_reps': defaultReps,
  };
}
