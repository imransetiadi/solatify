import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String language;
  final String calculationMethod;
  final bool onboardingCompleted;
  final Map<String, int> prayerOffsets;

  SettingsState({
    required this.themeMode,
    required this.language,
    required this.calculationMethod,
    required this.onboardingCompleted,
    required this.prayerOffsets,
  });

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

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(_initialState());

  static SettingsState _initialState() {
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
      return SettingsState(
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
    final normalizedLang = lang == 'en' ? 'en' : 'id';
    await HiveService.saveSetting('language', normalizedLang);
    state = state.copyWith(language: normalizedLang);
  }

  Future<void> updateCalculationMethod(String method) async {
    await HiveService.saveSetting('calculation_method', method);
    state = state.copyWith(calculationMethod: method);
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
