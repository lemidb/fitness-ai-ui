import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/history.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/dio_client.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return HistoryRepository(dio);
});

class HistoryRepository {
  final Dio _dio;
  HistoryRepository(this._dio);

  Future<HistoryResponse> getHistory({
    int days = 90,
    String? exercise,
    String? muscleGroup,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'days': days,
      'limit': limit,
      'offset': offset,
    };
    if (exercise != null && exercise.isNotEmpty) queryParams['exercise'] = exercise;
    if (muscleGroup != null && muscleGroup.isNotEmpty) queryParams['muscle_group'] = muscleGroup;

    try {
      final response = await _dio.get('/api/v1/workout/history', queryParameters: queryParams);
      return HistoryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _dio.delete('/api/v1/workout/sessions/$sessionId');
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }

  Future<void> deleteEntry(int entryId) async {
    try {
      await _dio.delete('/api/v1/workout/entries/$entryId');
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
