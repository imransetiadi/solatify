import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/settings/domain/repositories/settings_repository.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

void main() {
  test(
    'syncAdhanNotificationsWithPermission turns setting off when denied',
    () async {
      final repository = _FakeSettingsRepository(
        const SettingsState(
          themeMode: ThemeMode.system,
          language: 'id',
          calculationMethod: 'Kemenag',
          onboardingCompleted: true,
          prayerOffsets: {
            'subuh': 0,
            'dzuhur': 0,
            'ashar': 0,
            'magrib': 0,
            'isya': 0,
          },
          adhanNotificationsEnabled: true,
        ),
      );
      final notifier = SettingsNotifier(repository);

      await notifier.syncAdhanNotificationsWithPermission(false);

      expect(notifier.state.adhanNotificationsEnabled, isFalse);
      expect(repository.savedAdhanNotificationsEnabled, isFalse);
    },
  );

  test(
    'syncAdhanNotificationsWithPermission keeps setting on when allowed',
    () async {
      final repository = _FakeSettingsRepository(
        const SettingsState(
          themeMode: ThemeMode.system,
          language: 'id',
          calculationMethod: 'Kemenag',
          onboardingCompleted: true,
          prayerOffsets: {
            'subuh': 0,
            'dzuhur': 0,
            'ashar': 0,
            'magrib': 0,
            'isya': 0,
          },
          adhanNotificationsEnabled: true,
        ),
      );
      final notifier = SettingsNotifier(repository);

      await notifier.syncAdhanNotificationsWithPermission(true);

      expect(notifier.state.adhanNotificationsEnabled, isTrue);
      expect(repository.savedAdhanNotificationsEnabled, isNull);
    },
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  SettingsState _settings;
  bool? savedAdhanNotificationsEnabled;

  @override
  SettingsState getSettings() => _settings;

  @override
  Future<void> updateThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
  }

  @override
  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
  }

  @override
  Future<void> updateCalculationMethod(String method) async {
    _settings = _settings.copyWith(calculationMethod: method);
  }

  @override
  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(onboardingCompleted: true);
  }

  @override
  Future<void> updatePrayerOffsets(Map<String, int> offsets) async {
    _settings = _settings.copyWith(prayerOffsets: offsets);
  }

  @override
  Future<void> updateAdhanNotificationsEnabled(bool enabled) async {
    savedAdhanNotificationsEnabled = enabled;
    _settings = _settings.copyWith(adhanNotificationsEnabled: enabled);
  }
}
