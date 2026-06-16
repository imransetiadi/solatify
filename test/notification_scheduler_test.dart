import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';

void main() {
  group('buildPrayerNotificationRequests', () {
    test('schedules all remaining prayers when times are ahead', () {
      final now = DateTime(2026, 6, 16, 3);
      final today = <String, DateTime?>{
        'subuh': DateTime(2026, 6, 16, 4, 30),
        'dzuhur': DateTime(2026, 6, 16, 12),
        'ashar': DateTime(2026, 6, 16, 15, 20),
        'magrib': DateTime(2026, 6, 16, 18),
        'isya': DateTime(2026, 6, 16, 19, 15),
      };
      final tomorrow = <String, DateTime?>{
        'subuh': DateTime(2026, 6, 17, 4, 31),
      };

      final requests = buildPrayerNotificationRequests(
        today: today,
        tomorrow: tomorrow,
        now: now,
      );

      expect(requests, hasLength(6));
      expect(
        requests.map((request) => request.prayerKey),
        ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya', 'subuh'],
      );
      expect(
        requests.map((request) => request.notificationId),
        [1001, 1002, 1003, 1004, 1005, 2001],
      );
    });

    test('schedules tomorrow subuh when today prayer times have passed', () {
      final now = DateTime(2026, 6, 16, 21);
      final today = <String, DateTime?>{
        'subuh': DateTime(2026, 6, 16, 4, 30),
        'dzuhur': DateTime(2026, 6, 16, 12),
        'ashar': DateTime(2026, 6, 16, 15, 20),
        'magrib': DateTime(2026, 6, 16, 18),
        'isya': DateTime(2026, 6, 16, 19, 15),
      };
      final tomorrow = <String, DateTime?>{
        'subuh': DateTime(2026, 6, 17, 4, 31),
      };

      final requests = buildPrayerNotificationRequests(
        today: today,
        tomorrow: tomorrow,
        now: now,
      );

      expect(requests, hasLength(1));
      expect(requests.single.prayerKey, 'subuh');
      expect(requests.single.prayerTime, DateTime(2026, 6, 17, 4, 31));
      expect(requests.single.notificationId, 2001);
    });

    test('skips null or missing prayer entries safely', () {
      final now = DateTime(2026, 6, 16, 10);
      final today = <String, DateTime?>{
        'subuh': DateTime(2026, 6, 16, 4, 30),
        'dzuhur': null,
        'ashar': DateTime(2026, 6, 16, 15, 20),
        'isya': DateTime(2026, 6, 16, 19, 15),
      };
      final tomorrow = <String, DateTime?>{'subuh': null};

      final requests = buildPrayerNotificationRequests(
        today: today,
        tomorrow: tomorrow,
        now: now,
      );

      expect(requests, hasLength(2));
      expect(
        requests.map((request) => request.prayerKey),
        ['ashar', 'isya'],
      );
      expect(
        requests.map((request) => request.notificationId),
        [1003, 1005],
      );
    });
  });
}
