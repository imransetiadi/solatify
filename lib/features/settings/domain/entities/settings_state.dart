import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.language,
    required this.calculationMethod,
    required this.onboardingCompleted,
    required this.prayerOffsets,
    required this.adhanNotificationsEnabled,
  });

  final ThemeMode themeMode;
  final String language;
  final String calculationMethod;
  final bool onboardingCompleted;
  final Map<String, int> prayerOffsets;
  final bool adhanNotificationsEnabled;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? calculationMethod,
    bool? onboardingCompleted,
    Map<String, int>? prayerOffsets,
    bool? adhanNotificationsEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
      adhanNotificationsEnabled:
          adhanNotificationsEnabled ?? this.adhanNotificationsEnabled,
    );
  }
}
