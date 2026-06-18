import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';

void main() {
  group('Notification v2 settings defaults', () {
    test('enable every prayer with adhan sound and no reminder by default', () {
      expect(SettingsState.defaultEnabledPrayerNotifications, {
        'subuh': true,
        'dzuhur': true,
        'ashar': true,
        'magrib': true,
        'isya': true,
      });
      expect(SettingsState.defaultPreNotificationMinutes, 0);
      expect(SettingsState.defaultNotificationSoundMode, 'adhan');
    });
  });

  group('buildPrayerNotificationKey', () {
    test('keys a prayer notification by prayer and exact target time', () {
      expect(
        buildPrayerNotificationKey(
          prayerKey: 'magrib',
          prayerTime: DateTime(2026, 6, 17, 18),
        ),
        'adhan_magrib_2026-06-17T18:00:00.000_2026-06-17T18:00:00.000',
      );
    });
  });

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
      expect(requests.map((request) => request.prayerKey), [
        'subuh',
        'dzuhur',
        'ashar',
        'magrib',
        'isya',
        'subuh',
      ]);
      expect(requests.map((request) => request.notificationId), [
        1001,
        1002,
        1003,
        1004,
        1005,
        2001,
      ]);
      expect(requests.map((request) => request.prayerTime), [
        today['subuh'],
        today['dzuhur'],
        today['ashar'],
        today['magrib'],
        today['isya'],
        tomorrow['subuh'],
      ]);
    });

    test('keeps notification time exactly at prayer entry time', () {
      final now = DateTime(2026, 6, 16, 11, 59);
      final dzuhur = DateTime(2026, 6, 16, 12);
      final today = <String, DateTime?>{
        'subuh': DateTime(2026, 6, 16, 4, 30),
        'dzuhur': dzuhur,
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

      final dzuhurRequest = requests.firstWhere(
        (request) => request.prayerKey == 'dzuhur',
      );
      expect(dzuhurRequest.prayerTime, dzuhur);
      expect(dzuhurRequest.prayerTime.difference(dzuhur), Duration.zero);
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
      expect(requests.map((request) => request.prayerKey), ['ashar', 'isya']);
      expect(requests.map((request) => request.notificationId), [1003, 1005]);
    });

    test('skips prayers disabled by per-prayer notification settings', () {
      final now = DateTime(2026, 6, 16, 10);
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
        enabledPrayerNotifications: {
          ...SettingsState.defaultEnabledPrayerNotifications,
          'dzuhur': false,
          'magrib': false,
        },
      );

      expect(requests.map((request) => request.prayerKey), [
        'ashar',
        'isya',
        'subuh',
      ]);
      expect(requests.map((request) => request.notificationId), [
        1003,
        1005,
        2001,
      ]);
    });

    test('adds pre-prayer reminder requests with separate IDs', () {
      final now = DateTime(2026, 6, 16, 11, 40);
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
        preNotificationMinutes: 10,
      );

      final dzuhurReminder = requests.firstWhere(
        (request) => request.notificationId == 3002,
      );
      final dzuhurAdhan = requests.firstWhere(
        (request) => request.notificationId == 1002,
      );
      expect(dzuhurReminder.prayerKey, 'dzuhur');
      expect(dzuhurReminder.isReminder, isTrue);
      expect(dzuhurReminder.notificationTime, DateTime(2026, 6, 16, 11, 50));
      expect(dzuhurReminder.prayerTime, dzuhurAdhan.prayerTime);
    });
  });

  group('buildPrayerNotificationSyncPlan', () {
    test(
      'skips scheduling and cancellation when request keys are unchanged',
      () {
        final prayerTime = DateTime(2026, 6, 16, 18);
        final existingKey = buildPrayerNotificationKey(
          prayerKey: 'magrib',
          prayerTime: prayerTime,
        );

        final plan = buildPrayerNotificationSyncPlan(
          activeKeysById: {1004: existingKey},
          requests: [
            PrayerNotificationRequest(
              prayerKey: 'magrib',
              prayerTime: prayerTime,
              notificationTime: prayerTime,
              notificationId: 1004,
            ),
          ],
        );

        expect(plan.requestsToSchedule, isEmpty);
        expect(plan.notificationIdsToCancel, isEmpty);
        expect(plan.desiredKeysById, {1004: existingKey});
      },
    );

    test('cancels stale reused ids before scheduling updated prayer times', () {
      final oldTime = DateTime(2026, 6, 16, 18);
      final newTime = DateTime(2026, 6, 16, 18, 5);

      final plan = buildPrayerNotificationSyncPlan(
        activeKeysById: {
          1004: buildPrayerNotificationKey(
            prayerKey: 'magrib',
            prayerTime: oldTime,
          ),
        },
        requests: [
          PrayerNotificationRequest(
            prayerKey: 'magrib',
            prayerTime: newTime,
            notificationTime: newTime,
            notificationId: 1004,
          ),
        ],
      );

      expect(plan.notificationIdsToCancel, [1004]);
      expect(plan.requestsToSchedule.single.prayerTime, newTime);
      expect(
        plan.desiredKeysById[1004],
        buildPrayerNotificationKey(prayerKey: 'magrib', prayerTime: newTime),
      );
    });

    test('cancels ids that are no longer in the future request window', () {
      final oldSubuh = DateTime(2026, 6, 16, 4, 30);
      final tomorrowSubuh = DateTime(2026, 6, 17, 4, 31);

      final plan = buildPrayerNotificationSyncPlan(
        activeKeysById: {
          1001: buildPrayerNotificationKey(
            prayerKey: 'subuh',
            prayerTime: oldSubuh,
          ),
        },
        requests: [
          PrayerNotificationRequest(
            prayerKey: 'subuh',
            prayerTime: tomorrowSubuh,
            notificationTime: tomorrowSubuh,
            notificationId: 2001,
          ),
        ],
      );

      expect(plan.notificationIdsToCancel, [1001]);
      expect(plan.requestsToSchedule.single.notificationId, 2001);
      expect(plan.desiredKeysById.keys, [2001]);
    });
  });
}
