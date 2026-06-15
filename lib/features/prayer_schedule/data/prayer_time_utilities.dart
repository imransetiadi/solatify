class PrayerTimeUtilities {
  /// Standard prayer names mapping
  static const Map<String, String> prayerLabels = {
    'subuh': 'Subuh',
    'dzuhur': 'Dzuhur',
    'ashar': 'Ashar',
    'magrib': 'Magrib',
    'isya': 'Isya',
  };

  /// Get formatted prayer label
  static String getLabel(String key) {
    return prayerLabels[key] ?? '-';
  }

  /// Format time for display (HH:mm)
  static String formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  /// Format duration for countdown (HH:mm:ss)
  static String formatCountdown(Duration duration) {
    if (duration.isNegative) return '00:00:00';

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  /// Get prayer display name for current period
  static String getCurrentPrayerName(
    DateTime now,
    Map<String, DateTime> prayers,
  ) {
    if (now.isBefore(prayers['subuh']!)) {
      return 'Isya';
    } else if (now.isBefore(prayers['dzuhur']!)) {
      return 'Subuh';
    } else if (now.isBefore(prayers['ashar']!)) {
      return 'Dzuhur';
    } else if (now.isBefore(prayers['magrib']!)) {
      return 'Ashar';
    } else if (now.isBefore(prayers['isya']!)) {
      return 'Magrib';
    } else {
      return 'Isya';
    }
  }

  /// Get next prayer name
  static String getNextPrayerName(DateTime now, Map<String, DateTime> prayers) {
    if (now.isBefore(prayers['subuh']!)) {
      return 'Subuh';
    } else if (now.isBefore(prayers['dzuhur']!)) {
      return 'Dzuhur';
    } else if (now.isBefore(prayers['ashar']!)) {
      return 'Ashar';
    } else if (now.isBefore(prayers['magrib']!)) {
      return 'Magrib';
    } else if (now.isBefore(prayers['isya']!)) {
      return 'Isya';
    } else {
      return 'Subuh';
    }
  }

  /// Get all prayers in order
  static const List<String> prayerOrder = [
    'subuh',
    'dzuhur',
    'ashar',
    'magrib',
    'isya',
  ];

  /// Calculate progress percentage through the day (0-100)
  static double calculateDayProgress(
    DateTime now,
    DateTime firstPrayer,
    DateTime lastPrayer,
  ) {
    if (now.isBefore(firstPrayer)) return 0.0;
    if (now.isAfter(lastPrayer)) return 100.0;

    final totalSeconds = lastPrayer.difference(firstPrayer).inSeconds;
    final elapsedSeconds = now.difference(firstPrayer).inSeconds;

    return (elapsedSeconds / totalSeconds) * 100;
  }
}
