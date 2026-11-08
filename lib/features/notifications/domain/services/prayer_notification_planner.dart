import 'package:solatify/features/notifications/domain/entities/prayer_notification_request.dart';
import 'package:solatify/features/notifications/domain/entities/prayer_notification_sync_plan.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';

/// Number of days (today included) scheduled ahead, so prayers keep firing
/// even if the app is not opened for several days. 6 days × 5 prayers × 2
/// (adhan + reminder) = 60, under iOS's limit of 64 pending notifications.
const int prayerNotificationHorizonDays = 6;

const List<String> prayerNotificationKeys = [
  'subuh',
  'dzuhur',
  'ashar',
  'magrib',
  'isya',
];

/// Adhan IDs: today is 1001–1005, tomorrow 1011–1015, and so on.
int adhanNotificationId(int dayIndex, int prayerIndex) =>
    1000 + dayIndex * 10 + prayerIndex + 1;

/// Reminder IDs: today is 5001–5005, tomorrow 5011–5015, and so on.
int reminderNotificationId(int dayIndex, int prayerIndex) =>
    5000 + dayIndex * 10 + prayerIndex + 1;

/// IDs used by earlier versions (tomorrow's Subuh and the reminders). They
/// must still be cancelled so alarms scheduled by an old build stop firing.
const Set<int> _legacyPrayerNotificationIds = {
  2001,
  3001,
  3002,
  3003,
  3004,
  3005,
  4001,
};

/// Every notification ID this app may have scheduled for prayers.
final Set<int> managedPrayerNotificationIds = {
  for (var day = 0; day < prayerNotificationHorizonDays; day++)
    for (var prayer = 0; prayer < prayerNotificationKeys.length; prayer++) ...[
      adhanNotificationId(day, prayer),
      reminderNotificationId(day, prayer),
    ],
  ..._legacyPrayerNotificationIds,
};

/// Marks the managed IDs that are still pending on the platform as
/// "scheduled, contents unknown", so the next sync plan cancels whatever is
/// not wanted any more and reschedules the rest. Used for a full sync (app
/// start, resume, settings change) because the platform may hold alarms the
/// in-memory state does not know about. Only pending IDs are included, so
/// notifications already shown in the tray are not dismissed.
Map<int, String> unknownActivePrayerNotifications(Iterable<int> pendingIds) => {
  for (final id in pendingIds)
    if (managedPrayerNotificationIds.contains(id)) id: '',
};

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

/// Requests for every enabled prayer still ahead of [now], for [today],
/// [tomorrow] and any [laterDays], capped at [prayerNotificationHorizonDays].
List<PrayerNotificationRequest> buildPrayerNotificationRequests({
  required Map<String, DateTime?> today,
  required Map<String, DateTime?> tomorrow,
  required DateTime now,
  List<Map<String, DateTime?>> laterDays = const [],
  Map<String, bool> enabledPrayerNotifications =
      SettingsState.defaultEnabledPrayerNotifications,
  int preNotificationMinutes = SettingsState.defaultPreNotificationMinutes,
}) {
  final days = [
    today,
    tomorrow,
    ...laterDays,
  ].take(prayerNotificationHorizonDays).toList(growable: false);
  final requests = <PrayerNotificationRequest>[];

  for (var day = 0; day < days.length; day++) {
    for (var prayer = 0; prayer < prayerNotificationKeys.length; prayer++) {
      final key = prayerNotificationKeys[prayer];
      if (enabledPrayerNotifications[key] == false) continue;
      final prayerTime = days[day][key];
      if (prayerTime == null || !prayerTime.isAfter(now)) continue;

      _addPrayerNotificationRequests(
        requests: requests,
        prayerKey: key,
        prayerTime: prayerTime,
        now: now,
        notificationId: adhanNotificationId(day, prayer),
        reminderNotificationId: reminderNotificationId(day, prayer),
        preNotificationMinutes: preNotificationMinutes,
      );
    }
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

/// When the notification for [key] (from [buildPrayerNotificationKey]) is
/// shown, or null if the key cannot be parsed.
DateTime? prayerNotificationTargetTime(String key) {
  final separator = key.lastIndexOf('_');
  if (separator < 0) return null;
  return DateTime.tryParse(key.substring(separator + 1));
}

/// [now], when given, keeps notifications that have already fired out of
/// [PrayerNotificationSyncPlan.notificationIdsToCancel]: cancelling them
/// would also remove them from the notification tray (on Android taking the
/// "stop adhan" action with it while the adhan is still playing).
PrayerNotificationSyncPlan buildPrayerNotificationSyncPlan({
  required Map<int, String> activeKeysById,
  required List<PrayerNotificationRequest> requests,
  DateTime? now,
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

  bool alreadyFired(String key) {
    if (now == null) return false;
    final target = prayerNotificationTargetTime(key);
    return target != null && !target.isAfter(now);
  }

  final notificationIdsToCancel =
      activeKeysById.entries
          .where(
            (entry) =>
                desiredKeysById[entry.key] != entry.value &&
                !(desiredKeysById[entry.key] == null &&
                    alreadyFired(entry.value)),
          )
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
