import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress.dart';
import '../../../core/network/api_error_parser.dart';
import '../../../core/network/dio_client.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return ProgressRepository(dio);
});

class ProgressRepository {
  final Dio _dio;
  ProgressRepository(this._dio);

  Future<ProgressData> getProgress(String exercise, int days) async {
    try {
      final response = await _dio.get('/api/v1/workout/progress/$exercise', queryParameters: {'days': days});
      return ProgressData.fromJson(response.data);
    } catch (e) {
      throw Exception(parseApiError(e));
    }
  }
}
