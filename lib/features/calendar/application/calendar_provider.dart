import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/calendar_repository.dart';

final calendarDaysAheadProvider = StateProvider<int>((ref) => 7);

final calendarEventsProvider = FutureProvider<List<CalendarEvent>>((ref) async {
  final repo = ref.watch(calendarRepositoryProvider);
  final daysAhead = ref.watch(calendarDaysAheadProvider);
  return repo.getEvents(daysAhead: daysAhead);
});
