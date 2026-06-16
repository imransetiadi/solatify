import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
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

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().init();
      _scheduleAllNotifications();

      // Re-check notifications every minute to ensure they're scheduled
      _schedulingTimer?.cancel();
      _schedulingTimer = Timer.periodic(
        const Duration(minutes: 1),
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

      if (!_hasAllRequiredTimes(today, tomorrow)) return;

      final now = DateTime.now();

      final requests = buildPrayerNotificationRequests(
        today: today,
        tomorrow: tomorrow,
        now: now,
      );

      for (final request in requests) {
        await _scheduleNotification(
          prayerKey: request.prayerKey,
          prayerTime: request.prayerTime,
          location: locationStr,
          notificationId: request.notificationId,
        );
      }
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
    }
  }

  Future<void> _scheduleNotification({
    required String prayerKey,
    required DateTime prayerTime,
    required String location,
    required int notificationId,
  }) async {
    try {
      final notificationKey = '${prayerKey}_${prayerTime.toIso8601String()}';

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
        notificationId: notificationId,
      );

      _scheduledNotifications.add(notificationKey);
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
    super.dispose();
  }
}

final notificationSchedulerProvider =
    StateNotifierProvider<NotificationSchedulerNotifier, void>((ref) {
      return NotificationSchedulerNotifier(ref);
    });
