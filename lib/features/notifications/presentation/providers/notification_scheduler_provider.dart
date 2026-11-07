import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/performance/performance_tuning.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/domain/services/prayer_notification_planner.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_timezone_service.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/location_entity.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_times_state_entity.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

class NotificationSchedulerNotifier extends StateNotifier<void> {
  NotificationSchedulerNotifier(this._ref) : super(null) {
    _initializeNotifications();
  }
  final Ref _ref;
  Timer? _schedulingTimer;
  final Map<int, String> _scheduledNotificationKeysById = {};

  // The first sync after a cold start is a full sync, so alarms for prayers
  // that were turned off meanwhile are cancelled.
  bool _fullSyncRequested = true;
  bool _pluginInitialized = false;
  ProviderSubscription<PrayerTimesStateEntity>? _prayerTimesSubscription;
  ProviderSubscription<LocationEntity>? _locationSubscription;
  ProviderSubscription<SettingsState>? _settingsSubscription;
  bool _schedulingInProgress = false;
  bool _rescheduleRequested = false;

  /// [force] re-syncs every managed notification: anything not wanted any
  /// more is cancelled and the rest is rescheduled. (Previously force cleared
  /// the known-active map, so nothing was ever cancelled and prayers turned
  /// off in Settings kept firing.)
  Future<void> refreshSchedules({bool force = false}) async {
    if (force) _fullSyncRequested = true;
    if (!_pluginInitialized) {
      // Startup init failed earlier; retry it (this also registers the
      // listeners and runs the first sync) instead of giving up for good.
      await _initializeNotifications();
      return;
    }
    _ensureAuditTimer();
    await _scheduleAllNotifications();
  }

  /// Periodic safety net; restarted here because cancelling all
  /// notifications stops it.
  void _ensureAuditTimer() {
    if (_schedulingTimer?.isActive ?? false) return;
    _schedulingTimer = Timer.periodic(
      PerformanceTuning.notificationScheduleAuditInterval,
      (_) => _scheduleAllNotifications(),
    );
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().init();
      _pluginInitialized = true;
    } catch (e) {
      // Without the plugin nothing can be scheduled. refreshSchedules (app
      // resume, settings changes) retries the initialisation later.
      debugPrint('Error initializing notifications: $e');
      return;
    }
    try {
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
      _ensureAuditTimer();
    } catch (e) {
      debugPrint('Error registering notification listeners: $e');
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

      if (_fullSyncRequested) {
        _fullSyncRequested = false;
        final pendingIds = await NotificationService()
            .getPendingNotificationIds();
        _scheduledNotificationKeysById
          ..clear()
          ..addAll(unknownActivePrayerNotifications(pendingIds));
      }

      final now = DateTime.now();

      final requests = buildPrayerNotificationRequests(
        today: today,
        tomorrow: tomorrow,
        laterDays: _calculateLaterDays(
          location: location,
          settings: settings,
          timezoneName: timezoneName,
          now: now,
        ),
        now: now,
        enabledPrayerNotifications: settings.enabledPrayerNotifications,
        preNotificationMinutes: settings.preNotificationMinutes,
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
          notificationTime: request.notificationTime,
          location: locationStr,
          timezoneName: timezoneName,
          notificationId: request.notificationId,
          isReminder: request.isReminder,
          soundMode: settings.notificationSoundMode,
        );
        // Track progress so a failure part-way through does not forget what
        // was already scheduled.
        _scheduledNotificationKeysById[request.notificationId] =
            plan.desiredKeysById[request.notificationId]!;
      }

      _scheduledNotificationKeysById
        ..clear()
        ..addAll(plan.desiredKeysById);

      await NotificationService().recordScheduleSuccess(
        scheduledCount: plan.desiredKeysById.length,
        permissionStatus: readiness.status.name,
      );

      debugPrint(
        'Synced ${plan.desiredKeysById.length} prayer notifications for the '
        'next $prayerNotificationHorizonDays days',
      );
    } catch (e) {
      debugPrint('Error scheduling notifications: $e');
      await NotificationService().recordScheduleFailure(reason: e.toString());
    } finally {
      _schedulingInProgress = false;
      if (_rescheduleRequested && mounted) {
        _rescheduleRequested = false;
        await _scheduleAllNotifications();
      }
    }
  }

  /// Prayer times for day 2 onwards (today and tomorrow come from the prayer
  /// times provider), so notifications keep firing when the app is not
  /// opened for a few days.
  List<Map<String, DateTime?>> _calculateLaterDays({
    required LocationEntity location,
    required SettingsState settings,
    required String timezoneName,
    required DateTime now,
  }) {
    final days = <Map<String, DateTime?>>[];
    for (var day = 2; day < prayerNotificationHorizonDays; day++) {
      try {
        days.add(
          PrayerCalculationService.calculatePrayerTimes(
            latitude: location.latitude,
            longitude: location.longitude,
            date: now.add(Duration(days: day)),
            method: settings.calculationMethod,
            timezoneName: timezoneName,
            offsets: settings.prayerOffsets,
          ),
        );
      } catch (e) {
        // Stop at the first failure; earlier days are still scheduled.
        debugPrint('Could not calculate prayer times for day +$day: $e');
        break;
      }
    }
    return days;
  }

  Future<void> _scheduleNotification({
    required String prayerKey,
    required DateTime prayerTime,
    required DateTime notificationTime,
    required String location,
    required String timezoneName,
    required int notificationId,
    required bool isReminder,
    required String soundMode,
  }) async {
    try {
      final timeFormatter = DateFormat('HH:mm');
      final prayerTimeStr = timeFormatter.format(prayerTime);

      // Schedule notification at prayer time
      await NotificationService().schedulePrayerNotification(
        prayerKey: prayerKey,
        location: location,
        prayerTime: prayerTimeStr,
        notificationTime: notificationTime,
        timezoneName: timezoneName,
        notificationId: notificationId,
        isReminder: isReminder,
        soundMode: soundMode,
        refreshExactAlarmCapability: false,
        // Permission was already checked once for this sync; asking again
        // for each of up to 60 notifications is redundant.
        requestIosPermission: false,
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
