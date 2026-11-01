import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ai_labs_repository.dart';
import '../data/training_analysis_dtos.dart';

final trainingAnalysisDaysProvider = StateProvider<int>((ref) => 365);

final trainingAnalysisProvider = FutureProvider<TrainingAnalysisResponse>((ref) async {
  final repo = ref.watch(aiLabsRepositoryProvider);
  final days = ref.watch(trainingAnalysisDaysProvider);
  return repo.getTrainingAnalysis(days: days);
});
