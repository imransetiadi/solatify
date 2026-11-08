import 'prayer_log_entity.dart';

class TrackerHeatmapDayEntity {
  const TrackerHeatmapDayEntity({required this.date, required this.progress});

  final DateTime date;
  final double progress;
}

class WeeklyStatsEntity {
  const WeeklyStatsEntity({
    required this.completionRates, // e.g. {'subuh': 85.0, ...}
    required this.totalDone,
    this.statusCounts = const {},
    this.heatmap = const [],
    this.currentStreakDays = 0,
    this.bestDayLabel = 'Belum ada data',
    this.strongestItemLabel = 'Mulai hari ini',
    this.weakestItemLabel = 'Pilih satu ibadah',
    this.smartInsightMessage = 'Mulai dari satu checklist hari ini.',
    this.smartInsightAction = 'Pilih satu ibadah ringan untuk dijaga.',
    this.isEnglish = false,
  });

  final Map<String, double> completionRates;
  final int totalDone;
  final Map<PrayerStatus, int> statusCounts;
  final List<TrackerHeatmapDayEntity> heatmap;
  final int currentStreakDays;
  final String bestDayLabel;
  final String strongestItemLabel;
  final String weakestItemLabel;
  final String smartInsightMessage;
  final String smartInsightAction;

  /// Language the labels above were written in.
  final bool isEnglish;

  String get shareSummaryText {
    if (isEnglish) {
      return [
        'Weekly Worship Progress',
        'Prayers done: $totalDone',
        'Streak: $currentStreakDays days',
        'Best day: $bestDayLabel',
        'Strongest: $strongestItemLabel',
        'Needs focus: $weakestItemLabel',
        '',
        smartInsightMessage,
        smartInsightAction,
        '',
        'Made with Solatify',
      ].join('\n');
    }
    return [
      'Progress Ibadah Mingguan',
      'Total salat: $totalDone',
      'Streak: $currentStreakDays hari',
      'Hari terbaik: $bestDayLabel',
      'Terkuat: $strongestItemLabel',
      'Perlu fokus: $weakestItemLabel',
      '',
      smartInsightMessage,
      smartInsightAction,
      '',
      'Dibuat dengan Solatify',
    ].join('\n');
  }
}
