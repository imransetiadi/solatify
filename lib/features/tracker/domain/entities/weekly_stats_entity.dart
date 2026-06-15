class WeeklyStatsEntity {
  const WeeklyStatsEntity({
    required this.completionRates, // e.g. {'subuh': 85.0, ...}
    required this.totalDone,
  });

  final Map<String, double> completionRates;
  final int totalDone;
}
