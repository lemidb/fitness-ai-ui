import 'package:dio/dio.dart';

import '../../features/auth/data/auth_me.dart';
import '../../features/exercises/data/exercise.dart';
import '../../features/history/data/history_dtos.dart';
import '../../features/progress/data/progress_dtos.dart';
import '../../features/workout/data/workout_dtos.dart';
import '../../features/ai_labs/data/training_analysis_dtos.dart';
import '../auth/auth_repository.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'api_error_mapper.dart';

class FitnessApi {
  FitnessApi({
    required AppConfig config,
    required AuthRepository auth,
    Dio? dio,
    void Function()? onSessionExpired,
  }) : _auth = auth,
       _onSessionExpired = onSessionExpired,
       _dio = dio ?? Dio(BaseOptions(baseUrl: config.apiBaseUrl, connectTimeout: const Duration(seconds: 60), receiveTimeout: const Duration(seconds: 60))) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _auth.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && error.requestOptions.extra['retried'] != true) {
            final refreshed = await _auth.refreshSession();
            if (refreshed) {
              final retry = error.requestOptions;
              retry.extra['retried'] = true;
              final token = _auth.accessToken;
              if (token != null) {
                retry.headers['Authorization'] = 'Bearer $token';
              }
              try {
                final response = await _dio.fetch(retry);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
            _onSessionExpired?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final AuthRepository _auth;
  final void Function()? _onSessionExpired;

  Future<AuthMe> me() async {
    final data = await _get('/api/v1/auth/me');
    return AuthMe.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Exercise>> listExercises({
    String? search,
    String? muscleGroup,
    String? exerciseType,
    int limit = 50,
  }) async {
    final data = await _get(
      '/api/v1/exercises',
      query: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (muscleGroup != null && muscleGroup.isNotEmpty) 'muscle_group': muscleGroup,
        if (exerciseType != null && exerciseType.isNotEmpty) 'exercise_type': exerciseType,
        'limit': limit,
      },
    );
    return (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Exercise.fromJson)
        .toList();
  }

  Future<Exercise> getExercise(String id) async {
    final data = await _get('/api/v1/exercises/$id');
    return Exercise.fromJson(data as Map<String, dynamic>);
  }

  Future<Exercise> createExercise(Exercise draft) async {
    final data = await _post('/api/v1/exercises', draft.toCreateBody());
    return Exercise.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteExercise(String id) async {
    await _delete('/api/v1/exercises/$id');
  }

  Future<WorkoutLogResponse> logWorkout(WorkoutLogRequest request) async {
    final data = await _post('/api/v1/workout/log', request.toJson(), created: true);
    return WorkoutLogResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<HistoryPage> history({
    int days = 90,
    String? exercise,
    String? muscleGroup,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _get(
      '/api/v1/workout/history',
      query: {
        'days': days,
        if (exercise != null && exercise.isNotEmpty) 'exercise': exercise,
        if (muscleGroup != null && muscleGroup.isNotEmpty) 'muscle_group': muscleGroup,
        'limit': limit,
        'offset': offset,
      },
    );
    return HistoryPage.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteSession(String sessionId) async {
    await _delete('/api/v1/workout/sessions/$sessionId');
  }

  Future<void> deleteEntry(int entryId) async {
    await _delete('/api/v1/workout/entries/$entryId');
  }

  Future<ProgressReport> progress({required String exercise, int days = 365}) async {
    final encoded = Uri.encodeComponent(exercise);
    final data = await _get('/api/v1/workout/progress/$encoded', query: {'days': days});
    return ProgressReport.fromJson(data as Map<String, dynamic>);
  }

  // --- Phase 2: Calendar & AI Labs ---

  Future<List<dynamic>> getCalendarEvents({int daysAhead = 7, String? startAt, String? endAt}) async {
    final query = <String, dynamic>{'days_ahead': daysAhead};
    if (startAt != null) query['start_at'] = startAt;
    if (endAt != null) query['end_at'] = endAt;
    return await _get('/api/v1/calendar/events', query: query) as List<dynamic>;
  }

  Future<dynamic> createCalendarEvent(Map<String, dynamic> event) async {
    return await _post('/api/v1/calendar/events', event);
  }

  Future<void> syncGoogleCalendar(String accessToken, {String? refreshToken, int daysAhead = 7}) async {
    await _post('/api/v1/calendar/sync', {
      'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      'days_ahead': daysAhead,
    });
  }

  Future<dynamic> getAuthConnections() async {
    return await _get('/api/v1/auth/connections');
  }

  Future<dynamic> getAiInsights(String exerciseId) async {
    return await _get('/api/v1/ai/insights', query: {'exercise': exerciseId});
  }

  Future<TrainingAnalysisResponse> getTrainingAnalysis({int days = 365}) async {
    final data = await _get('/api/v1/ai/training-analysis', query: {'days': days, 'limit': 200});
    return TrainingAnalysisResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<dynamic> analyzeForm(String exercise, {String? videoUrl, String? filePath}) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('exercise', exercise));
      if (videoUrl != null && videoUrl.isNotEmpty) {
        formData.fields.add(MapEntry('video_url', videoUrl));
      } else if (filePath != null && filePath.isNotEmpty) {
        formData.files.add(MapEntry('video', await MultipartFile.fromFile(filePath)));
      }
      
      final response = await _dio.post<dynamic>('/api/v1/ai/analyze-form', data: formData);
      return response.data;
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return response.data;
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<dynamic> _post(String path, Object body, {bool created = false}) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return response.data;
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }

  Future<void> _delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (error) {
      throw mapDioError(error);
    }
  }
}

Never rethrowAsApp(Object error) {
  if (error is AppException) throw error;
  throw AppException(error.toString());
}
