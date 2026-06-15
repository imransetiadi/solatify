import 'package:flutter/material.dart';
import '../entities/settings_state.dart';

abstract class SettingsRepository {
  SettingsState getSettings();
  Future<void> updateThemeMode(ThemeMode mode);
  Future<void> updateLanguage(String language);
  Future<void> updateCalculationMethod(String method);
  Future<void> completeOnboarding();
  Future<void> updatePrayerOffsets(Map<String, int> offsets);
}
