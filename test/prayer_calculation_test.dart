import 'package:flutter_test/flutter_test.dart';
import 'package:adhan/adhan.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';

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
