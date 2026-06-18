import '../entities/prayer_log_entity.dart';
import '../entities/weekly_stats_entity.dart';
import '../repositories/tracker_repository.dart';

class GetWeeklyStats {
  const GetWeeklyStats(this.repository);

  final TrackerRepository repository;

  Future<WeeklyStatsEntity> execute(DateTime endDate) async {
    final logs = await repository.getWeeklyLogs(endDate);

    final prayers = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
    final habitKeys = [
      'tahajud',
      'dhuha',
      'shalawat',
      'sedekah',
      'puasa_sunnah',
      'murojaah',
    ];
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

    final logsByDate = {for (final log in logs) _dateKey(log.date): log};
    final dailyTargetCount = prayers.length + habitKeys.length;
    final heatmap = List.generate(14, (index) {
      final date = _dateOnly(endDate.subtract(Duration(days: index)));
      final log = logsByDate[_dateKey(date)];
      final completedCount = log == null
          ? 0
          : prayers.where(log.isPrayerDone).length +
                habitKeys.where(log.isHabitDone).length;

      return TrackerHeatmapDayEntity(
        date: date,
        progress: dailyTargetCount == 0 ? 0 : completedCount / dailyTargetCount,
      );
    });

    return WeeklyStatsEntity(
      completionRates: rates,
      totalDone: totalDone,
      statusCounts: statusCounts,
      heatmap: heatmap,
    );
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) {
    final normalized = _dateOnly(date);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }
}
