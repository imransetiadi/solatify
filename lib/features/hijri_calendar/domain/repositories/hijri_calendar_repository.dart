import '../entities/hijri_event.dart';

abstract class HijriCalendarRepository {
  Future<List<HijriEvent>> getHijriEvents();
}
