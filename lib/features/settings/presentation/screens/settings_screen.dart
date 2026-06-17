import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_hero_card.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/notifications/presentation/providers/notification_scheduler_provider.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

enum PrayerOffsetType { subuh, dzuhur, ashar, magrib, isya }

int normalizePrayerOffsetInput(String value) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null) return 0;
  return parsed.clamp(-60, 60).toInt();
}

final prayerOffsetInputFormatter = TextInputFormatter.withFunction((
  oldValue,
  newValue,
) {
  final text = newValue.text;
  if (text.isEmpty || text == '-' || RegExp(r'^-?\d{1,2}$').hasMatch(text)) {
    return newValue;
  }

  if (RegExp(r'^-?60$').hasMatch(text)) return newValue;
  return oldValue;
});

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
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAdhanNotificationPermission();
    });
  }

  void _showPrayerOffsetDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerOffsetType prayer,
    int currentOffset,
  ) {
    final l = AppLocalizations.of(context);
    int selectedOffset = currentOffset;
    final controller = TextEditingController(text: currentOffset.toString());
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkTheme ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDarkTheme ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDarkTheme
        ? const Color(0xFFB8A898)
        : const Color(0xFF6A5B51);
    final primaryColor = AppTheme.readableAccent(context);
    final controlBg = primaryColor.withValues(alpha: isDarkTheme ? 0.16 : 0.10);
    final controlBorder = primaryColor.withValues(
      alpha: isDarkTheme ? 0.34 : 0.24,
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                l.setPrayerOffset(l.prayerName(prayer.key)),
                style: TextStyle(color: textColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.adjustOffsetHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textMuted, height: 1.35),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.prayerOffsetLimitHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    inputFormatters: [prayerOffsetInputFormatter],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SolatifyType.heroTitle,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      suffixText: l.minutes,
                      suffixStyle: TextStyle(color: textMuted),
                      helperText: l.offsetNegativeHint,
                      helperStyle: TextStyle(
                        color: textMuted,
                        fontSize: SolatifyType.eyebrow,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: primaryColor.withValues(alpha: 0.35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onChanged: (value) {
                      selectedOffset = normalizePrayerOffsetInput(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOffsetControlButton(
                          icon: Icons.remove,
                          backgroundColor: controlBg,
                          borderColor: controlBorder,
                          iconColor: primaryColor,
                          onPressed: () {
                            stfSetState(() {
                              selectedOffset = (selectedOffset - 1).clamp(
                                -60,
                                60,
                              );
                              controller.text = selectedOffset.toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOffsetControlButton(
                          icon: Icons.add,
                          backgroundColor: controlBg,
                          borderColor: controlBorder,
                          iconColor: primaryColor,
                          onPressed: () {
                            stfSetState(() {
                              selectedOffset = (selectedOffset + 1).clamp(
                                -60,
                                60,
                              );
                              controller.text = selectedOffset.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          l.cancel,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final offset = normalizePrayerOffsetInput(
                            controller.text,
                          );
                          await ref
                              .read(settingsProvider.notifier)
                              .updatePrayerOffsets(prayer.key, offset);
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                        },
                        child: Text(l.save),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCalculationMethodDialog(
    BuildContext context,
    WidgetRef ref,
    String currentMethod,
  ) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final accentColor = AppTheme.readableAccent(context);

    final methods = {
      'Kemenag': 'Kemenag RI',
      'MWL': 'Muslim World League',
      'ISNA': 'ISNA (North America)',
      'Egypt': 'Egyptian General Authority',
      'Makkah': 'Umm al-Qura University, Makkah',
      'Singapore': 'MUIS Singapore',
    };

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(l.calculationMethod, style: TextStyle(color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: methods.entries.map((entry) {
                return ListTile(
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                  leading: Icon(
                    currentMethod == entry.key
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: accentColor,
                  ),
                  onTap: () {
                    ref
                        .read(settingsProvider.notifier)
                        .updateCalculationMethod(entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final accentColor = AppTheme.readableAccent(context);

    final langs = {'id': 'Bahasa Indonesia', 'en': 'English'};

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(l.language, style: TextStyle(color: textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: langs.entries.map((entry) {
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: SolatifyType.body,
                  ),
                ),
                leading: Icon(
                  currentLang == entry.key
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: accentColor,
                ),
                onTap: () {
                  ref.read(settingsProvider.notifier).updateLanguage(entry.key);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l = AppLocalizations.of(context);

    final String displayMethod = settings.calculationMethod;
    final String displayLang = l.languageLabel(settings.language);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFFAFA19A);
    final accentColor = AppTheme.readableAccent(context);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final reliabilityMessage = defaultTargetPlatform == TargetPlatform.iOS
        ? l.iosNotificationReliabilityMessage
        : l.forceStopWarningMessage;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SolatifyHeroCard(
                    eyebrow: l.navSettings,
                    title: l.navSettings,
                    subtitle:
                        'Atur metode jadwal, bahasa, tema, notifikasi, dan koreksi waktu salat dari satu tempat.',
                    icon: Icons.tune_rounded,
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  _buildSectionHeader(context, l.generalSettings),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  GlassContainer(
                    opacity: isDark ? 0.04 : 0.02,
                    borderRadius: 24,
                    padding: ResponsiveLayout.cardPadding,
                    child: Column(
                      children: [
                        // Method selection
                        ListTile(
                          title: Text(
                            l.calculationMethod,
                            style: TextStyle(
                              color: textColor,
                              fontSize: SolatifyType.body,
                            ),
                          ),
                          subtitle: Text(
                            displayMethod,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: SolatifyType.caption,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: textSecondary,
                          ),
                          onTap: () => _showCalculationMethodDialog(
                            context,
                            ref,
                            settings.calculationMethod,
                          ),
                        ),
                        Divider(color: dividerColor, height: 16),
                        // Language
                        ListTile(
                          title: Text(
                            l.language,
                            style: TextStyle(
                              color: textColor,
                              fontSize: SolatifyType.body,
                            ),
                          ),
                          subtitle: Text(
                            displayLang,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: SolatifyType.caption,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: textSecondary,
                          ),
                          onTap: () => _showLanguageDialog(
                            context,
                            ref,
                            settings.language,
                          ),
                        ),
                        Divider(color: dividerColor, height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.automaticAdhanNotifications,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: SolatifyType.body,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      l.automaticAdhanNotificationsDescription,
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: SolatifyType.caption,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Switch.adaptive(
                                value: settings.adhanNotificationsEnabled,
                                activeThumbColor: accentColor,
                                onChanged: (enabled) =>
                                    _toggleAdhanNotifications(
                                      context,
                                      ref,
                                      enabled,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: dividerColor, height: 16),
                        // Theme toggles
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  l.appTheme,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: SolatifyType.body,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  _buildThemeButton(
                                    context,
                                    ref,
                                    ThemeMode.light,
                                    Icons.light_mode,
                                    settings.themeMode,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildThemeButton(
                                    context,
                                    ref,
                                    ThemeMode.dark,
                                    Icons.dark_mode,
                                    settings.themeMode,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  _buildSectionHeader(context, l.notificationReliability),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  GlassContainer(
                    opacity: isDark ? 0.04 : 0.02,
                    borderRadius: 24,
                    padding: ResponsiveLayout.cardPadding,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.info_outline, color: accentColor),
                          title: Text(
                            l.forceStopWarningTitle,
                            style: TextStyle(
                              color: textColor,
                              fontSize: SolatifyType.body,
                            ),
                          ),
                          subtitle: Text(
                            reliabilityMessage,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: SolatifyType.caption,
                            ),
                          ),
                        ),
                        Divider(color: dividerColor, height: 16),
                        _buildSettingsShortcutTile(
                          title: l.openNotificationPermission,
                          icon: Icons.notifications_active_outlined,
                          textColor: textColor,
                          textSecondary: textSecondary,
                          onTap: () => NotificationService()
                              .openPlatformNotificationSettings(),
                        ),
                        if (isAndroid) ...[
                          Divider(color: dividerColor, height: 16),
                          _buildSettingsShortcutTile(
                            title: l.openExactAlarmPermission,
                            icon: Icons.alarm_on_outlined,
                            textColor: textColor,
                            textSecondary: textSecondary,
                            onTap: () => NotificationService()
                                .openAndroidExactAlarmSettings(),
                          ),
                          Divider(color: dividerColor, height: 16),
                          _buildSettingsShortcutTile(
                            title: l.openBatterySettings,
                            icon: Icons.battery_saver_outlined,
                            textColor: textColor,
                            textSecondary: textSecondary,
                            onTap: () => NotificationService()
                                .openAndroidBatteryOptimizationSettings(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: ResponsiveLayout.sectionGap),

                  _buildSectionHeader(context, l.prayerTimeCorrection),
                  const SizedBox(height: ResponsiveLayout.itemGap),
                  GlassContainer(
                    opacity: isDark ? 0.04 : 0.02,
                    borderRadius: 24,
                    padding: ResponsiveLayout.cardPadding,
                    child: Column(
                      children: [
                        _buildOffsetTile(
                          context,
                          ref,
                          PrayerOffsetType.subuh,
                          settings.prayerOffsets['subuh'] ?? 0,
                          textColor,
                          textSecondary,
                        ),
                        Divider(color: dividerColor, height: 16),
                        _buildOffsetTile(
                          context,
                          ref,
                          PrayerOffsetType.dzuhur,
                          settings.prayerOffsets['dzuhur'] ?? 0,
                          textColor,
                          textSecondary,
                        ),
                        Divider(color: dividerColor, height: 16),
                        _buildOffsetTile(
                          context,
                          ref,
                          PrayerOffsetType.ashar,
                          settings.prayerOffsets['ashar'] ?? 0,
                          textColor,
                          textSecondary,
                        ),
                        Divider(color: dividerColor, height: 16),
                        _buildOffsetTile(
                          context,
                          ref,
                          PrayerOffsetType.magrib,
                          settings.prayerOffsets['magrib'] ?? 0,
                          textColor,
                          textSecondary,
                        ),
                        Divider(color: dividerColor, height: 16),
                        _buildOffsetTile(
                          context,
                          ref,
                          PrayerOffsetType.isya,
                          settings.prayerOffsets['isya'] ?? 0,
                          textColor,
                          textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ResponsiveLayout.bottomSafeGap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFFAFA19A);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: SolatifyType.body,
          fontWeight: FontWeight.bold,
          color: textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildOffsetControlButton({
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: iconColor, size: SolatifyIconSize.cardIcon),
      ),
    );
  }

  Widget _buildSettingsShortcutTile({
    required String title,
    required IconData icon,
    required Color textColor,
    required Color textSecondary,
    required Future<bool> Function() onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: textSecondary),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: SolatifyType.body),
      ),
      trailing: Icon(
        Icons.open_in_new,
        color: textSecondary,
        size: SolatifyIconSize.inline,
      ),
      onTap: () async {
        final opened = await onTap();
        if (opened || !mounted) return;

        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.notificationPermissionError)));
      },
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
      if (enabled) {
        final opened = await NotificationService()
            .openPlatformNotificationSettings();
        if (!opened) {
          messenger.showSnackBar(
            SnackBar(content: Text(l.notificationPermissionError)),
          );
          return;
        }
      } else {
        await ref
            .read(notificationSchedulerProvider.notifier)
            .cancelAllNotifications();
      }

      await ref
          .read(settingsProvider.notifier)
          .updateAdhanNotificationsEnabled(enabled);

      if (enabled) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.notificationPermissionSettingsHint)),
        );
      } else {
        final opened = await NotificationService()
            .openPlatformNotificationSettings();
        if (!opened) return;
        messenger.showSnackBar(
          SnackBar(content: Text(l.notificationPermissionSettingsHint)),
        );
      }
    } catch (e) {
      debugPrint('Error toggling automatic adhan notifications: $e');
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

  Future<bool> _areAdhanNotificationsAllowed() async {
    final readiness = await NotificationService().getReadinessStatus();
    return readiness.status !=
        NotificationReadinessStatus.needsNotificationPermission;
  }

  Widget _buildThemeButton(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
    IconData icon,
    ThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.tertiary;
    final unselectedBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    final unselectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final iconColor = isSelected
        ? Colors.black
        : (isDark ? const Color(0xFFC8B8A8) : const Color(0xFFAFA19A));
    return GestureDetector(
      onTap: () => ref.read(settingsProvider.notifier).updateTheme(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : unselectedBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? accentColor : unselectedBorder,
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: iconColor, size: SolatifyIconSize.inline),
      ),
    );
  }

  Widget _buildOffsetTile(
    BuildContext context,
    WidgetRef ref,
    PrayerOffsetType prayer,
    int offset,
    Color textColor,
    Color textSecondary,
  ) {
    final l = AppLocalizations.of(context);
    final primaryColor = AppTheme.readableAccent(context);

    return ListTile(
      title: Text(
        l.isEnglish
            ? '${l.prayerName(prayer.key)} Offset'
            : '${l.prayerName(prayer.key)} Ofset',
        style: TextStyle(color: textColor, fontSize: SolatifyType.body),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${offset > 0 ? '+' : ''}$offset ${l.minutes}',
            style: TextStyle(
              color: primaryColor,
              fontSize: SolatifyType.caption,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: textSecondary),
        ],
      ),
      onTap: () => _showPrayerOffsetDialog(context, ref, prayer, offset),
    );
  }
}
