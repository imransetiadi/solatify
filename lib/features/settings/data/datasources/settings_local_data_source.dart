import 'package:flutter/material.dart';
import 'package:solatify/core/database/hive_service.dart';
import '../../domain/entities/settings_state.dart';

abstract class SettingsLocalDataSource {
  SettingsState getSettings();
  Future<void> updateThemeMode(ThemeMode mode);
  Future<void> updateLanguage(String language);
  Future<void> updateCalculationMethod(String method);
  Future<void> completeOnboarding();
  Future<void> updatePrayerOffsets(Map<String, int> offsets);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl();

  @override
  SettingsState getSettings() {
    try {
      final themeStr = HiveService.getSetting('theme', defaultValue: 'light')?.toString() ?? 'light';
      final rawLang = HiveService.getSetting('language', defaultValue: 'id')?.toString() ?? 'id';
      final lang = rawLang == 'en' ? 'en' : 'id';
      final method = (HiveService.getSetting('calculation_method', defaultValue: 'Kemenag') ?? 'Kemenag').toString();

      final rawOnboarding = HiveService.getSetting('onboarding_completed', defaultValue: false);
      final onboarding = rawOnboarding is bool ? rawOnboarding : false;

      final offsets = HiveService.getPrayerOffsets();

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
      );
    }
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
}
