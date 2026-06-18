import 'package:flutter/material.dart';
import 'package:solatify/core/database/hive_service.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';

abstract class SettingsLocalDataSource {
  SettingsState getSettings();
  Future<void> updateThemeMode(ThemeMode mode);
  Future<void> updateLanguage(String language);
  Future<void> updateCalculationMethod(String method);
  Future<void> completeOnboarding();
  Future<void> updatePrayerOffsets(Map<String, int> offsets);
  Future<void> updateAdhanNotificationsEnabled(bool enabled);
  Future<void> updateEnabledPrayerNotifications(Map<String, bool> enabled);
  Future<void> updatePreNotificationMinutes(int minutes);
  Future<void> updateNotificationSoundMode(String mode);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl();

  @override
  SettingsState getSettings() {
    try {
      final themeStr =
          HiveService.getSetting('theme', defaultValue: 'light')?.toString() ??
          'light';
      final rawLang =
          HiveService.getSetting('language', defaultValue: 'id')?.toString() ??
          'id';
      final lang = rawLang == 'en' ? 'en' : 'id';
      final method =
          (HiveService.getSetting(
                    'calculation_method',
                    defaultValue: 'Kemenag',
                  ) ??
                  'Kemenag')
              .toString();

      final rawOnboarding = HiveService.getSetting(
        'onboarding_completed',
        defaultValue: false,
      );
      final onboarding = rawOnboarding is bool ? rawOnboarding : false;

      final offsets = HiveService.getPrayerOffsets();
      final rawAdhanNotificationsEnabled = HiveService.getSetting(
        'adhan_notifications_enabled',
        defaultValue: false,
      );
      final adhanNotificationsEnabled = rawAdhanNotificationsEnabled is bool
          ? rawAdhanNotificationsEnabled
          : false;
      final enabledPrayerNotifications = _readEnabledPrayerNotifications();
      final preNotificationMinutes = _readPreNotificationMinutes();
      final notificationSoundMode = _readNotificationSoundMode();

      ThemeMode themeMode;
      switch (themeStr) {
        case 'light':
          themeMode = ThemeMode.light;
          break;
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        default:
          themeMode = ThemeMode.system;
      }

      return SettingsState(
        themeMode: themeMode,
        language: lang,
        calculationMethod: method,
        onboardingCompleted: onboarding,
        prayerOffsets: offsets,
        adhanNotificationsEnabled: adhanNotificationsEnabled,
        enabledPrayerNotifications: enabledPrayerNotifications,
        preNotificationMinutes: preNotificationMinutes,
        notificationSoundMode: notificationSoundMode,
      );
    } catch (e) {
      return const SettingsState(
        themeMode: ThemeMode.system,
        language: 'id',
        calculationMethod: 'Kemenag',
        onboardingCompleted: false,
        prayerOffsets: {
          'subuh': 0,
          'dzuhur': 0,
          'ashar': 0,
          'magrib': 0,
          'isya': 0,
        },
        adhanNotificationsEnabled: false,
      );
    }
  }

  Map<String, bool> _readEnabledPrayerNotifications() {
    final raw = HiveService.getSetting(
      'enabled_prayer_notifications',
      defaultValue: SettingsState.defaultEnabledPrayerNotifications,
    );
    if (raw is! Map) return SettingsState.defaultEnabledPrayerNotifications;

    return {
      for (final entry
          in SettingsState.defaultEnabledPrayerNotifications.entries)
        entry.key: raw[entry.key] is bool
            ? raw[entry.key] as bool
            : entry.value,
    };
  }

  int _readPreNotificationMinutes() {
    final raw = HiveService.getSetting(
      'pre_notification_minutes',
      defaultValue: SettingsState.defaultPreNotificationMinutes,
    );
    if (raw is int && const {0, 5, 10, 15}.contains(raw)) return raw;
    return SettingsState.defaultPreNotificationMinutes;
  }

  String _readNotificationSoundMode() {
    final raw = HiveService.getSetting(
      'notification_sound_mode',
      defaultValue: SettingsState.defaultNotificationSoundMode,
    )?.toString();
    if (const {'adhan', 'beep', 'silent'}.contains(raw)) return raw!;
    return SettingsState.defaultNotificationSoundMode;
  }

  @override
  Future<void> updateThemeMode(ThemeMode mode) async {
    String themeStr;
    switch (mode) {
      case ThemeMode.light:
        themeStr = 'light';
        break;
      case ThemeMode.dark:
        themeStr = 'dark';
        break;
      case ThemeMode.system:
        themeStr = 'system';
    }
    await HiveService.saveSetting('theme', themeStr);
  }

  @override
  Future<void> updateLanguage(String language) async {
    final normalizedLang = language == 'en' ? 'en' : 'id';
    await HiveService.saveSetting('language', normalizedLang);
  }

  @override
  Future<void> updateCalculationMethod(String method) async {
    await HiveService.saveSetting('calculation_method', method);
  }

  @override
  Future<void> completeOnboarding() async {
    await HiveService.saveSetting('onboarding_completed', true);
  }

  @override
  Future<void> updatePrayerOffsets(Map<String, int> offsets) async {
    await HiveService.savePrayerOffsets(offsets);
  }

  @override
  Future<void> updateAdhanNotificationsEnabled(bool enabled) async {
    await HiveService.saveSetting('adhan_notifications_enabled', enabled);
  }

  @override
  Future<void> updateEnabledPrayerNotifications(
    Map<String, bool> enabled,
  ) async {
    await HiveService.saveSetting('enabled_prayer_notifications', enabled);
  }

  @override
  Future<void> updatePreNotificationMinutes(int minutes) async {
    await HiveService.saveSetting('pre_notification_minutes', minutes);
  }

  @override
  Future<void> updateNotificationSoundMode(String mode) async {
    await HiveService.saveSetting('notification_sound_mode', mode);
  }
}
