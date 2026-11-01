import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_ai_ui/features/ai_labs/data/training_analysis_dtos.dart';

void main() {
  group('TrainingAnalysisResponse DTO parsing', () {
    test('Parses complete valid json', () {
      final json = {
        "period_days": 365,
        "generated_at": "2023-10-27T10:00:00Z",
        "sessions_analyzed": 10,
        "truncated": false,
        "total_volume_kg_reps": 15000.5,
        "total_reps": 500,
        "sessions": [
          {
            "id": "s1",
            "started_at": "2023-10-26T10:00:00Z",
            "exercise_count": 2,
            "volume_kg_reps": 1000.0,
            "total_reps": 20,
            "entries": [
              {
                "exercise": "Bench Press",
                "sets": [
                  {
                    "set_number": 1,
                    "reps": 10,
                    "weight_kg": 100.0,
                    "rpe": 8.0,
                    "volume_kg_reps": 1000.0,
                    "estimated_1rm_kg": 133.0
                  }
                ]
              }
            ]
          }
        ],
        "exercise_progress": [
          {
            "exercise": "Bench Press",
            "trend": "up",
            "workout_count": 5,
            "latest_estimated_1rm_kg": 133.0,
            "best_estimated_1rm_kg": 135.0,
            "estimated_1rm_change_percent": 5.5,
            "volume_change_percent": 10.0,
            "recommendation": "Keep it up"
          }
        ],
        "general_recommendations": [
          "Rest more"
        ]
      };

      final response = TrainingAnalysisResponse.fromJson(json);
      
      expect(response.periodDays, 365);
      expect(response.truncated, false);
      expect(response.sessionsAnalyzed, 10);
      expect(response.totalVolumeKgReps, 15000.5);
      expect(response.totalReps, 500);
      
      expect(response.sessions.length, 1);
      expect(response.sessions.first.entries.first.sets.first.weightKg, 100.0);
      
      expect(response.exerciseProgress.length, 1);
      expect(response.exerciseProgress.first.trend, 'up');
      expect(response.exerciseProgress.first.estimated1rmChangePercent, 5.5);
      
      expect(response.generalRecommendations.first, "Rest more");
    });

    test('Parses empty history with nullable trend changes', () {
      final json = {
        "period_days": 365,
        "generated_at": "2023-10-27T10:00:00Z",
        "sessions_analyzed": 0,
        "truncated": false,
        "total_volume_kg_reps": 0.0,
        "total_reps": 0,
        "sessions": [],
        "exercise_progress": [
          {
            "exercise": "Squat",
            "trend": "flat",
            "workout_count": 1,
            "latest_estimated_1rm_kg": 100.0,
            "best_estimated_1rm_kg": 100.0,
            "estimated_1rm_change_percent": null,
            "volume_change_percent": null,
            "recommendation": "Need more data"
          }
        ],
        "general_recommendations": []
      };

      final response = TrainingAnalysisResponse.fromJson(json);
      
      expect(response.sessionsAnalyzed, 0);
      expect(response.sessions, isEmpty);
      expect(response.exerciseProgress.first.estimated1rmChangePercent, isNull);
      expect(response.exerciseProgress.first.volumeChangePercent, isNull);
    });

    test('Parses truncated response correctly', () {
       final json = {
        "period_days": 365,
        "generated_at": "2023-10-27T10:00:00Z",
        "sessions_analyzed": 200,
        "truncated": true,
        "total_volume_kg_reps": 50000.0,
        "total_reps": 5000,
        "sessions": [],
        "exercise_progress": [],
        "general_recommendations": []
      };

      final response = TrainingAnalysisResponse.fromJson(json);
      expect(response.truncated, true);
      expect(response.sessionsAnalyzed, 200);
    });
  });
}
