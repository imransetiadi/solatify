import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:solatify/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/settings/domain/repositories/settings_repository.dart';

// Data Source Provider
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((
  ref,
) {
  return const SettingsLocalDataSourceImpl();
});

// Repository Provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final localDataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(localDataSource: localDataSource);
});

// Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository) : super(_repository.getSettings());

  final SettingsRepository _repository;

  Future<void> updateTheme(ThemeMode mode) async {
    await _repository.updateThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> updateLanguage(String lang) async {
    final normalizedLang = lang == 'en' ? 'en' : 'id';
    await _repository.updateLanguage(normalizedLang);
    state = state.copyWith(language: normalizedLang);
  }

  Future<void> updateCalculationMethod(String method) async {
    await _repository.updateCalculationMethod(method);
    state = state.copyWith(calculationMethod: method);
  }

  Future<void> completeOnboarding() async {
    await _repository.completeOnboarding();
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> updatePrayerOffsets(String prayerKey, int minutes) async {
    final newOffsets = Map<String, int>.from(state.prayerOffsets);
    newOffsets[prayerKey] = minutes;
    await _repository.updatePrayerOffsets(newOffsets);
    state = state.copyWith(prayerOffsets: newOffsets);
  }

  Future<void> updateAdhanNotificationsEnabled(bool enabled) async {
    await _repository.updateAdhanNotificationsEnabled(enabled);
    state = state.copyWith(adhanNotificationsEnabled: enabled);
  }

  Future<void> syncAdhanNotificationsWithPermission(
    bool notificationsAllowed,
  ) async {
    if (!state.adhanNotificationsEnabled || notificationsAllowed) return;

    await _repository.updateAdhanNotificationsEnabled(false);
    state = state.copyWith(adhanNotificationsEnabled: false);
  }
}

// Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final repository = ref.watch(settingsRepositoryProvider);
    return SettingsNotifier(repository);
  },
);
