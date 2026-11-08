import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/notifications/domain/entities/prayer_notification_request.dart';
import 'package:solatify/features/notifications/domain/services/prayer_notification_planner.dart';
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
        1011,
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
      expect(requests.single.notificationId, 1011);
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
        1011,
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
        (request) => request.notificationId == 5002,
      );
      final dzuhurAdhan = requests.firstWhere(
        (request) => request.notificationId == 1002,
      );
      expect(dzuhurReminder.prayerKey, 'dzuhur');
      expect(dzuhurReminder.isReminder, isTrue);
      expect(dzuhurReminder.notificationTime, DateTime(2026, 6, 16, 11, 50));
      expect(dzuhurReminder.prayerTime, dzuhurAdhan.prayerTime);
    });
    test('schedules several days ahead so prayers keep firing', () {
      final now = DateTime(2026, 6, 16, 3);
      Map<String, DateTime?> dayOf(int day) => {
        for (final (i, key) in prayerNotificationKeys.indexed)
          key: DateTime(2026, 6, day, 5 + i * 3),
      };

      final requests = buildPrayerNotificationRequests(
        today: dayOf(16),
        tomorrow: dayOf(17),
        laterDays: [dayOf(18), dayOf(19), dayOf(20), dayOf(21), dayOf(22)],
        now: now,
        preNotificationMinutes: 10,
      );

      // Capped at the horizon (6 days), with an adhan and a reminder each.
      expect(requests, hasLength(prayerNotificationHorizonDays * 5 * 2));
      expect(requests.length, lessThanOrEqualTo(64)); // iOS pending limit
      expect(requests.last.prayerTime, DateTime(2026, 6, 21, 17));
      expect(requests.map((r) => r.notificationId).toSet(), hasLength(60));
    });
  });

  group('buildPrayerNotificationSyncPlan', () {
    test('a full sync cancels pending alarms for prayers turned off', () {
      final magrib = DateTime(2026, 6, 16, 18);
      // Platform still holds Ashar (1003) and Magrib (1004); Ashar was
      // turned off in Settings, so only Magrib is requested now.
      final plan = buildPrayerNotificationSyncPlan(
        activeKeysById: unknownActivePrayerNotifications([1003, 1004]),
        requests: [
          PrayerNotificationRequest(
            prayerKey: 'magrib',
            prayerTime: magrib,
            notificationTime: magrib,
            notificationId: 1004,
          ),
        ],
      );

      expect(plan.notificationIdsToCancel, [1003, 1004]);
      expect(plan.requestsToSchedule.single.notificationId, 1004);
    });

    test('does not cancel notifications that have already fired', () {
      final dzuhur = DateTime(2026, 6, 16, 12);
      final ashar = DateTime(2026, 6, 16, 15);
      final firedKey = buildPrayerNotificationKey(
        prayerKey: 'dzuhur',
        prayerTime: dzuhur,
      );
      final turnedOffKey = buildPrayerNotificationKey(
        prayerKey: 'ashar',
        prayerTime: ashar,
      );
      // 12:10: Dzuhur (1002) fired ten minutes ago and is still in the
      // tray; Ashar (1003) is pending but no longer requested.
      final plan = buildPrayerNotificationSyncPlan(
        activeKeysById: {1002: firedKey, 1003: turnedOffKey},
        requests: const [],
        now: DateTime(2026, 6, 16, 12, 10),
      );

      expect(plan.notificationIdsToCancel, [1003]);
      expect(plan.desiredKeysById, isEmpty);
    });

    test('a full sync also cancels IDs left by older versions', () {
      final plan = buildPrayerNotificationSyncPlan(
        activeKeysById: unknownActivePrayerNotifications([2001, 3002, 4001]),
        requests: const [],
      );

      expect(plan.notificationIdsToCancel, [2001, 3002, 4001]);
    });

    test('a full sync ignores IDs that are not prayer notifications', () {
      expect(unknownActivePrayerNotifications([42, 99999]), isEmpty);
    });

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

  test(
    'notification scheduler provider delegates planning to domain service',
    () {
      final providerSource = File(
        'lib/features/notifications/presentation/providers/notification_scheduler_provider.dart',
      ).readAsStringSync();

      expect(providerSource, contains('prayer_notification_planner.dart'));
      expect(
        providerSource,
        isNot(contains('class PrayerNotificationRequest')),
      );
      expect(
        providerSource,
        isNot(contains('class PrayerNotificationSyncPlan')),
      );
    },
  );
}
