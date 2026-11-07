import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/core/utils/location_service.dart';
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

    test('East Java and Kalimantan follow province timezones', () {
      String zone(double lat, double lon, String country) =>
          PrayerTimezoneService.inferTimezoneName(
            latitude: lat,
            longitude: lon,
            country: country,
          );

      // East Java is WIB even east of 112°E.
      expect(zone(-7.2575, 112.7521, 'Jawa Timur, Indonesia'), 'Asia/Jakarta');
      expect(zone(-8.2192, 114.3691, 'East Java, Indonesia'), 'Asia/Jakarta');
      expect(
        zone(-2.2136, 113.9108, 'Kalimantan Tengah, Indonesia'),
        'Asia/Jakarta',
      );
      expect(
        zone(-3.3186, 114.5944, 'Kalimantan Selatan, Indonesia'),
        'Asia/Makassar',
      );
    });

    test('GPS locations without a province use Indonesian zone borders', () {
      String zone(double lat, double lon) =>
          PrayerTimezoneService.inferTimezoneName(
            latitude: lat,
            longitude: lon,
            country: 'Indonesia',
          );

      expect(zone(-7.2575, 112.7521), 'Asia/Jakarta'); // Surabaya
      expect(zone(-8.2192, 114.3691), 'Asia/Jakarta'); // Banyuwangi
      expect(zone(-8.6500, 115.2167), 'Asia/Makassar'); // Denpasar
      expect(zone(-2.2136, 113.9108), 'Asia/Jakarta'); // Palangkaraya
      expect(zone(-3.3186, 114.5944), 'Asia/Makassar'); // Banjarmasin
      expect(zone(-0.5022, 117.1536), 'Asia/Makassar'); // Samarinda
      expect(zone(1.4748, 124.8421), 'Asia/Makassar'); // Manado
      expect(zone(-3.6954, 128.1814), 'Asia/Jayapura'); // Ambon
      expect(zone(0.7893, 127.3772), 'Asia/Jayapura'); // Ternate
      expect(zone(-0.0263, 109.3425), 'Asia/Jakarta'); // Pontianak
    });

    test('Cities outside Indonesia get their own timezone', () {
      String zone(double lat, double lon, String country) =>
          PrayerTimezoneService.inferTimezoneName(
            latitude: lat,
            longitude: lon,
            country: country,
          );

      expect(zone(51.5074, -0.1278, 'United Kingdom'), 'Europe/London');
      expect(zone(40.7128, -74.0060, 'United States'), 'America/New_York');
      expect(zone(1.3521, 103.8198, 'Singapore'), 'Asia/Singapore');
      expect(zone(3.1390, 101.6869, 'Malaysia'), 'Asia/Kuala_Lumpur');
      expect(zone(21.4225, 39.8262, 'Arab Saudi'), 'Asia/Riyadh');
      // Unknown country: fixed offset, and no false substring matches.
      expect(zone(44.4268, 26.1025, 'Romania'), 'Etc/GMT-2');
    });

    test('Every built-in city resolves to a valid timezone', () {
      tzdata.initializeTimeZones();
      for (final city in LocationService.defaultCities) {
        final name = PrayerTimezoneService.inferTimezoneName(
          latitude: city.latitude,
          longitude: city.longitude,
          country: city.country,
        );
        expect(() => tz.getLocation(name), returnsNormally, reason: city.name);
        if (city.country.contains('Indonesia')) {
          final expected =
              city.country.contains('Papua') || city.country.contains('Maluku')
              ? 'Asia/Jayapura'
              : RegExp(
                  'Bali|Nusa Tenggara|Sulawesi|Gorontalo|'
                  'Kalimantan (Timur|Selatan|Utara)',
                ).hasMatch(city.country)
              ? 'Asia/Makassar'
              : 'Asia/Jakarta';
          expect(name, expected, reason: '${city.name}, ${city.country}');
        }
      }
    });

    test('Every calculation method offered in Settings is applied', () {
      // Keys stored by the Settings picker -> expected Fajr/Isha angles.
      final expected = <String, (double, double?)>{
        'Kemenag': (20.0, 18.0),
        'MWL': (18.0, 17.0),
        'ISNA': (15.0, 15.0),
        'Egypt': (19.5, 17.5),
        'Makkah': (18.5, null),
        'Singapore': (20.0, 18.0),
      };
      for (final entry in expected.entries) {
        final params = PrayerCalculationService.getParameters(entry.key);
        expect(params.fajrAngle, entry.value.$1, reason: entry.key);
        expect(params.ishaAngle, entry.value.$2, reason: entry.key);
      }
      // Umm al-Qura uses a fixed Isha interval instead of an angle.
      expect(PrayerCalculationService.getParameters('Makkah').ishaInterval, 90);
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
