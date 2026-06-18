import '../entities/prayer_log_entity.dart';
import '../entities/weekly_stats_entity.dart';
import '../repositories/tracker_repository.dart';

class GetWeeklyStats {
  const GetWeeklyStats(this.repository);

  final TrackerRepository repository;

  Future<WeeklyStatsEntity> execute(DateTime endDate) async {
    final logs = await repository.getWeeklyLogs(endDate);

    final prayers = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
    final rates = <String, double>{};
    final statusCounts = {for (final status in PrayerStatus.values) status: 0};
    int totalDone = 0;

    for (final prayer in prayers) {
      final doneCount = logs.where((log) => log.isPrayerDone(prayer)).length;
      rates[prayer] = logs.isEmpty ? 0.0 : (doneCount / logs.length) * 100;
      totalDone += doneCount;

      for (final log in logs.where((log) => log.isPrayerDone(prayer))) {
        final status = log.getPrayerStatus(prayer) ?? PrayerStatus.onTime;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
    }

    return WeeklyStatsEntity(
      completionRates: rates,
      totalDone: totalDone,
      statusCounts: statusCounts,
    );
  }
}
