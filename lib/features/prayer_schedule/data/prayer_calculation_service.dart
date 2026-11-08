import 'package:adhan/adhan.dart';
import 'package:solatify/core/utils/timezone_database.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_offsets.dart';
import 'package:timezone/timezone.dart' as tz;

/// Simple in-memory cache for prayer calculations to avoid recalculating
class _PrayerCalcCache {
  static final Map<String, Map<String, DateTime>> _cache = {};

  static String _cacheKey(
    double lat,
    double lng,
    DateTime date,
    String method,
    String timezoneName,
    Map<String, int>? offsets,
  ) {
    final safe = offsets == null ? null : sanitizePrayerOffsets(offsets);
    final offsetStr = safe == null
        ? 'no_offset'
        : prayerOffsetKeys.map((key) => '$key=${safe[key]}').join(',');
    return '$lat:$lng:${date.year}-${date.month}-${date.day}:$method:$timezoneName:$offsetStr';
  }

  static Map<String, DateTime>? get(
    double lat,
    double lng,
    DateTime date,
    String method,
    String timezoneName,
    Map<String, int>? offsets,
  ) {
    return _cache[_cacheKey(lat, lng, date, method, timezoneName, offsets)];
  }

  static void set(
    double lat,
    double lng,
    DateTime date,
    String method,
    String timezoneName,
    Map<String, int>? offsets,
    Map<String, DateTime> times,
  ) {
    final key = _cacheKey(lat, lng, date, method, timezoneName, offsets);
    _cache[key] = times;
    // Keep cache size reasonable (max 30 entries = ~30 days)
    if (_cache.length > 30) {
      _cache.remove(_cache.keys.first);
    }
  }
}

/// Conventions an official schedule applies on top of the astronomical
/// times. Kept apart from the user's own corrections: the standard decides
/// what "0 minutes" means, a correction only moves away from it.
class PrayerMethodStandard {
  const PrayerMethodStandard({
    this.ihtiyatMinutes = const {},
    this.roundUp = false,
  });

  /// Safety margin (ihtiyat) per prayer key, in minutes.
  final Map<String, int> ihtiyatMinutes;

  /// Round each time up to the next minute instead of to the nearest one,
  /// so a published minute is never earlier than the computed instant.
  final bool roundUp;

  static const none = PrayerMethodStandard();

  /// Kemenag RI: 2 minutes of ihtiyat, 3 for Dzuhur and Magrib, rounded up.
  ///
  /// Calibrated against Kemenag's published schedules (Bimas Islam, via
  /// api.myquran.com) for Banda Aceh, Medan, Jakarta, Surabaya, Denpasar,
  /// Makassar and Jayapura on four dates across the year: 86% of the times
  /// match to the minute and none is more than one minute off. Without it,
  /// every time was 2 to 4 minutes earlier than Kemenag's, which put the
  /// Magrib adhan before the official time to break the fast.
  static const kemenag = PrayerMethodStandard(
    ihtiyatMinutes: {
      'subuh': 2,
      'dzuhur': 3,
      'ashar': 2,
      'magrib': 3,
      'isya': 2,
    },
    roundUp: true,
  );
}

class PrayerCalculationService {
  static void _ensureTimezonesInitialized() =>
      TimezoneDatabase.ensureInitialized();

  /// adhan rounds every time to the nearest minute. Its times depend on the
  /// longitude only through the solar transit, at 4 minutes per degree, so
  /// computing 0.125 degrees further west yields each instant plus exactly
  /// 30 seconds, and nearest(t + 30 s) is t rounded up.
  static const double _roundUpLongitudeShift = 0.125;

  static PrayerMethodStandard standardFor(String methodName) {
    switch (methodName) {
      case 'Kemenag':
        return PrayerMethodStandard.kemenag;
      default:
        // Unknown or legacy values fall back to Kemenag parameters in
        // [getParameters], so they get the Kemenag standard too.
        return _isKnownNonKemenag(methodName)
            ? PrayerMethodStandard.none
            : PrayerMethodStandard.kemenag;
    }
  }

  static bool _isKnownNonKemenag(String methodName) => const {
    'MWL',
    'MuslimWorldLeague',
    'Egypt',
    'Karachi',
    'Makkah',
    'UmmAlQura',
    'ISNA',
    'NorthAmerica',
    'Singapore',
    'Dubai',
  }.contains(methodName);

