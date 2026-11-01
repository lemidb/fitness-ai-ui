import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class CalendarEvent {
  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String? location;
  final String type;
  final int? estimatedDurationMin;
  final dynamic aiInsights;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.location,
    required this.type,
    this.estimatedDurationMin,
    this.aiInsights,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Workout',
      startAt: DateTime.tryParse(json['start_at'] as String? ?? '') ?? DateTime.now(),
      endAt: DateTime.tryParse(json['end_at'] as String? ?? '') ?? DateTime.now(),
      location: json['location'] as String?,
      type: json['type'] as String? ?? 'workout',
      estimatedDurationMin: json['estimated_duration_min'] as int?,
      aiInsights: json['ai_insights'],
    );
  }
}

class CalendarRepository {
  final ref;
  CalendarRepository(this.ref);

  Future<List<CalendarEvent>> getEvents({int daysAhead = 7}) async {
    final api = ref.read(fitnessApiProvider);
    final data = await api.getCalendarEvents(daysAhead: daysAhead);
    return data.map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createEvent(Map<String, dynamic> event) async {
    final api = ref.read(fitnessApiProvider);
    await api.createCalendarEvent(event);
  }

  Future<void> syncGoogleCalendar(String accessToken) async {
    final api = ref.read(fitnessApiProvider);
    await api.syncGoogleCalendar(accessToken);
  }
}

final calendarRepositoryProvider = Provider((ref) => CalendarRepository(ref));
