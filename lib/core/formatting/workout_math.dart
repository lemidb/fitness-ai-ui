double setVolume({required int reps, required double weightKg}) =>
    reps * weightKg;

double epley1Rm({required int reps, required double weightKg}) {
  if (reps <= 0) return weightKg;
  return weightKg * (1 + (reps / 30.0));
}

double entryVolume(Iterable<({int reps, double weightKg})> sets) {
  return sets.fold<double>(
    0,
    (sum, set) => sum + setVolume(reps: set.reps, weightKg: set.weightKg),
  );
}

double entryEstimated1Rm(Iterable<({int reps, double weightKg})> sets) {
  var maxRm = 0.0;
  for (final set in sets) {
    final rm = epley1Rm(reps: set.reps, weightKg: set.weightKg);
    if (rm > maxRm) maxRm = rm;
  }
  return maxRm;
}
