import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.language,
    required this.calculationMethod,
    required this.onboardingCompleted,
    required this.prayerOffsets,
    required this.adhanNotificationsEnabled,
    this.enabledPrayerNotifications = defaultEnabledPrayerNotifications,
    this.preNotificationMinutes = defaultPreNotificationMinutes,
    this.notificationSoundMode = defaultNotificationSoundMode,
  });

  static const Map<String, bool> defaultEnabledPrayerNotifications = {
    'subuh': true,
    'dzuhur': true,
    'ashar': true,
    'magrib': true,
    'isya': true,
  };
  static const int defaultPreNotificationMinutes = 0;
  static const String defaultNotificationSoundMode = 'adhan';

  final ThemeMode themeMode;
  final String language;
  final String calculationMethod;
  final bool onboardingCompleted;
  final Map<String, int> prayerOffsets;
  final bool adhanNotificationsEnabled;
  final Map<String, bool> enabledPrayerNotifications;
  final int preNotificationMinutes;
  final String notificationSoundMode;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? calculationMethod,
    bool? onboardingCompleted,
    Map<String, int>? prayerOffsets,
    bool? adhanNotificationsEnabled,
    Map<String, bool>? enabledPrayerNotifications,
    int? preNotificationMinutes,
    String? notificationSoundMode,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
      adhanNotificationsEnabled:
          adhanNotificationsEnabled ?? this.adhanNotificationsEnabled,
      enabledPrayerNotifications:
          enabledPrayerNotifications ?? this.enabledPrayerNotifications,
      preNotificationMinutes:
          preNotificationMinutes ?? this.preNotificationMinutes,
      notificationSoundMode:
          notificationSoundMode ?? this.notificationSoundMode,
    );
  }
}
