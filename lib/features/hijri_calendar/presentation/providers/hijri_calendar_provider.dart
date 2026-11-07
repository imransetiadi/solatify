import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/hijri_calendar/data/datasources/hijri_calendar_local_data_source.dart';
import 'package:solatify/features/hijri_calendar/data/repositories/hijri_calendar_repository_impl.dart';
import 'package:solatify/features/hijri_calendar/domain/entities/hijri_event.dart';
import 'package:solatify/features/hijri_calendar/domain/repositories/hijri_calendar_repository.dart';
import 'package:solatify/features/hijri_calendar/domain/usecases/get_hijri_events.dart';

// Data Source Provider
final hijriCalendarLocalDataSourceProvider =
    Provider<HijriCalendarLocalDataSource>((ref) {
      return const HijriCalendarLocalDataSourceImpl();
    });

// Repository Provider
final hijriCalendarRepositoryProvider = Provider<HijriCalendarRepository>((
  ref,
) {
  final localDataSource = ref.watch(hijriCalendarLocalDataSourceProvider);
  return HijriCalendarRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Provider
final getHijriEventsUseCaseProvider = Provider<GetHijriEvents>((ref) {
  final repository = ref.watch(hijriCalendarRepositoryProvider);
  return GetHijriEvents(repository);
});

// Presentation State Provider (Asynchronously fetch Events).
// Auto-disposed so "today" is re-evaluated whenever the screen is reopened,
// instead of being frozen at the first load.
final hijriEventsProvider = FutureProvider.autoDispose<List<HijriEvent>>((
  ref,
) async {
  final getHijriEvents = ref.watch(getHijriEventsUseCaseProvider);
  return getHijriEvents.execute();
});

// Derived Provider for upcoming events (today's events included).
final upcomingHijriEventsProvider =
    FutureProvider.autoDispose<List<HijriEvent>>((ref) async {
      final events = await ref.watch(hijriEventsProvider.future);
      return upcomingHijriEvents(events, DateTime.now());
    });

/// Events on or after [now]'s calendar day, soonest first. Compared by date
/// only, so an event stays listed for its whole day instead of disappearing
/// at 00:00.
List<HijriEvent> upcomingHijriEvents(List<HijriEvent> events, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return events.where((event) {
    final date = event.gregorianDate;
    return !DateTime(date.year, date.month, date.day).isBefore(today);
  }).toList()..sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
}
