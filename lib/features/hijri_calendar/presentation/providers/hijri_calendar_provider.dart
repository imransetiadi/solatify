import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/hijri_calendar/data/datasources/hijri_calendar_local_data_source.dart';
import 'package:solatify/features/hijri_calendar/data/repositories/hijri_calendar_repository_impl.dart';
import 'package:solatify/features/hijri_calendar/domain/entities/hijri_event.dart';
import 'package:solatify/features/hijri_calendar/domain/repositories/hijri_calendar_repository.dart';
import 'package:solatify/features/hijri_calendar/domain/usecases/get_hijri_events.dart';

// Data Source Provider
final hijriCalendarLocalDataSourceProvider = Provider<HijriCalendarLocalDataSource>((ref) {
  return const HijriCalendarLocalDataSourceImpl();
});

// Repository Provider
final hijriCalendarRepositoryProvider = Provider<HijriCalendarRepository>((ref) {
  final localDataSource = ref.watch(hijriCalendarLocalDataSourceProvider);
  return HijriCalendarRepositoryImpl(localDataSource: localDataSource);
});

// UseCase Provider
final getHijriEventsUseCaseProvider = Provider<GetHijriEvents>((ref) {
  final repository = ref.watch(hijriCalendarRepositoryProvider);
  return GetHijriEvents(repository);
});

// Presentation State Provider (Asynchronously fetch Events)
final hijriEventsProvider = FutureProvider<List<HijriEvent>>((ref) async {
  final getHijriEvents = ref.watch(getHijriEventsUseCaseProvider);
  return getHijriEvents.execute();
});

// Derived Provider for upcoming events
final upcomingHijriEventsProvider = FutureProvider<List<HijriEvent>>((ref) async {
  final now = DateTime.now();
  final events = await ref.watch(hijriEventsProvider.future);
  
  final upcomingEvents = events.where((event) => event.gregorianDate.isAfter(now)).toList()
    ..sort((a, b) => a.gregorianDate.compareTo(b.gregorianDate));
    
  return upcomingEvents;
});
