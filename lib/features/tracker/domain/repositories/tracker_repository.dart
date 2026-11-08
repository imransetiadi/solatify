import '../entities/prayer_log_entity.dart';

abstract class TrackerRepository {
  Future<PrayerLogEntity> getLogByDate(DateTime date);
  Future<void> updatePrayerStatus(DateTime date, String prayerKey, bool isDone);
  Future<void> updatePrayerStatusDetail(
    DateTime date,
    String prayerKey,
    PrayerStatus status,
  );
  Future<void> updateHabitStatus(DateTime date, String habitKey, bool isDone);
  Future<void> updateHabitProgress(
    DateTime date,
    String habitKey,
    int progress, {
    int? target,
  });
  Future<List<PrayerLogEntity>> getWeeklyLogs(DateTime endDate);

  /// Logs for [days] calendar days ending at [endDate] (missing days are
  /// skipped). Used for the streak, which can be longer than two weeks.
  Future<List<PrayerLogEntity>> getLogsBack(DateTime endDate, int days);

  Future<void> renameHabitKey(String oldKey, String newKey);
}
