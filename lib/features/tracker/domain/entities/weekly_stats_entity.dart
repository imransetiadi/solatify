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
}
