import 'package:flutter/material.dart';
import 'package:solatify/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({required this.localDataSource});

  final SettingsLocalDataSource localDataSource;

  @override
  SettingsState getSettings() {
    return localDataSource.getSettings();
  }

  @override
  Future<void> updateThemeMode(ThemeMode mode) {
    return localDataSource.updateThemeMode(mode);
  }

  @override
  Future<void> updateLanguage(String language) {
    return localDataSource.updateLanguage(language);
  }

  @override
  Future<void> updateCalculationMethod(String method) {
    return localDataSource.updateCalculationMethod(method);
  }

  @override
  Future<void> completeOnboarding() {
    return localDataSource.completeOnboarding();
  }

  @override
  Future<void> updatePrayerOffsets(Map<String, int> offsets) {
    return localDataSource.updatePrayerOffsets(offsets);
  }

  @override
  Future<void> updateAdhanNotificationsEnabled(bool enabled) {
    return localDataSource.updateAdhanNotificationsEnabled(enabled);
  }

  @override
  Future<void> updateEnabledPrayerNotifications(Map<String, bool> enabled) {
    return localDataSource.updateEnabledPrayerNotifications(enabled);
  }

  @override
  Future<void> updatePreNotificationMinutes(int minutes) {
    return localDataSource.updatePreNotificationMinutes(minutes);
  }

  @override
  Future<void> updateNotificationSoundMode(String mode) {
    return localDataSource.updateNotificationSoundMode(mode);
  }
}
