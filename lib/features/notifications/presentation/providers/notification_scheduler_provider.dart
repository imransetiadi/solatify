import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/performance/performance_tuning.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_timezone_service.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/location_entity.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_times_state_entity.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

class PrayerNotificationRequest {
  const PrayerNotificationRequest({
    required this.prayerKey,
    required this.prayerTime,
    required this.notificationId,
  });

  final String prayerKey;
  final DateTime prayerTime;
  final int notificationId;
}

class PrayerNotificationSyncPlan {
  const PrayerNotificationSyncPlan({
    required this.requestsToSchedule,
    required this.notificationIdsToCancel,
    required this.desiredKeysById,
  });

  final List<PrayerNotificationRequest> requestsToSchedule;
  final List<int> notificationIdsToCancel;
  final Map<int, String> desiredKeysById;
}

String buildPrayerNotificationKey({
  required String prayerKey,
  required DateTime prayerTime,
}) {
  return '${prayerKey}_${prayerTime.toIso8601String()}';
}

List<PrayerNotificationRequest> buildPrayerNotificationRequests({
  required Map<String, DateTime?> today,
  required Map<String, DateTime?> tomorrow,
  required DateTime now,
}) {
  const prayerKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
  final requests = <PrayerNotificationRequest>[];

  for (var index = 0; index < prayerKeys.length; index++) {
    final key = prayerKeys[index];
    final prayerTime = today[key];
    if (prayerTime != null && prayerTime.isAfter(now)) {
      requests.add(
        PrayerNotificationRequest(
          prayerKey: key,
          prayerTime: prayerTime,
          notificationId: 1001 + index,
        ),
      );
    }
  }

  final tomorrowSubuh = tomorrow['subuh'];
  if (tomorrowSubuh != null && tomorrowSubuh.isAfter(now)) {
    requests.add(
      PrayerNotificationRequest(
        prayerKey: 'subuh',
        prayerTime: tomorrowSubuh,
        notificationId: 2001,
      ),
    );
  }

  return requests;
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

class NotificationSchedulerNotifier extends StateNotifier<void> {
  NotificationSchedulerNotifier(this._ref) : super(null) {
    _initializeNotifications();
  }
  final Ref _ref;
  Timer? _schedulingTimer;
  final Map<int, String> _scheduledNotificationKeysById = {};
  ProviderSubscription<PrayerTimesStateEntity>? _prayerTimesSubscription;
  ProviderSubscription<LocationEntity>? _locationSubscription;
  ProviderSubscription<SettingsState>? _settingsSubscription;
  bool _schedulingInProgress = false;
  bool _rescheduleRequested = false;

  Future<void> refreshSchedules({bool force = false}) async {
    if (force) {
      _scheduledNotificationKeysById.clear();
    }
    await _scheduleAllNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().init();
      _prayerTimesSubscription?.close();
      _locationSubscription?.close();
      _settingsSubscription?.close();
      _prayerTimesSubscription = _ref.listen<PrayerTimesStateEntity>(
        prayerTimesProvider,
        (previous, next) {
          if (mounted) {
            _scheduleAllNotifications();
          }
        },
      );
      _locationSubscription = _ref.listen<LocationEntity>(locationProvider, (
        previous,
        next,
      ) {
        if (mounted) {
          _scheduleAllNotifications();
        }
      });
      _settingsSubscription = _ref.listen<SettingsState>(settingsProvider, (
        previous,
        next,
      ) {
        if (!mounted ||
            previous?.adhanNotificationsEnabled ==
                next.adhanNotificationsEnabled) {
          return;
        }

        if (next.adhanNotificationsEnabled) {
          refreshSchedules(force: true);
        } else {
          cancelAllNotifications();
        }
      });
      _scheduleAllNotifications();

      // Re-check periodically as a safety net; provider listeners handle normal
      // location and prayer-time changes immediately.
      _schedulingTimer?.cancel();
      _schedulingTimer = Timer.periodic(
        PerformanceTuning.notificationScheduleAuditInterval,
        (_) => _scheduleAllNotifications(),
      );
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _scheduleAllNotifications() async {
    if (_schedulingInProgress) {
      _rescheduleRequested = true;
      return;
    }

    _schedulingInProgress = true;
    try {
      final timesState = _ref.read(prayerTimesProvider);
      final location = _ref.read(locationProvider);
      final settings = _ref.read(settingsProvider);

      if (!settings.adhanNotificationsEnabled) {
        await NotificationService().cancelAllNotifications();
        _scheduledNotificationKeysById.clear();
        return;
      }

      final readiness = await NotificationService().getReadinessStatus();
      if (readiness.status ==
          NotificationReadinessStatus.needsNotificationPermission) {
        await NotificationService().cancelAllNotifications();
        _scheduledNotificationKeysById.clear();
        return;
      }

      final today = timesState.todayTimes;
      final tomorrow = timesState.tomorrowTimes;
      final locationStr = '${location.city}, ${location.country}';
      final timezoneName = PrayerTimezoneService.inferTimezoneName(
        latitude: location.latitude,
        longitude: location.longitude,
        country: location.country,
      );

      if (!_hasAllRequiredTimes(today, tomorrow)) return;

      final now = DateTime.now();

      final requests = buildPrayerNotificationRequests(
        today: today,
        tomorrow: tomorrow,
        now: now,
      );

      final plan = buildPrayerNotificationSyncPlan(
        activeKeysById: _scheduledNotificationKeysById,
        requests: requests,
      );

      if (plan.requestsToSchedule.isEmpty &&
          plan.notificationIdsToCancel.isEmpty) {
        debugPrint(
          'Prayer notification schedule unchanged; skipping platform calls.',
        );
        return;
      }

      debugPrint(
        'Prayer notification sync: desired=${requests.length}, '
        'schedule=${plan.requestsToSchedule.length}, '
        'cancel=${plan.notificationIdsToCancel.length}',
      );

      debugPrint(
        'Notification readiness before prayer scheduling: '
        '${readiness.status.name} - ${readiness.title}',
      );

      for (final notificationId in plan.notificationIdsToCancel) {
        await NotificationService().cancelNotification(notificationId);
        _scheduledNotificationKeysById.remove(notificationId);
      }

      for (final request in plan.requestsToSchedule) {
        await _scheduleNotification(
          prayerKey: request.prayerKey,
          prayerTime: request.prayerTime,
          location: locationStr,
          timezoneName: timezoneName,
          notificationId: request.notificationId,
        );
      }

      _scheduledNotificationKeysById
        ..clear()
        ..addAll(plan.desiredKeysById);

      debugPrint(
        'Synced ${plan.desiredKeysById.length} prayer notifications for today and tomorrow',
      );
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    } finally {
      _schedulingInProgress = false;
      if (_rescheduleRequested && mounted) {
        _rescheduleRequested = false;
        await _scheduleAllNotifications();
      }
    }
  }

  Future<void> _scheduleNotification({
    required String prayerKey,
    required DateTime prayerTime,
    required String location,
    required String timezoneName,
    required int notificationId,
  }) async {
    try {
      final timeFormatter = DateFormat('HH:mm');
      final prayerTimeStr = timeFormatter.format(prayerTime);

      // Schedule notification at prayer time
      await NotificationService().schedulePrayerNotification(
        prayerKey: prayerKey,
        location: location,
        prayerTime: prayerTimeStr,
        notificationTime: prayerTime,
        timezoneName: timezoneName,
        notificationId: notificationId,
        refreshExactAlarmCapability: false,
      );

      debugPrint(
        'Marked $prayerKey scheduled: ID=$notificationId at $prayerTimeStr',
      );
    } catch (e) {
      debugPrint('Error scheduling notification for $prayerKey: $e');
      rethrow;
    }
  }

  bool _hasAllRequiredTimes(
    Map<String, DateTime?> today,
    Map<String, DateTime?> tomorrow,
  ) {
    return today.containsKey('subuh') &&
        today.containsKey('dzuhur') &&
        today.containsKey('ashar') &&
        today.containsKey('magrib') &&
        today.containsKey('isya') &&
        tomorrow.containsKey('subuh');
  }

  Future<void> cancelAllNotifications() async {
    try {
      await NotificationService().cancelAllNotifications();
      _scheduledNotificationKeysById.clear();
      _schedulingTimer?.cancel();
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  @override
  void dispose() {
    _schedulingTimer?.cancel();
    _prayerTimesSubscription?.close();
    _locationSubscription?.close();
    _settingsSubscription?.close();
    super.dispose();
  }
}

final notificationSchedulerProvider =
    StateNotifierProvider<NotificationSchedulerNotifier, void>((ref) {
      return NotificationSchedulerNotifier(ref);
    });
