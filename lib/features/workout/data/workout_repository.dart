import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/models/workout.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_error_parser.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return WorkoutRepository(dio);
});

class WorkoutRepository {
  final Dio _dio;
  WorkoutRepository(this._dio);

  Future<void> logWorkout(WorkoutPayload payload) async {
    try {
      await _dio.post('/api/v1/workout/log', data: payload.toJson());
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
