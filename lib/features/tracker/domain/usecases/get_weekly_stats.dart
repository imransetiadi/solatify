import '../entities/prayer_log_entity.dart';
import '../entities/weekly_stats_entity.dart';
import '../repositories/tracker_repository.dart';

class GetWeeklyStats {
  const GetWeeklyStats(this.repository);

  final TrackerRepository repository;

  /// Insight and label text is built in the user's language ([isEnglish]).
  Future<WeeklyStatsEntity> execute(
    DateTime endDate, {
    bool isEnglish = false,
  }) async {
    final logs = await repository.getWeeklyLogs(endDate);
    // The streak can be longer than the two weeks above.
    final streakLogs = await repository.getLogsBack(endDate, _maxStreakDays);
    String t(String id, String en) => isEnglish ? en : id;

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
        logsByDate[_dateKey(_daysBefore(today, index))],
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
      final date = _daysBefore(endDate, index);
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
      {for (final log in streakLogs) _dateKey(log.date): log},
      prayers,
      habitKeys,
    );
    final bestDayLabel = _bestDayLabel(
      endDate,
      weekLogs,
      prayers,
      habitKeys,
      isEnglish,
    );
    final strongestPrayer = weekLogs.isEmpty
        ? t('Mulai hari ini', 'Start today')
        : _strongestPrayerLabel(rates, isEnglish);
    final weakestPrayer = weekLogs.isEmpty
        ? t('Pilih satu ibadah', 'Pick one practice')
        : _weakestPrayerLabel(rates, isEnglish);
    final smartInsightMessage = weekLogs.isEmpty
        ? t(
            'Mulai dari satu checklist hari ini untuk membangun ritme ibadah.',
            'Start with one checklist item today to build a rhythm of worship.',
          )
        : currentStreakDays > 0
        ? t(
            'MasyaAllah, kamu sedang menjaga streak $currentStreakDays hari.',
            'MashaAllah, you are keeping a $currentStreakDays-day streak.',
          )
        : t(
            'Belum ada streak aktif. Mulai lagi dari checklist hari ini.',
            'No active streak yet. Start again with today\'s checklist.',
          );
    final smartInsightAction = weekLogs.isEmpty
        ? t(
            'Pilih satu ibadah ringan, lalu tandai setelah selesai.',
            'Pick one light practice and tick it once it is done.',
          )
        : t(
            'Fokus kecil berikutnya: kuatkan $weakestPrayer agar pekan ini lebih seimbang.',
            'Next small focus: strengthen $weakestPrayer for a more balanced week.',
          );

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
      isEnglish: isEnglish,
    );
  }

  /// How far back the streak is counted.
  static const _maxStreakDays = 366;

  int _calculateCurrentStreak(
    DateTime endDate,
    Map<String, PrayerLogEntity> logsByDate,
    List<String> prayers,
    List<String> habitKeys,
  ) {
    bool isComplete(int daysAgo) {
      final date = _daysBefore(endDate, daysAgo);
      final log = logsByDate[_dateKey(date)];
      return log != null && _completedCount(log, prayers, habitKeys) >= 3;
    }

    // Today still counts as "in progress": until it is complete, the streak
    // is counted from yesterday instead of dropping to 0 every morning.
    final start = isComplete(0) ? 0 : 1;
    var streak = 0;
    for (var index = start; index < _maxStreakDays; index++) {
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
    bool isEnglish,
  ) {
    final noData = isEnglish ? 'No data yet' : 'Belum ada data';
    if (logs.isEmpty) return noData;

    PrayerLogEntity? bestLog;
    var bestCount = -1;
    for (final log in logs) {
      final completedCount = _completedCount(log, prayers, habitKeys);
      if (completedCount > bestCount) {
        bestLog = log;
        bestCount = completedCount;
      }
    }
    if (bestLog == null) return noData;

    final bestDate = _dateOnly(bestLog.date);
    final today = _dateOnly(endDate);
    final yesterday = _daysBefore(today, 1);
    if (bestDate == today) return isEnglish ? 'Today' : 'Hari ini';
    if (bestDate == yesterday) return isEnglish ? 'Yesterday' : 'Kemarin';
    return '${bestDate.day}/${bestDate.month}/${bestDate.year}';
  }

  String _strongestPrayerLabel(Map<String, double> rates, bool isEnglish) {
    if (rates.isEmpty) return isEnglish ? 'Start today' : 'Mulai hari ini';

    var selectedKey = rates.keys.first;
    var selectedRate = rates[selectedKey] ?? 0;
    for (final entry in rates.entries) {
      if (entry.value > selectedRate) {
        selectedKey = entry.key;
        selectedRate = entry.value;
      }
    }
    return _prayerLabel(selectedKey, isEnglish);
  }

  String _weakestPrayerLabel(Map<String, double> rates, bool isEnglish) {
    if (rates.isEmpty)
      return isEnglish ? 'Pick one practice' : 'Pilih satu ibadah';

    var selectedKey = rates.keys.first;
    var selectedRate = rates[selectedKey] ?? 0;
    for (final entry in rates.entries) {
      if (entry.value <= selectedRate) {
        selectedKey = entry.key;
        selectedRate = entry.value;
      }
    }
    return _prayerLabel(selectedKey, isEnglish);
  }

  int _completedCount(
    PrayerLogEntity log,
    List<String> prayers,
    List<String> habitKeys,
  ) {
    return prayers.where(log.isPrayerDone).length +
        habitKeys.where(log.isHabitDone).length;
  }

  String _prayerLabel(String key, bool isEnglish) {
    return switch (key) {
      'subuh' => isEnglish ? 'Fajr' : 'Subuh',
      'dzuhur' => isEnglish ? 'Dhuhr' : 'Dzuhur',
      'ashar' => isEnglish ? 'Asr' : 'Ashar',
      'magrib' => isEnglish ? 'Maghrib' : 'Magrib',
      'isya' => isEnglish ? 'Isha' : 'Isya',
      _ => key,
    };
  }

  /// [days] calendar days before [date] (DST-safe, unlike subtracting 24 h).
  DateTime _daysBefore(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day - days);

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _dateKey(DateTime date) {
    final normalized = _dateOnly(date);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }
}
