import 'package:solatify/features/notifications/domain/entities/prayer_notification_request.dart';
import 'package:solatify/features/notifications/domain/entities/prayer_notification_sync_plan.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';

String buildPrayerNotificationKey({
  required String prayerKey,
  required DateTime prayerTime,
  DateTime? notificationTime,
  bool isReminder = false,
}) {
  final targetTime = notificationTime ?? prayerTime;
  final kind = isReminder ? 'reminder' : 'adhan';
  return '${kind}_${prayerKey}_${prayerTime.toIso8601String()}_${targetTime.toIso8601String()}';
}

List<PrayerNotificationRequest> buildPrayerNotificationRequests({
  required Map<String, DateTime?> today,
  required Map<String, DateTime?> tomorrow,
  required DateTime now,
  Map<String, bool> enabledPrayerNotifications =
      SettingsState.defaultEnabledPrayerNotifications,
  int preNotificationMinutes = SettingsState.defaultPreNotificationMinutes,
}) {
  const prayerKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
  final requests = <PrayerNotificationRequest>[];

  for (var index = 0; index < prayerKeys.length; index++) {
    final key = prayerKeys[index];
    if (enabledPrayerNotifications[key] == false) continue;
    final prayerTime = today[key];
    if (prayerTime != null && prayerTime.isAfter(now)) {
      _addPrayerNotificationRequests(
        requests: requests,
        prayerKey: key,
        prayerTime: prayerTime,
        now: now,
        notificationId: 1001 + index,
        reminderNotificationId: 3001 + index,
        preNotificationMinutes: preNotificationMinutes,
      );
    }
  }

  final tomorrowSubuh = tomorrow['subuh'];
  if (enabledPrayerNotifications['subuh'] != false &&
      tomorrowSubuh != null &&
      tomorrowSubuh.isAfter(now)) {
    _addPrayerNotificationRequests(
      requests: requests,
      prayerKey: 'subuh',
      prayerTime: tomorrowSubuh,
      now: now,
      notificationId: 2001,
      reminderNotificationId: 4001,
      preNotificationMinutes: preNotificationMinutes,
    );
  }

  return requests;
}

void _addPrayerNotificationRequests({
  required List<PrayerNotificationRequest> requests,
  required String prayerKey,
  required DateTime prayerTime,
  required DateTime now,
  required int notificationId,
  required int reminderNotificationId,
  required int preNotificationMinutes,
}) {
  if (preNotificationMinutes > 0) {
    final reminderTime = prayerTime.subtract(
      Duration(minutes: preNotificationMinutes),
    );
    if (reminderTime.isAfter(now)) {
      requests.add(
        PrayerNotificationRequest(
          prayerKey: prayerKey,
          prayerTime: prayerTime,
          notificationTime: reminderTime,
          notificationId: reminderNotificationId,
          isReminder: true,
        ),
      );
    }
  }

  requests.add(
    PrayerNotificationRequest(
      prayerKey: prayerKey,
      prayerTime: prayerTime,
      notificationTime: prayerTime,
      notificationId: notificationId,
    ),
  );
}

PrayerNotificationSyncPlan buildPrayerNotificationSyncPlan({
  required Map<int, String> activeKeysById,
  required List<PrayerNotificationRequest> requests,
}) {
  final desiredKeysById = <int, String>{
    for (final request in requests)
      request.notificationId: buildPrayerNotificationKey(
        prayerKey: request.prayerKey,
        prayerTime: request.prayerTime,
        notificationTime: request.notificationTime,
        isReminder: request.isReminder,
      ),
  };

  final notificationIdsToCancel =
      activeKeysById.entries
          .where((entry) => desiredKeysById[entry.key] != entry.value)
          .map((entry) => entry.key)
          .toList(growable: false)
        ..sort();

  final requestsToSchedule = requests
      .where((request) {
        final key = desiredKeysById[request.notificationId];
        return activeKeysById[request.notificationId] != key;
      })
      .toList(growable: false);

  return PrayerNotificationSyncPlan(
    requestsToSchedule: requestsToSchedule,
    notificationIdsToCancel: notificationIdsToCancel,
    desiredKeysById: desiredKeysById,
  );
}
