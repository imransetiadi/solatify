import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_time_utilities.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_timezone_service.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('Prayer Calculation Tests', () {
    test('Calculate Jakarta Prayer Times using Kemenag method', () {
      final jakartaLat = -6.2088;
      final jakartaLng = 106.8456;
      final date = DateTime(2026, 6, 8); // Monday, June 8, 2026

      final times = PrayerCalculationService.calculatePrayerTimes(
        latitude: jakartaLat,
        longitude: jakartaLng,
        date: date,
        method: 'Kemenag',
        timezoneName: 'Asia/Jakarta',
      );

      // Verify we have all 5 prayers
      expect(times.containsKey('subuh'), true);
      expect(times.containsKey('dzuhur'), true);
      expect(times.containsKey('ashar'), true);
      expect(times.containsKey('magrib'), true);
      expect(times.containsKey('isya'), true);

      // Verify chronology: Subuh is before Dzuhur, Dzuhur before Ashar, etc.
      expect(times['subuh']!.isBefore(times['dzuhur']!), true);
      expect(times['dzuhur']!.isBefore(times['ashar']!), true);
      expect(times['ashar']!.isBefore(times['magrib']!), true);
      expect(times['magrib']!.isBefore(times['isya']!), true);
    });

    test('Manual prayer offsets shift calculated times by minutes', () {
      final date = DateTime(2026, 6, 8);
      final baseTimes = PrayerCalculationService.calculatePrayerTimes(
        latitude: -6.2088,
        longitude: 106.8456,
        date: date,
        method: 'Kemenag',
        timezoneName: 'Asia/Jakarta',
      );
      final adjustedTimes = PrayerCalculationService.calculatePrayerTimes(
        latitude: -6.2088,
        longitude: 106.8456,
        date: date,
        method: 'Kemenag',
        timezoneName: 'Asia/Jakarta',
        offsets: {
          'subuh': -2,
          'dzuhur': 3,
          'ashar': 5,
          'magrib': -1,
          'isya': 4,
        },
      );

      expect(
        adjustedTimes['subuh'],
        baseTimes['subuh']!.subtract(const Duration(minutes: 2)),
      );
      expect(
        adjustedTimes['dzuhur'],
        baseTimes['dzuhur']!.add(const Duration(minutes: 3)),
      );
      expect(
        adjustedTimes['ashar'],
        baseTimes['ashar']!.add(const Duration(minutes: 5)),
      );
      expect(
        adjustedTimes['magrib'],
        baseTimes['magrib']!.subtract(const Duration(minutes: 1)),
      );
      expect(
        adjustedTimes['isya'],
        baseTimes['isya']!.add(const Duration(minutes: 4)),
      );
    });

    test('Active prayer at Jakarta morning is Subuh, not Isya', () {
      tzdata.initializeTimeZones();
      final jakarta = tz.getLocation('Asia/Jakarta');
      final now = tz.TZDateTime(jakarta, 2026, 6, 14, 10, 39);
      final times = PrayerCalculationService.calculatePrayerTimes(
        latitude: -6.2088,
        longitude: 106.8456,
        date: now,
        method: 'Kemenag',
        timezoneName: 'Asia/Jakarta',
      );

      expect(PrayerTimeUtilities.getCurrentPrayerName(now, times), 'Subuh');
      expect(PrayerTimeUtilities.getNextPrayerName(now, times), 'Dzuhur');
    });

    test('Active prayer uses selected city timezone, not device timezone', () {
      tzdata.initializeTimeZones();
      final makassar = tz.getLocation('Asia/Makassar');
      final now = tz.TZDateTime(makassar, 2026, 6, 14, 10, 39);
      final times = PrayerCalculationService.calculatePrayerTimes(
        latitude: -5.1477,
        longitude: 119.4327,
        date: now,
        method: 'Kemenag',
        timezoneName: 'Asia/Makassar',
      );

      expect(PrayerTimeUtilities.getCurrentPrayerName(now, times), 'Subuh');
      expect(PrayerTimeUtilities.getNextPrayerName(now, times), 'Dzuhur');
    });

    test('Infer Indonesian prayer notification timezones', () {
      expect(
        PrayerTimezoneService.inferTimezoneName(
          latitude: -6.2088,
          longitude: 106.8456,
          country: 'DKI Jakarta, Indonesia',
        ),
        'Asia/Jakarta',
      );
      expect(
        PrayerTimezoneService.inferTimezoneName(
          latitude: -8.65,
          longitude: 115.2167,
          country: 'Bali, Indonesia',
        ),
        'Asia/Makassar',
      );
      expect(
        PrayerTimezoneService.inferTimezoneName(
          latitude: -2.5916,
          longitude: 140.669,
          country: 'Papua, Indonesia',
        ),
        'Asia/Jayapura',
      );
    });

    test('Verify Qibla Bearing calculation from Jakarta', () {
      final jakartaLat = -6.2088;
      final jakartaLng = 106.8456;
      final coordinates = Coordinates(jakartaLat, jakartaLng);

      // Fetch Qibla bearing using adhan library
      final qiblaAngle = Qibla(coordinates).direction;

      // Qibla bearing from Jakarta is approximately 295 degrees (West-Northwest)
      expect(qiblaAngle, closeTo(295.0, 2.0));
    });
  });
}
