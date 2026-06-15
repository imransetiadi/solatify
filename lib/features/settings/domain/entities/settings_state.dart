import 'package:flutter/material.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.language,
    required this.calculationMethod,
    required this.onboardingCompleted,
    required this.prayerOffsets,
  });

  final ThemeMode themeMode;
  final String language;
  final String calculationMethod;
  final bool onboardingCompleted;
  final Map<String, int> prayerOffsets;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? calculationMethod,
    bool? onboardingCompleted,
    Map<String, int>? prayerOffsets,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
    );
  }
}
