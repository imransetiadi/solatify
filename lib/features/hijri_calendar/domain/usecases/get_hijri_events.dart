import '../entities/hijri_event.dart';
import '../repositories/hijri_calendar_repository.dart';

class GetHijriEvents {
  const GetHijriEvents(this.repository);

  final HijriCalendarRepository repository;

  Future<List<HijriEvent>> execute() async {
    return repository.getHijriEvents();
  }
}
