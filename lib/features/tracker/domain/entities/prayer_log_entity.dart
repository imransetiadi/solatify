enum PrayerStatus {
  onTime('tepat waktu'),
  late('terlambat'),
  qadha('qadha');

  const PrayerStatus(this.label);

  final String label;

  static PrayerStatus? fromName(String? value) {
    if (value == null) return null;
    for (final status in PrayerStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }
}

class PrayerLogEntity {
  const PrayerLogEntity({
    required this.date,
    required this.prayers,
    this.prayerStatuses = const {},
  });

  final DateTime date;
  final Map<String, bool> prayers;
  final Map<String, PrayerStatus> prayerStatuses;

  PrayerLogEntity copyWith({
    DateTime? date,
    Map<String, bool>? prayers,
    Map<String, PrayerStatus>? prayerStatuses,
  }) {
    return PrayerLogEntity(
      date: date ?? this.date,
      prayers: prayers ?? Map<String, bool>.from(this.prayers),
      prayerStatuses:
          prayerStatuses ?? Map<String, PrayerStatus>.from(this.prayerStatuses),
    );
  }

  bool isPrayerDone(String prayerKey) => prayers[prayerKey] ?? false;

  PrayerStatus? getPrayerStatus(String prayerKey) {
    if (!isPrayerDone(prayerKey)) return null;
    return prayerStatuses[prayerKey] ?? PrayerStatus.onTime;
  }

  PrayerLogEntity copyWithStatus(String prayerKey, PrayerStatus? status) {
    final updatedPrayers = Map<String, bool>.from(prayers);
    final updatedStatuses = Map<String, PrayerStatus>.from(prayerStatuses);

    if (status == null) {
      updatedPrayers[prayerKey] = false;
      updatedStatuses.remove(prayerKey);
    } else {
      updatedPrayers[prayerKey] = true;
      updatedStatuses[prayerKey] = status;
    }

    return copyWith(prayers: updatedPrayers, prayerStatuses: updatedStatuses);
  }
}