  /// Noon, [daysAhead] calendar days after the current day in
  /// [timezoneName], as an instant to pass to [calculatePrayerTimes].
  ///
  /// Stepping by `now.add(Duration(days: n))` lands on the wrong date around
  /// a DST change (a 23- or 25-hour day), and using the device's calendar
  /// is off when the selected city is in another timezone.
  static DateTime cityNoon(String timezoneName, DateTime now, int daysAhead) {
    _ensureTimezonesInitialized();
    final location = tz.getLocation(timezoneName);
    final cityNow = tz.TZDateTime.from(now, location);
    return tz.TZDateTime(
      location,
      cityNow.year,
      cityNow.month,
      cityNow.day + daysAhead,
      12,
    );
  }

  static CalculationParameters getParameters(String methodName) {
    // Settings stores the short keys ('MWL', 'ISNA', 'Makkah', 'Singapore');
    // the long names are kept as aliases for older stored values.
    switch (methodName) {
      case 'MWL':
      case 'MuslimWorldLeague':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'Egypt':
        return CalculationMethod.egyptian.getParameters();
      case 'Karachi':
        return CalculationMethod.karachi.getParameters();
      case 'Makkah':
      case 'UmmAlQura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'ISNA':
      case 'NorthAmerica':
        return CalculationMethod.north_america.getParameters();
      case 'Singapore':
        return CalculationMethod.singapore.getParameters();
      case 'Dubai':
        return CalculationMethod.dubai.getParameters();
      case 'Kemenag':
      default:
        // Kemenag (Indonesian Ministry of Religious Affairs) standard
        // Fajr: 20 degrees, Isha: 18 degrees
        final params = CalculationParameters(fajrAngle: 20.0, ishaAngle: 18.0);
        params.madhab = Madhab.shafi;
        return params;
    }
  }

  static Map<String, DateTime> calculatePrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    required String method,
    required String timezoneName,
    Map<String, int>? offsets, // In minutes, optional custom offset adjustments
  }) {
    _ensureTimezonesInitialized();

    // The civil date is the city's, not the device's: they differ around
    // midnight when the phone is in another timezone, and caching by the
    // device date returned the wrong day's times.
    final location = tz.getLocation(timezoneName);
    final targetDate = tz.TZDateTime.from(date, location);
    final cityDay = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final cached = _PrayerCalcCache.get(
      latitude,
      longitude,
      cityDay,
      method,
      timezoneName,
      offsets,
    );
    if (cached != null) {
      return cached;
    }
    final standard = standardFor(method);
    final coordinates = Coordinates(
      latitude,
      standard.roundUp ? longitude - _roundUpLongitudeShift : longitude,
    );
    final params = getParameters(method);

    // The method's own convention, then the user's correction on top.
    final ihtiyat = standard.ihtiyatMinutes;
    params.methodAdjustments.fajr += ihtiyat['subuh'] ?? 0;
    params.methodAdjustments.dhuhr += ihtiyat['dzuhur'] ?? 0;
    params.methodAdjustments.asr += ihtiyat['ashar'] ?? 0;
    params.methodAdjustments.maghrib += ihtiyat['magrib'] ?? 0;
    params.methodAdjustments.isha += ihtiyat['isya'] ?? 0;

    if (offsets != null) {
      final safe = sanitizePrayerOffsets(offsets);
      params.adjustments.fajr = safe['subuh']!;
      params.adjustments.dhuhr = safe['dzuhur']!;
      params.adjustments.asr = safe['ashar']!;
      params.adjustments.maghrib = safe['magrib']!;
      params.adjustments.isha = safe['isya']!;
    }

    final dateComponents = DateComponents(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // Convert UTC times from adhan to TZDateTime for the specific location
    final result = {
      'subuh': tz.TZDateTime.from(prayerTimes.fajr, location),
      'dzuhur': tz.TZDateTime.from(prayerTimes.dhuhr, location),
      'ashar': tz.TZDateTime.from(prayerTimes.asr, location),
      'magrib': tz.TZDateTime.from(prayerTimes.maghrib, location),
      'isya': tz.TZDateTime.from(prayerTimes.isha, location),
    };

    // Cache result for future calls
    _PrayerCalcCache.set(
      latitude,
      longitude,
      cityDay,
      method,
      timezoneName,
      offsets,
      result,
    );

    return result;
  }
}
