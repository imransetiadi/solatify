import '../entities/prayer_log_entity.dart';

abstract class TrackerRepository {
  Future<PrayerLogEntity> getLogByDate(DateTime date);
  Future<void> updatePrayerStatus(DateTime date, String prayerKey, bool isDone);
  Future<void> updatePrayerStatusDetail(
    DateTime date,
    String prayerKey,
    PrayerStatus status,
  );
  Future<List<PrayerLogEntity>> getWeeklyLogs(DateTime endDate);
}
