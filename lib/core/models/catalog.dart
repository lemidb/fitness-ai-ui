const muscleGroups = [
  'chest',
  'back',
  'legs',
  'shoulders',
  'arms',
  'core',
  'full_body',
];

const exerciseTypes = ['strength', 'cardio', 'flexibility', 'mixed'];

String labelForSlug(String value) {
  return value
      .split('_')
      .map((part) => part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
