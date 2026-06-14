import 'package:adhan/adhan.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

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
    final offsetStr = offsets != null ? offsets.toString() : 'no_offset';
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

class PrayerCalculationService {
  static bool _timezonesInitialized = false;

  static void _ensureTimezonesInitialized() {
    if (!_timezonesInitialized) {
      tzdata.initializeTimeZones();
      _timezonesInitialized = true;
    }
  }

  static CalculationParameters getParameters(String methodName) {
    switch (methodName) {
      case 'MuslimWorldLeague':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'Egypt':
        return CalculationMethod.egyptian.getParameters();
      case 'Karachi':
        return CalculationMethod.karachi.getParameters();
      case 'UmmAlQura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'NorthAmerica':
        return CalculationMethod.north_america.getParameters();
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

    // Check cache first
    final cached = _PrayerCalcCache.get(
      latitude,
      longitude,
      date,
      method,
      timezoneName,
      offsets,
    );
    if (cached != null) {
      return cached;
    }
    final coordinates = Coordinates(latitude, longitude);
    final params = getParameters(method);

    // Apply custom offsets if provided
    if (offsets != null) {
      params.adjustments.fajr = offsets['subuh'] ?? 0;
      params.adjustments.dhuhr = offsets['dzuhur'] ?? 0;
      params.adjustments.asr = offsets['ashar'] ?? 0;
      params.adjustments.maghrib = offsets['magrib'] ?? 0;
      params.adjustments.isha = offsets['isya'] ?? 0;
    }

    // Get the timezone location for the selected city and calculate the
    // civil date in that timezone, not the device timezone.
    final location = tz.getLocation(timezoneName);
    final targetDate = tz.TZDateTime.from(date, location);
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
      date,
      method,
      timezoneName,
      offsets,
      result,
    );

    return result;
  }
}
