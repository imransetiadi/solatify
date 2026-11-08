import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_timezone_service.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_offsets.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';
import 'package:solatify/features/settings/presentation/widgets/prayer_offset_dialog.dart';
import 'package:solatify/features/settings/presentation/widgets/settings_choice_sheet.dart';
import 'package:solatify/features/settings/presentation/widgets/settings_tiles.dart';

export 'package:solatify/features/settings/presentation/widgets/prayer_offset_dialog.dart'
    show normalizePrayerOffsetInput, prayerOffsetInputFormatter;

enum PrayerOffsetType { subuh, dzuhur, ashar, magrib, isya }

/// Calculation methods offered in the picker (stored key -> display name).
const Map<String, String> _calculationMethods = {
  'Kemenag': 'Kemenag RI',
  'MWL': 'Muslim World League',
  'ISNA': 'ISNA (North America)',
  'Egypt': 'Egyptian General Authority',
  'Makkah': 'Umm al-Qura University, Makkah',
  'Singapore': 'MUIS Singapore',
};

class _NotificationV2Controls extends StatelessWidget {
  const _NotificationV2Controls({
    required this.settings,
    required this.onPrayerChanged,
    required this.onReminderChanged,
    required this.onSoundModeChanged,
  });

  final SettingsState settings;
  final Future<void> Function(String prayerKey, bool enabled) onPrayerChanged;
  final Future<void> Function(int minutes) onReminderChanged;
  final Future<void> Function(String mode) onSoundModeChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const prayerKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];
    const reminderOptions = [0, 5, 10, 15];
    final soundModes = {
      'adhan': l.adhanSoundMode,
      'beep': l.beepSoundMode,
      'silent': l.silentSoundMode,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SolatifySpacing.sm,
        SolatifySpacing.sm,
        SolatifySpacing.sm,
        SolatifySpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsSubheading(title: l.notificationPerPrayerTitle),
          const SizedBox(height: SolatifySpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prayerKeys.map((prayerKey) {
              final selected =
                  settings.enabledPrayerNotifications[prayerKey] != false;
              return FilterChip(
                label: Text(l.prayerName(prayerKey)),
                selected: selected,
                onSelected: (value) {
                  SolatifyHaptics.light();
                  onPrayerChanged(prayerKey, value);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: SolatifySpacing.md),
          SettingsSubheading(title: l.preNotificationReminder),
          const SizedBox(height: SolatifySpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reminderOptions.map((minutes) {
              final label = minutes == 0
                  ? l.noReminder
                  : '$minutes ${l.minutes}';
              return ChoiceChip(
                label: Text(label),
                selected: settings.preNotificationMinutes == minutes,
                onSelected: (_) {
                  SolatifyHaptics.selection();
                  onReminderChanged(minutes);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: SolatifySpacing.md),
          SettingsSubheading(title: l.notificationSoundMode),
          const SizedBox(height: SolatifySpacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: soundModes.entries.map((entry) {
              return ChoiceChip(
                label: Text(entry.value),
                selected: settings.notificationSoundMode == entry.key,
                onSelected: (_) {
                  SolatifyHaptics.selection();
                  onSoundModeChanged(entry.key);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

extension PrayerOffsetTypeExtension on PrayerOffsetType {
  String get nameId {
    switch (this) {
      case PrayerOffsetType.subuh:
        return 'Subuh';
      case PrayerOffsetType.dzuhur:
        return 'Dzuhur';
      case PrayerOffsetType.ashar:
        return 'Ashar';
      case PrayerOffsetType.magrib:
        return 'Magrib';
      case PrayerOffsetType.isya:
        return 'Isya';
    }
  }

  String get key {
    switch (this) {
      case PrayerOffsetType.subuh:
        return 'subuh';
      case PrayerOffsetType.dzuhur:
        return 'dzuhur';
      case PrayerOffsetType.ashar:
        return 'ashar';
      case PrayerOffsetType.magrib:
        return 'magrib';
      case PrayerOffsetType.isya:
        return 'isya';
    }
  }

  IconData get icon {
    switch (this) {
      case PrayerOffsetType.subuh:
        return Icons.wb_twilight_rounded;
      case PrayerOffsetType.dzuhur:
        return Icons.wb_sunny_outlined;
      case PrayerOffsetType.ashar:
        return Icons.filter_drama_outlined;
      case PrayerOffsetType.magrib:
        return Icons.nights_stay_outlined;
      case PrayerOffsetType.isya:
        return Icons.bedtime_outlined;
    }
  }
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAdhanNotificationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _verifyNotificationPermissionAfterReturn();
  }

  /// Today's times for the saved location and method, without any manual
  /// correction, so the dialog can preview and validate a new value.
  /// Null when they cannot be calculated; the dialog then edits blind.
  Map<String, DateTime>? _standardTimesToday(SettingsState settings) {
    try {
      final location = ref.read(locationProvider);
      return PrayerCalculationService.calculatePrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        date: DateTime.now(),
        method: settings.calculationMethod,
        timezoneName: PrayerTimezoneService.inferTimezoneName(
          latitude: location.latitude,
          longitude: location.longitude,
          country: location.country,
        ),
        offsets: const {},
      );
    } catch (e) {
      debugPrint('Could not calculate standard prayer times: $e');
      return null;
    }
  }

  Future<void> _showPrayerOffsetDialog(
    PrayerOffsetType prayer,
    int currentOffset,
  ) async {
    final l = AppLocalizations.of(context);
    final settings = ref.read(settingsProvider);
    SolatifyHaptics.selection();
    final offset = await showPrayerOffsetDialog(
      context: context,
      title: l.setPrayerOffset(l.prayerName(prayer.key)),
      prayerKey: prayer.key,
      initialOffset: currentOffset,
      standardTimes: _standardTimesToday(settings),
      offsets: settings.prayerOffsets,
    );
    if (offset == null || offset == currentOffset || !mounted) return;
    try {
      await ref
          .read(settingsProvider.notifier)
          .updatePrayerOffsets(prayer.key, offset);
    } catch (e) {
      debugPrint('Error saving prayer offset: $e');
      _showOffsetSaveError();
    }
  }

  Future<void> _resetPrayerOffsets() async {
    final l = AppLocalizations.of(context);
    SolatifyHaptics.selection();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l.isEnglish ? 'Reset all corrections?' : 'Kembalikan semua koreksi?',
        ),
        content: Text(
          l.isEnglish
              ? 'Every prayer goes back to the standard time of the selected '
                    'calculation method.'
              : 'Semua waktu salat kembali ke waktu standar metode '
                    'perhitungan yang dipilih.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.isEnglish ? 'Reset' : 'Kembalikan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(settingsProvider.notifier).resetPrayerOffsets();
    } catch (e) {
      debugPrint('Error resetting prayer offsets: $e');
      _showOffsetSaveError();
    }
  }

  void _showOffsetSaveError() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l.isEnglish
              ? 'The correction could not be saved. Your schedule is '
                    'unchanged; please try again.'
              : 'Koreksi gagal disimpan. Jadwalmu tidak berubah; silakan coba '
                    'lagi.',
        ),
      ),
    );
  }

  Future<void> _showCalculationMethodSheet(String currentMethod) async {
    final l = AppLocalizations.of(context);
    SolatifyHaptics.selection();
    final method = await showSettingsChoiceSheet<String>(
      context: context,
      title: l.calculationMethod,
      selected: currentMethod,
      choices: [
        for (final entry in _calculationMethods.entries)
          SettingsChoice(value: entry.key, label: entry.value),
      ],
    );
    if (method == null || method == currentMethod || !mounted) return;
    ref.read(settingsProvider.notifier).updateCalculationMethod(method);
  }

  Future<void> _showLanguageSheet(String currentLang) async {
    final l = AppLocalizations.of(context);
    SolatifyHaptics.selection();
    final lang = await showSettingsChoiceSheet<String>(
      context: context,
      title: l.chooseLanguage,
      selected: currentLang,
      choices: [
        SettingsChoice(value: 'id', label: l.indonesiaLanguage),
        SettingsChoice(value: 'en', label: l.englishLanguage),
      ],
    );
    if (lang == null || lang == currentLang || !mounted) return;
    ref.read(settingsProvider.notifier).updateLanguage(lang);
  }

  Future<void> _showThemeSheet(ThemeMode currentMode) async {
    final l = AppLocalizations.of(context);
    SolatifyHaptics.selection();
    final mode = await showSettingsChoiceSheet<ThemeMode>(
      context: context,
      title: l.appTheme,
      selected: currentMode,
      choices: [
        SettingsChoice(
          value: ThemeMode.light,
          label: l.lightTheme,
          icon: Icons.light_mode_outlined,
        ),
        SettingsChoice(
          value: ThemeMode.dark,
          label: l.darkTheme,
          icon: Icons.dark_mode_outlined,
        ),
        SettingsChoice(
          value: ThemeMode.system,
          label: l.systemTheme,
          icon: Icons.brightness_auto_outlined,
        ),
      ],
    );
    if (mode == null || mode == currentMode || !mounted) return;
    ref.read(settingsProvider.notifier).updateTheme(mode);
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l = AppLocalizations.of(context);

    final displayMethod =
        _calculationMethods[settings.calculationMethod] ??
        settings.calculationMethod;
    final displayLang = l.languageLabel(settings.language);
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final reliabilityMessage = defaultTargetPlatform == TargetPlatform.iOS
        ? l.iosNotificationReliabilityMessage
        : l.forceStopWarningMessage;
    final openSystemHint = l.isEnglish
        ? 'Opens system settings'
        : 'Membuka pengaturan sistem';

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveLayout.pagePadding(context).copyWith(
                top: ResponsiveLayout.pageTopGap,
                bottom: ResponsiveLayout.bottomSafeGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      l.navSettings,
                      style: TextStyle(
                        color: SolatifyColors.text(context),
                        fontSize: SolatifyType.pageTitle,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  // General
                  SettingsSectionHeader(
                    title: l.generalSettings,
                    icon: Icons.tune_rounded,
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: Icons.calculate_outlined,
                        title: l.calculationMethod,
                        value: displayMethod,
                        onTap: () => _showCalculationMethodSheet(
                          settings.calculationMethod,
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.translate_rounded,
                        title: l.language,
                        value: displayLang,
                        onTap: () => _showLanguageSheet(settings.language),
                      ),
                      SettingsTile(
                        icon: _themeIcon(settings.themeMode),
                        title: l.appTheme,
                        value: l.themeLabel(settings.themeMode),
                        onTap: () => _showThemeSheet(settings.themeMode),
                      ),
                    ],
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  // Adhan notifications
                  SettingsSectionHeader(
                    title: l.isEnglish
                        ? 'ADHAN NOTIFICATIONS'
                        : 'NOTIFIKASI ADZAN',
                    icon: Icons.notifications_none_rounded,
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  SettingsGroup(
                    children: [
                      SettingsSwitchTile(
                        icon: settings.adhanNotificationsEnabled
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        title: l.automaticAdhanNotifications,
                        description: l.automaticAdhanNotificationsDescription,
                        value: settings.adhanNotificationsEnabled,
                        onChanged: (enabled) {
                          SolatifyHaptics.light();
                          _toggleAdhanNotifications(context, ref, enabled);
                        },
                      ),
                      _NotificationV2Controls(
                        settings: settings,
                        onPrayerChanged: (prayerKey, enabled) async {
                          await ref
                              .read(settingsProvider.notifier)
                              .updateEnabledPrayerNotification(
                                prayerKey,
                                enabled,
                              );
                          await ref
                              .read(notificationSchedulerProvider.notifier)
                              .refreshSchedules(force: true);
                        },
                        onReminderChanged: (minutes) async {
                          await ref
                              .read(settingsProvider.notifier)
                              .updatePreNotificationMinutes(minutes);
                          await ref
                              .read(notificationSchedulerProvider.notifier)
                              .refreshSchedules(force: true);
                        },
                        onSoundModeChanged: (mode) async {
                          await ref
                              .read(settingsProvider.notifier)
                              .updateNotificationSoundMode(mode);
                          await ref
                              .read(notificationSchedulerProvider.notifier)
                              .refreshSchedules(force: true);
                        },
                      ),
                      SettingsTile(
                        icon: Icons.send_outlined,
                        title: l.sendTestNotificationTitle,
                        value: l.sendTestNotificationSubtitle,
                        valueMaxLines: null,
                        onTap: () async {
                          SolatifyHaptics.selection();
                          await _sendTestNotification(context, ref);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  // Reliability
                  SettingsSectionHeader(
                    title: l.notificationReliability,
                    icon: Icons.verified_user_outlined,
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: SolatifyColors.warning(context),
                        title: l.forceStopWarningTitle,
                        value: reliabilityMessage,
                        valueMaxLines: null,
                      ),
                      _buildSettingsShortcutTile(
                        title: l.openNotificationPermission,
                        icon: Icons.notifications_active_outlined,
                        hint: openSystemHint,
                        onTap: () => NotificationService()
                            .openPlatformNotificationSettings(),
                      ),
                      if (isAndroid) ...[
                        _buildSettingsShortcutTile(
                          title: l.openExactAlarmPermission,
                          icon: Icons.alarm_on_outlined,
                          hint: openSystemHint,
                          onTap: () => NotificationService()
                              .openAndroidExactAlarmSettings(),
                        ),
                        _buildSettingsShortcutTile(
                          title: l.openBatterySettings,
                          icon: Icons.battery_saver_outlined,
                          hint: openSystemHint,
                          onTap: () => NotificationService()
                              .openAndroidBatteryOptimizationSettings(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  // Prayer time correction
                  SettingsSectionHeader(
                    title: l.prayerTimeCorrection,
                    icon: Icons.more_time_rounded,
                    description: l.adjustOffsetHint,
                  ),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  if (_showIhtiyatNotice(settings)) ...[
                    _buildIhtiyatNotice(),
                    const SizedBox(height: ResponsiveLayout.itemGap),
                  ],
                  SettingsGroup(
                    children: [
                      for (final prayer in PrayerOffsetType.values)
                        _buildOffsetTile(
                          prayer,
                          settings.prayerOffsets[prayer.key] ?? 0,
                        ),
                    ],
                  ),
                  // The notice card has its own reset button.
                  if (hasActivePrayerOffsets(settings.prayerOffsets) &&
                      !_showIhtiyatNotice(settings)) ...[
                    const SizedBox(height: ResponsiveLayout.itemGap),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _resetPrayerOffsets,
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          size: SolatifyIconSize.inline,
                        ),
                        label: Text(
                          l.isEnglish
                              ? 'Reset all corrections'
                              : 'Kembalikan semua koreksi',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: ResponsiveLayout.bottomSafeGap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsShortcutTile({
    required String title,
    required IconData icon,
    required String hint,
    required Future<bool> Function() onTap,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      value: hint,
      semanticHint: hint,
      trailing: ExcludeSemantics(
        child: Icon(
          Icons.open_in_new_rounded,
          color: SolatifyColors.subtle(context),
          size: SolatifyIconSize.inline + 2,
        ),
      ),
      onTap: () async {
        SolatifyHaptics.selection();
        final opened = await onTap();
        if (opened || !mounted) return;

        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.notificationPermissionError)));
      },
    );
  }

  /// Kemenag times now include ihtiyat. Users who added minutes by hand to
  /// match Kemenag would now be that much later, so tell them once.
  bool _showIhtiyatNotice(SettingsState settings) =>
      !settings.ihtiyatNoticeDismissed &&
      hasActivePrayerOffsets(settings.prayerOffsets) &&
      PrayerCalculationService.standardFor(settings.calculationMethod) ==
          PrayerMethodStandard.kemenag;

  Widget _buildIhtiyatNotice() {
    final l = AppLocalizations.of(context);
    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      borderColor: SolatifyColors.warning(context).withValues(alpha: 0.45),
      padding: ResponsiveLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: SolatifyIconSize.cardIcon,
                color: SolatifyColors.warning(context),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Text(
                  l.isEnglish
                      ? 'Kemenag times now include the official ihtiyat '
                            '(2 to 3 minutes). If you added minutes yourself '
                            'to match Kemenag, set those corrections back to '
                            '0 so prayers are not later than the official '
                            'schedule.'
                      : 'Jadwal Kemenag kini sudah termasuk ihtiyat resmi '
                            '(2 sampai 3 menit). Kalau dulu kamu menambah '
                            'menit sendiri supaya sama dengan Kemenag, '
                            'kembalikan koreksinya ke 0 agar waktu salat tidak '
                            'lebih lambat dari jadwal resmi.',
                  style: TextStyle(
                    color: SolatifyColors.text(context),
                    fontSize: SolatifyType.body,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.sm),
          Wrap(
            spacing: SolatifySpacing.sm,
            children: [
              TextButton(
                onPressed: _resetPrayerOffsets,
                child: Text(
                  l.isEnglish
                      ? 'Reset all corrections'
                      : 'Kembalikan semua koreksi',
                ),
              ),
              TextButton(
                onPressed: _dismissIhtiyatNotice,
                child: Text(l.isEnglish ? 'Keep my corrections' : 'Biarkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _dismissIhtiyatNotice() async {
    SolatifyHaptics.selection();
    try {
      await ref.read(settingsProvider.notifier).dismissIhtiyatNotice();
    } catch (e) {
      debugPrint('Error saving ihtiyat notice state: $e');
    }
  }

  Widget _buildOffsetTile(PrayerOffsetType prayer, int offset) {
    final l = AppLocalizations.of(context);
    final prayerName = l.prayerName(prayer.key);

    return SettingsTile(
      icon: prayer.icon,
      title: l.prayerCorrectionTitle(prayerName),
      value: formatPrayerOffset(l, offset),
      highlightValue: offset != 0,
      semanticHint: l.setPrayerOffset(prayerName),
      onTap: () => _showPrayerOffsetDialog(prayer, offset),
    );
  }

  Future<void> _toggleAdhanNotifications(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);

    try {
      if (!enabled) {
        // Turning the adhan off only cancels this app's prayer alarms; it
        // must not send users to the system settings, where they might turn
        // off all of the app's notifications.
        await ref
            .read(notificationSchedulerProvider.notifier)
            .cancelAllNotifications();
        await ref
            .read(settingsProvider.notifier)
            .updateAdhanNotificationsEnabled(false);
        return;
      }

      // Ask for permission only when it is missing; open the system
      // settings only when it was refused.
      final granted = await NotificationService()
          .ensureNotificationPermission();
      if (!granted) {
        final opened = await NotificationService()
            .openPlatformNotificationSettings();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              opened
                  ? l.notificationPermissionSettingsHint
                  : l.notificationPermissionError,
            ),
          ),
        );
        return;
      }

      await ref
          .read(settingsProvider.notifier)
          .updateAdhanNotificationsEnabled(true);
      await ref
          .read(notificationSchedulerProvider.notifier)
          .refreshSchedules(force: true);
    } catch (e) {
      debugPrint('Error toggling automatic adhan notifications: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.notificationPermissionError)),
      );
    }
  }

  Future<void> _sendTestNotification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    final notificationService = NotificationService();

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final granted = await notificationService.requestIosPermissions();
        if (!granted) {
          await notificationService.openPlatformNotificationSettings();
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(content: Text(l.notificationPermissionSettingsHint)),
          );
          return;
        }
      }

      messenger.showSnackBar(
        SnackBar(content: Text(l.sendTestNotificationInProgress)),
      );

      await notificationService.showTestNotification();
      await ref
          .read(notificationSchedulerProvider.notifier)
          .refreshSchedules(force: true);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.notificationHealthTestSent)),
      );
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l.notificationPermissionError)),
      );
    }
  }

  Future<void> _syncAdhanNotificationPermission() async {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    if (!settings.adhanNotificationsEnabled) return;

    final notificationsAllowed = await _areAdhanNotificationsAllowed();
    if (!mounted || notificationsAllowed) return;

    await ref
        .read(settingsProvider.notifier)
        .syncAdhanNotificationsWithPermission(false);
    await ref
        .read(notificationSchedulerProvider.notifier)
        .cancelAllNotifications();
  }

  Future<void> _verifyNotificationPermissionAfterReturn() async {
    if (!mounted) return;
    final settings = ref.read(settingsProvider);
    if (!settings.adhanNotificationsEnabled) return;

    final notificationsAllowed = await _areAdhanNotificationsAllowed();
    if (!mounted) return;

    if (notificationsAllowed) {
      await ref
          .read(notificationSchedulerProvider.notifier)
          .refreshSchedules(force: true);
      return;
    }

    await ref
        .read(settingsProvider.notifier)
        .syncAdhanNotificationsWithPermission(false);
    await ref
        .read(notificationSchedulerProvider.notifier)
        .cancelAllNotifications();
  }

  Future<bool> _areAdhanNotificationsAllowed() async {
    final readiness = await NotificationService().getReadinessStatus();
    return readiness.status !=
        NotificationReadinessStatus.needsNotificationPermission;
  }
}
