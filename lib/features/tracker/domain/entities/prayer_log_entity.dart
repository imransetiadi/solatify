class PrayerLogEntity {
  const PrayerLogEntity({
    required this.date,
    required this.prayers,
  });

  final DateTime date;
  final Map<String, bool> prayers;

  PrayerLogEntity copyWith({
    DateTime? date,
    Map<String, bool>? prayers,
  }) {
    return PrayerLogEntity(
      date: date ?? this.date,
      prayers: prayers ?? Map<String, bool>.from(this.prayers),
    );
  }

  bool isPrayerDone(String prayerKey) => prayers[prayerKey] ?? false;
}
