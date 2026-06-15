class PrayerTimesStateEntity {
  const PrayerTimesStateEntity({
    required this.todayTimes,
    required this.tomorrowTimes,
    this.isOfflineCached = false,
  });

  final Map<String, DateTime> todayTimes;
  final Map<String, DateTime> tomorrowTimes;
  final bool isOfflineCached;

  PrayerTimesStateEntity copyWith({
    Map<String, DateTime>? todayTimes,
    Map<String, DateTime>? tomorrowTimes,
    bool? isOfflineCached,
  }) {
    return PrayerTimesStateEntity(
      todayTimes: todayTimes ?? this.todayTimes,
      tomorrowTimes: tomorrowTimes ?? this.tomorrowTimes,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
    );
  }
}
