/// Manual prayer time corrections, in whole minutes per prayer.
///
/// A correction moves a prayer away from the method's standard time (which
/// already includes the method's ihtiyat), typically to match the adhan of
/// a local mosque. See docs/prayer-time-corrections.md.
library;

/// Prayer keys in chronological order.
const List<String> prayerOffsetKeys = [
  'subuh',
  'dzuhur',
  'ashar',
  'magrib',
  'isya',
];

/// Smallest / largest allowed correction in minutes.
const int kPrayerOffsetMin = -60;
const int kPrayerOffsetMax = 60;

/// Corrections that move Subuh or Magrib earlier than the standard time
/// can put the adhan before the prayer has begun, and Subuh and Magrib
/// also mark the start and the end of the fast.
const Set<String> prayersSensitiveToEarlierCorrection = {'subuh', 'magrib'};

/// All five keys, every value a whole number of minutes within range.
/// Unknown keys and non-numeric values are dropped.
Map<String, int> sanitizePrayerOffsets(Map<dynamic, dynamic>? raw) {
  return {for (final key in prayerOffsetKeys) key: _sanitizeMinutes(raw?[key])};
}

int _sanitizeMinutes(Object? value) {
  final minutes = switch (value) {
    final int v => v,
    final num v when v.isFinite => v.round(),
    final String v => int.tryParse(v.trim()) ?? 0,
    _ => 0,
  };
  return minutes.clamp(kPrayerOffsetMin, kPrayerOffsetMax).toInt();
}

bool hasActivePrayerOffsets(Map<String, int> offsets) =>
    offsets.values.any((minutes) => minutes != 0);

/// What a correction would do to one prayer on a given day.
class PrayerOffsetCheck {
  const PrayerOffsetCheck({
    required this.correctedTime,
    this.mustStayAfter,
    this.mustStayBefore,
    required this.earlierThanStandardOnSensitivePrayer,
  });

  /// The prayer time with the correction applied.
  final DateTime correctedTime;

  /// Set when the corrected time would no longer come after this prayer.
  final String? mustStayAfter;

  /// Set when the corrected time would no longer come before this prayer.
  final String? mustStayBefore;

  /// Subuh or Magrib moved earlier than the standard time.
  final bool earlierThanStandardOnSensitivePrayer;

  bool get keepsPrayerOrder => mustStayAfter == null && mustStayBefore == null;
}

/// Checks a correction of [minutes] for [prayerKey] against the standard
/// times of the day (no corrections applied) and the other prayers'
/// current corrections. The five prayers must stay in order, at least a
/// minute apart: the countdown, notifications and widget rely on it.
PrayerOffsetCheck checkPrayerOffset({
  required String prayerKey,
  required int minutes,
  required Map<String, DateTime> standardTimes,
  required Map<String, int> offsets,
}) {
  final safe = sanitizePrayerOffsets(offsets);
  DateTime corrected(String key, int correction) =>
      standardTimes[key]!.add(Duration(minutes: correction));

  final index = prayerOffsetKeys.indexOf(prayerKey);
  final time = corrected(prayerKey, minutes);

  String? after;
  if (index > 0) {
    final previous = prayerOffsetKeys[index - 1];
    if (standardTimes.containsKey(previous) &&
        !time.isAfter(corrected(previous, safe[previous]!))) {
      after = previous;
    }
  }

  String? before;
  if (index < prayerOffsetKeys.length - 1) {
    final next = prayerOffsetKeys[index + 1];
    if (standardTimes.containsKey(next) &&
        !time.isBefore(corrected(next, safe[next]!))) {
      before = next;
    }
  }

  return PrayerOffsetCheck(
    correctedTime: time,
    mustStayAfter: after,
    mustStayBefore: before,
    earlierThanStandardOnSensitivePrayer:
        minutes < 0 && prayersSensitiveToEarlierCorrection.contains(prayerKey),
  );
}
