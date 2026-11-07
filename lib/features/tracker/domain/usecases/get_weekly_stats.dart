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

    final logsByDate = {for (final log in logs) _dateKey(log.date): log};

    // Weekly figures use the last 7 days. Days without a log count as not
    // done, so rates are no longer inflated (one logged day used to read as
    // 100%). The window starts at the first tracked day, so a new user is
    // not penalised for days before they started.
    final today = _dateOnly(endDate);
    final weekLogs = [
      for (var index = 0; index < 7; index++)
        logsByDate[_dateKey(today.subtract(Duration(days: index)))],
    ].whereType<PrayerLogEntity>().toList();
    final weekDays = weekLogs.isEmpty
        ? 0
        : today
                  .difference(
                    weekLogs
                        .map((log) => _dateOnly(log.date))
                        .reduce((a, b) => a.isBefore(b) ? a : b),
                  )
                  .inDays +
              1;

    for (final prayer in prayers) {
      final doneCount = weekLogs
          .where((log) => log.isPrayerDone(prayer))
          .length;
      rates[prayer] = weekDays == 0 ? 0.0 : (doneCount / weekDays) * 100;
      totalDone += doneCount;

      for (final log in weekLogs.where((log) => log.isPrayerDone(prayer))) {
        final status = log.getPrayerStatus(prayer) ?? PrayerStatus.onTime;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
    }
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

    final currentStreakDays = _calculateCurrentStreak(
      endDate,
      logsByDate,
      prayers,
      habitKeys,
    );
    final bestDayLabel = _bestDayLabel(endDate, weekLogs, prayers, habitKeys);
    final strongestPrayer = weekLogs.isEmpty
        ? 'Mulai hari ini'
        : _strongestPrayerLabel(rates);
    final weakestPrayer = weekLogs.isEmpty
        ? 'Pilih satu ibadah'
        : _weakestPrayerLabel(rates);
    final smartInsightMessage = weekLogs.isEmpty
        ? 'Mulai dari satu checklist hari ini untuk membangun ritme ibadah.'
        : currentStreakDays > 0
        ? 'MasyaAllah, kamu sedang menjaga streak $currentStreakDays hari.'
        : 'Belum ada streak aktif. Mulai lagi dari checklist hari ini.';
    final smartInsightAction = weekLogs.isEmpty
        ? 'Pilih satu ibadah ringan, lalu tandai setelah selesai.'
        : 'Fokus kecil berikutnya: kuatkan $weakestPrayer agar pekan ini lebih seimbang.';

    return WeeklyStatsEntity(
      completionRates: rates,
      totalDone: totalDone,
      statusCounts: statusCounts,
      heatmap: heatmap,
      currentStreakDays: currentStreakDays,
      bestDayLabel: bestDayLabel,
      strongestItemLabel: strongestPrayer,
      weakestItemLabel: weakestPrayer,
      smartInsightMessage: smartInsightMessage,
      smartInsightAction: smartInsightAction,
    );
  }

  int _calculateCurrentStreak(
    DateTime endDate,
    Map<String, PrayerLogEntity> logsByDate,
    List<String> prayers,
    List<String> habitKeys,
  ) {
    bool isComplete(int daysAgo) {
      final date = _dateOnly(endDate.subtract(Duration(days: daysAgo)));
      final log = logsByDate[_dateKey(date)];
      return log != null && _completedCount(log, prayers, habitKeys) >= 3;
    }

    // Today still counts as "in progress": until it is complete, the streak
    // is counted from yesterday instead of dropping to 0 every morning.
    final start = isComplete(0) ? 0 : 1;
    var streak = 0;
    for (var index = start; index < 14; index++) {
      if (!isComplete(index)) break;
      streak++;
    }
    return streak;
  }

  String _bestDayLabel(
    DateTime endDate,
    List<PrayerLogEntity> logs,
    List<String> prayers,
    List<String> habitKeys,
  ) {
    if (logs.isEmpty) return 'Belum ada data';

    PrayerLogEntity? bestLog;
    var bestCount = -1;
    for (final log in logs) {
      final completedCount = _completedCount(log, prayers, habitKeys);
      if (completedCount > bestCount) {
        bestLog = log;
        bestCount = completedCount;
      }
    }
    if (bestLog == null) return 'Belum ada data';

    final bestDate = _dateOnly(bestLog.date);
    final today = _dateOnly(endDate);
    final yesterday = today.subtract(const Duration(days: 1));
    if (bestDate == today) return 'Hari ini';
    if (bestDate == yesterday) return 'Kemarin';
    return '${bestDate.day}/${bestDate.month}/${bestDate.year}';
  }

  String _strongestPrayerLabel(Map<String, double> rates) {
    if (rates.isEmpty) return 'Mulai hari ini';

    var selectedKey = rates.keys.first;
    var selectedRate = rates[selectedKey] ?? 0;
    for (final entry in rates.entries) {
      if (entry.value > selectedRate) {
        selectedKey = entry.key;
        selectedRate = entry.value;
      }
    }
    return _prayerLabel(selectedKey);
  }

  String _weakestPrayerLabel(Map<String, double> rates) {
    if (rates.isEmpty) return 'Pilih satu ibadah';

    var selectedKey = rates.keys.first;
    var selectedRate = rates[selectedKey] ?? 0;
    for (final entry in rates.entries) {
      if (entry.value <= selectedRate) {
        selectedKey = entry.key;
        selectedRate = entry.value;
      }
    }
    return _prayerLabel(selectedKey);
  }

  int _completedCount(
    PrayerLogEntity log,
    List<String> prayers,
    List<String> habitKeys,
  ) {
    return prayers.where(log.isPrayerDone).length +
        habitKeys.where(log.isHabitDone).length;
  }

  String _prayerLabel(String key) {
    return switch (key) {
      'subuh' => 'Subuh',
      'dzuhur' => 'Dzuhur',
      'ashar' => 'Ashar',
      'magrib' => 'Magrib',
      'isya' => 'Isya',
      _ => key,
    };
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) {
    final normalized = _dateOnly(date);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }
}
