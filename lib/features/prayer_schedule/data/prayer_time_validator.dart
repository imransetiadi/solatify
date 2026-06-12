class PrayerTimeValidator {
  /// Validates that prayer times are in correct chronological order
  static bool validatePrayerTimeOrder(Map<String, DateTime> prayers) {
    if (prayers.length != 5) return false;

    const order = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];

    for (int i = 0; i < order.length - 1; i++) {
      final current = prayers[order[i]];
      final next = prayers[order[i + 1]];

      if (current == null || next == null) return false;

      // Each prayer should be at least 30 minutes before next prayer
      if (current.difference(next).inMinutes >= -30) {
        return false;
      }
    }

    return true;
  }

  /// Ensures prayer times are in local timezone
  static Map<String, DateTime> ensureLocalTimezone(
    Map<String, DateTime> prayers,
  ) {
    final result = <String, DateTime>{};

    for (final entry in prayers.entries) {
      final time = entry.value;

      // Ensure the time is in local timezone
      if (time.timeZoneOffset == Duration.zero) {
        // UTC time, convert to local
        result[entry.key] = time.toLocal();
      } else {
        result[entry.key] = time;
      }
    }

    return result;
  }

  /// Validates a single prayer time is reasonable
  static bool isReasonablePrayerTime(DateTime time) {
    // Prayer time should be within today (same date)
    final now = DateTime.now();

    return time.year == now.year &&
        time.month == now.month &&
        time.day == now.day;
  }

  /// Compares two prayer times considering timezone
  static int comparePrayerTimes(DateTime time1, DateTime time2) {
    final t1 = time1.toLocal();
    final t2 = time2.toLocal();

    return t1.compareTo(t2);
  }

  /// Calculates time until a specific prayer time
  static Duration timeUntilPrayer(DateTime prayerTime) {
    final now = DateTime.now();
    return prayerTime.difference(now);
  }

  /// Determines if we're currently within a prayer window (10 minutes before)
  static bool isWithinPrayerWindow(
    DateTime prayerTime, {
    int minutesBefore = 10,
  }) {
    final now = DateTime.now();
    final windowStart = prayerTime.subtract(Duration(minutes: minutesBefore));

    return now.isAfter(windowStart) && now.isBefore(prayerTime);
  }

  /// Determines if a prayer time has passed
  static bool hasPrayerPassed(DateTime prayerTime) {
    return DateTime.now().isAfter(prayerTime.add(const Duration(minutes: 1)));
  }
}
