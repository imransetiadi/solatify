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
    this.habits = const {},
    this.habitProgress = const {},
  });

  final DateTime date;
  final Map<String, bool> prayers;
  final Map<String, PrayerStatus> prayerStatuses;
  final Map<String, bool> habits;
  final Map<String, int> habitProgress;

  PrayerLogEntity copyWith({
    DateTime? date,
    Map<String, bool>? prayers,
    Map<String, PrayerStatus>? prayerStatuses,
    Map<String, bool>? habits,
    Map<String, int>? habitProgress,
  }) {
    return PrayerLogEntity(
      date: date ?? this.date,
      prayers: prayers ?? Map<String, bool>.from(this.prayers),
      prayerStatuses:
          prayerStatuses ?? Map<String, PrayerStatus>.from(this.prayerStatuses),
      habits: habits ?? Map<String, bool>.from(this.habits),
      habitProgress: habitProgress ?? Map<String, int>.from(this.habitProgress),
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

  bool isHabitDone(String habitKey) => habits[habitKey] ?? false;

  PrayerLogEntity copyWithHabit(String habitKey, bool isDone) {
    final updatedHabits = Map<String, bool>.from(habits);
    updatedHabits[habitKey] = isDone;
    return copyWith(habits: updatedHabits);
  }

  int getHabitProgress(String habitKey) => habitProgress[habitKey] ?? 0;

  PrayerLogEntity copyWithHabitProgress(String habitKey, int progress) {
    final updatedProgress = Map<String, int>.from(habitProgress);
    updatedProgress[habitKey] = progress < 0 ? 0 : progress;

    final updatedHabits = Map<String, bool>.from(habits);
    updatedHabits[habitKey] = (updatedProgress[habitKey] ?? 0) > 0;

    return copyWith(habits: updatedHabits, habitProgress: updatedProgress);
  }
}
