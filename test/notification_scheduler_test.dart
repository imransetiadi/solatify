import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';

void main() {
  test('schedules tomorrow subuh when today prayer times have passed', () {
    final now = DateTime(2026, 6, 16, 21);
    final today = <String, DateTime?>{
      'subuh': DateTime(2026, 6, 16, 4, 30),
      'dzuhur': DateTime(2026, 6, 16, 12),
      'ashar': DateTime(2026, 6, 16, 15, 20),
      'magrib': DateTime(2026, 6, 16, 18),
      'isya': DateTime(2026, 6, 16, 19, 15),
    };
    final tomorrow = <String, DateTime?>{'subuh': DateTime(2026, 6, 17, 4, 31)};

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
}
