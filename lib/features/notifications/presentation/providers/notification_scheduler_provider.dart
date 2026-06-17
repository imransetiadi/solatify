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

class NotificationSchedulerNotifier extends StateNotifier<void> {
  NotificationSchedulerNotifier(this._ref) : super(null) {
    _initializeNotifications();
  }
  final Ref _ref;
  Timer? _schedulingTimer;
  final Set<String> _scheduledNotifications = {};
  ProviderSubscription<PrayerTimesStateEntity>? _prayerTimesSubscription;
  ProviderSubscription<LocationEntity>? _locationSubscription;

  Future<void> refreshSchedules({bool force = false}) async {
    if (force) {
      _scheduledNotifications.clear();
    }
    await _scheduleAllNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().init();
      _prayerTimesSubscription?.close();
      _locationSubscription?.close();
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
    try {
      final timesState = _ref.read(prayerTimesProvider);
      final location = _ref.read(locationProvider);

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

      debugPrint('Prayer notification request count: ${requests.length}');
      for (final request in requests) {
        debugPrint(
          'Prayer notification request: prayer=${request.prayerKey}, '
          'id=${request.notificationId}, target=${request.prayerTime.toIso8601String()}, '
          'timezone=$timezoneName, isFuture=${request.prayerTime.isAfter(now)}',
        );
      }

      final readiness = await NotificationService().getReadinessStatus();
      debugPrint(
        'Notification readiness before prayer scheduling: '
        '${readiness.status.name} - ${readiness.title}',
      );

      for (final request in requests) {
        await _scheduleNotification(
          prayerKey: request.prayerKey,
          prayerTime: request.prayerTime,
          location: locationStr,
          timezoneName: timezoneName,
          notificationId: request.notificationId,
        );
      }

      debugPrint(
        'Scheduled ${requests.length} prayer notifications for today and tomorrow',
      );
      final pendingIds = await NotificationService()
          .getPendingNotificationIds();
      debugPrint(
        'Pending prayer notification IDs after scheduling: $pendingIds',
      );
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
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
      final notificationKey = buildPrayerNotificationKey(
        prayerKey: prayerKey,
        prayerTime: prayerTime,
      );

      // Avoid scheduling duplicate notifications
      if (_scheduledNotifications.contains(notificationKey)) {
        return;
      }

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
      );

      // Mark as scheduled only after successful completion
      _scheduledNotifications.add(notificationKey);
      debugPrint(
        'Marked $prayerKey scheduled: ID=$notificationId at $prayerTimeStr',
      );
    } catch (e) {
      debugPrint('Error scheduling notification for $prayerKey: $e');
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
      _scheduledNotifications.clear();
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
    super.dispose();
  }
}

final notificationSchedulerProvider =
    StateNotifierProvider<NotificationSchedulerNotifier, void>((ref) {
      return NotificationSchedulerNotifier(ref);
    });
