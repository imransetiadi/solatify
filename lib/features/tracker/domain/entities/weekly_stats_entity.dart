import 'prayer_log_entity.dart';

class WeeklyStatsEntity {
  const WeeklyStatsEntity({
    required this.completionRates, // e.g. {'subuh': 85.0, ...}
    required this.totalDone,
    this.statusCounts = const {},
  });

  final Map<String, double> completionRates;
  final int totalDone;
  final Map<PrayerStatus, int> statusCounts;
}
