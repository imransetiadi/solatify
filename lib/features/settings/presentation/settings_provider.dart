import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final String calculationMethod;
  final bool notificationEnabled;
  final String adhanSound;
  final bool onboardingCompleted;
  final Map<String, int> prayerOffsets;

  SettingsState({
    required this.themeMode,
    required this.language,
    required this.calculationMethod,
    required this.notificationEnabled,
    required this.adhanSound,
    required this.onboardingCompleted,
    required this.prayerOffsets,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? language,
    String? calculationMethod,
    bool? notificationEnabled,
    String? adhanSound,
    bool? onboardingCompleted,
    Map<String, int>? prayerOffsets,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      adhanSound: adhanSound ?? this.adhanSound,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      prayerOffsets: prayerOffsets ?? this.prayerOffsets,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(_initialState());

  static SettingsState _initialState() {
    final themeStr = HiveService.getSetting('theme', defaultValue: 'light');
    final lang = HiveService.getSetting('language', defaultValue: 'id');
    final method = HiveService.getSetting(
      'calculation_method',
      defaultValue: 'Kemenag',
    ); // Default Kemenag/Singapore method
    final notif = HiveService.getSetting(
      'notification_enabled',
      defaultValue: true,
    );
    final adhan = HiveService.getSetting(
      'adhan_sound',
      defaultValue: 'default',
    );
    final onboarding = HiveService.getSetting(
      'onboarding_completed',
      defaultValue: false,
    );
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
      notificationEnabled: notif,
      adhanSound: adhan,
      onboardingCompleted: onboarding,
      prayerOffsets: offsets,
    );
  }

  Future<void> updateTheme(ThemeMode mode) async {
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
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateLanguage(String lang) async {
    await HiveService.saveSetting('language', lang);
    state = state.copyWith(language: lang);
  }

  Future<void> updateCalculationMethod(String method) async {
    await HiveService.saveSetting('calculation_method', method);
    state = state.copyWith(calculationMethod: method);
  }

  Future<void> updateNotificationEnabled(bool enabled) async {
    await HiveService.saveSetting('notification_enabled', enabled);
    state = state.copyWith(notificationEnabled: enabled);
  }

  Future<void> updateAdhanSound(String adhan) async {
    await HiveService.saveSetting('adhan_sound', adhan);
    state = state.copyWith(adhanSound: adhan);
  }

  Future<void> completeOnboarding() async {
    await HiveService.saveSetting('onboarding_completed', true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> updatePrayerOffsets(String prayerKey, int minutes) async {
    final newOffsets = Map<String, int>.from(state.prayerOffsets);
    newOffsets[prayerKey] = minutes;
    await HiveService.savePrayerOffsets(newOffsets);
    state = state.copyWith(prayerOffsets: newOffsets);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
