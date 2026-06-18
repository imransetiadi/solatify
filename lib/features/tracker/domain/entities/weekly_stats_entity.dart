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
  });

  final Map<String, double> completionRates;
  final int totalDone;
  final Map<PrayerStatus, int> statusCounts;
  final List<TrackerHeatmapDayEntity> heatmap;
}
