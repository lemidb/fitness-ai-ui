import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/models/exercise.dart';
import '../../../core/network/dio_client.dart';

import '../../../core/network/api_error_parser.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ExerciseRepository(dio);
});

class ExerciseRepository {
  final Dio _dio;
  ExerciseRepository(this._dio);

  Future<List<Exercise>> getExercises({String? search, String? muscleGroup}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (muscleGroup != null && muscleGroup.isNotEmpty) queryParams['muscle_group'] = muscleGroup;

    try {
      final response = await _dio.get('/api/v1/exercises', queryParameters: queryParams);
      if (response.data is List) {
        return (response.data as List).map((json) => Exercise.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<Exercise> createExercise(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/v1/exercises', data: data);
      return Exercise.fromJson(response.data);
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
