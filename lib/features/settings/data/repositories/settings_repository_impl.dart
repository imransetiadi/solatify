import 'package:flutter/material.dart';
import '../../domain/entities/settings_state.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

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
}
