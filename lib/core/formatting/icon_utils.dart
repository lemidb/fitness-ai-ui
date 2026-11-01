import 'package:flutter/material.dart';

IconData getIconForMuscleGroup(String group) {
  switch (group.toLowerCase().trim()) {
    case 'chest':
      return Icons.fitness_center;
    case 'back':
      return Icons.airline_seat_recline_extra;
    case 'legs':
      return Icons.directions_run;
    case 'arms':
      return Icons.sports_mma;
    case 'shoulders':
      return Icons.sports_gymnastics;
    case 'core':
    case 'abs':
      return Icons.accessibility_new;
    case 'cardio':
      return Icons.directions_bike;
    default:
      return Icons.fitness_center;
  }
}

IconData getIconForExercise(String exerciseName, {String? muscleGroup}) {
  if (muscleGroup != null && muscleGroup.isNotEmpty) {
    return getIconForMuscleGroup(muscleGroup);
  }
  
  final name = exerciseName.toLowerCase();
  if (name.contains('bench') || name.contains('chest') || name.contains('fly')) {
    return Icons.fitness_center;
  } else if (name.contains('squat') || name.contains('leg') || name.contains('calf')) {
    return Icons.directions_run;
  } else if (name.contains('pull') || name.contains('row') || name.contains('back')) {
    return Icons.airline_seat_recline_extra;
  } else if (name.contains('curl') || name.contains('tricep') || name.contains('arm')) {
    return Icons.sports_mma;
  } else if (name.contains('press') || name.contains('shoulder') || name.contains('delt')) {
    return Icons.sports_gymnastics;
  } else if (name.contains('run') || name.contains('bike') || name.contains('cardio') || name.contains('treadmill')) {
    return Icons.directions_bike;
  } else if (name.contains('crunch') || name.contains('plank') || name.contains('core') || name.contains('abs')) {
    return Icons.accessibility_new;
  }
  return Icons.fitness_center;
}
