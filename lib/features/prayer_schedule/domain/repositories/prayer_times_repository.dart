abstract class PrayerTimesRepository {
  Future<void> cacheSchedule(String dateKey, Map<String, DateTime> times);
  Future<Map<String, DateTime>?> getCachedSchedule(String dateKey);
}
