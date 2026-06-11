import 'package:adhan/adhan.dart';

class PrayerCalculationService {
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
    Map<String, int>? offsets, // In minutes, optional custom offset adjustments
  }) {
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

    // Convert DateTime to DateComponents for adhan library
    final dateComponents = DateComponents(date.year, date.month, date.day);

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // Return localized map of DateTime objects converted to local time
    return {
      'subuh': prayerTimes.fajr.toLocal(),
      'dzuhur': prayerTimes.dhuhr.toLocal(),
      'ashar': prayerTimes.asr.toLocal(),
      'magrib': prayerTimes.maghrib.toLocal(),
      'isya': prayerTimes.isha.toLocal(),
    };
  }
}
