import '../../domain/entities/hijri_event.dart';
import '../../domain/repositories/hijri_calendar_repository.dart';
import '../datasources/hijri_calendar_local_data_source.dart';

class HijriCalendarRepositoryImpl implements HijriCalendarRepository {
  const HijriCalendarRepositoryImpl({required this.localDataSource});

  final HijriCalendarLocalDataSource localDataSource;

  @override
  Future<List<HijriEvent>> getHijriEvents() async {
    return localDataSource.getHijriEvents();
  }
}
