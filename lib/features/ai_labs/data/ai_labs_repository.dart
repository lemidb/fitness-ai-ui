import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import 'training_analysis_dtos.dart';

class AiLabsRepository {
  final ref;
  AiLabsRepository(this.ref);

  Future<dynamic> getInsights(String exerciseId) async {
    final api = ref.read(fitnessApiProvider);
    return await api.getAiInsights(exerciseId);
  }

  Future<TrainingAnalysisResponse> getTrainingAnalysis({int days = 365}) async {
    final api = ref.read(fitnessApiProvider);
    return await api.getTrainingAnalysis(days: days);
  }

  Future<dynamic> analyzeForm(String exercise, {String? videoUrl, String? filePath}) async {
    final api = ref.read(fitnessApiProvider);
    return await api.analyzeForm(exercise, videoUrl: videoUrl, filePath: filePath);
  }
}

final aiLabsRepositoryProvider = Provider((ref) => AiLabsRepository(ref));
