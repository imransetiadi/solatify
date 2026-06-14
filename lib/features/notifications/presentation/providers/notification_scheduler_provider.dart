import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/services/notification_service.dart';
import '../../../prayer_schedule/presentation/prayer_times_provider.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';

class NotificationSchedulerNotifier extends StateNotifier<void> {
  final Ref _ref;
  Timer? _schedulingTimer;
  final Set<String> _scheduledNotifications = {};

  NotificationSchedulerNotifier(this._ref) : super(null) {
    _initializeNotifications();
  }

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

      // Prayer keys in order for today
      const prayerKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
      int notificationId = 1001;

      for (final key in prayerKeys) {
        final prayerTime = today[key];
        if (prayerTime != null && prayerTime.isAfter(now)) {
          await _scheduleNotification(
            prayerKey: key,
            prayerTime: prayerTime,
            location: locationStr,
            notificationId: notificationId,
          );
        }
        notificationId++;
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
