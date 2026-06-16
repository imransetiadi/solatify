import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

enum PrayerOffsetType { subuh, dzuhur, ashar, magrib, isya }

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
  final NotificationService _notificationService = NotificationService();
  late final ValueNotifier<NotificationReadiness> _notificationReadiness;
  final ValueNotifier<String> _notificationActionStatus = ValueNotifier<String>(
    'Belum ada status aksi.',
  );
  final ValueNotifier<int> _pendingNotificationCount = ValueNotifier<int>(0);
  bool _isNotificationActionRunning = false;

  @override
  void initState() {
    super.initState();
    _notificationReadiness = ValueNotifier<NotificationReadiness>(
      NotificationReadiness.unknown(),
    );
    _refreshNotificationReadiness();
  }

  @override
  void dispose() {
    _notificationReadiness.dispose();
    _notificationActionStatus.dispose();
    _pendingNotificationCount.dispose();
    super.dispose();
  }

  Future<void> _refreshNotificationReadiness() async {
    final readiness = await _notificationService.getReadinessStatus();
    final pendingCount = await _notificationService
        .getPendingNotificationsCount();
    if (!mounted) return;
    _notificationReadiness.value = readiness;
    _pendingNotificationCount.value = pendingCount;
  }

  Future<void> _runNotificationAction(Future<void> Function() action) async {
    if (_isNotificationActionRunning) return;

    setState(() {
      _isNotificationActionRunning = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isNotificationActionRunning = false;
        });
      }
    }
  }

  Future<void> _requestNotificationPermissions() async {
    await _runNotificationAction(() async {
      try {
        final before = _notificationReadiness.value;
        await _notificationService.requestAndroidPermissions();
        await _refreshNotificationReadiness();
        final after = _notificationReadiness.value;

        final message = after.status == NotificationReadinessStatus.ready
            ? 'Notifikasi sudah aktif.'
            : after.title;
        _notificationActionStatus.value = message;

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        debugPrint(
          'Notification permission action: before=${before.status.name}, after=${after.status.name}',
        );
      } catch (e) {
        debugPrint('Error requesting notification permissions: $e');
        _notificationActionStatus.value =
            'Izin notifikasi belum dapat diperbarui.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi belum dapat diperbarui.'),
          ),
        );
      }
    });
  }

  Future<void> _sendTestNotification() async {
    await _runNotificationAction(() async {
      try {
        await _notificationService.showTestNotification();
        _notificationActionStatus.value = 'Tes terkirim.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi uji dikirim.')),
        );
        await _refreshNotificationReadiness();
      } catch (e) {
        debugPrint('Error sending test notification from settings: $e');
        _notificationActionStatus.value = 'Notifikasi uji belum dapat dikirim.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifikasi uji belum dapat dikirim.')),
        );
      }
    });
  }

  Future<void> _scheduleDiagnosticNotification() async {
    await _runNotificationAction(() async {
      try {
        final scheduledAt = DateTime.now().add(const Duration(minutes: 2));
        await _notificationService.scheduleDiagnosticNotification(
          scheduledAt: scheduledAt,
        );
        await _refreshNotificationReadiness();
        if (!mounted) return;
        final scheduledTimeLabel = TimeOfDay.fromDateTime(
          scheduledAt,
        ).format(context);
        _notificationActionStatus.value =
            'Jadwal uji tersimpan untuk $scheduledTimeLabel.';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi terjadwal untuk 2 menit lagi.'),
          ),
        );
      } catch (e) {
        debugPrint(
          'Error scheduling diagnostic notification from settings: $e',
        );
        _notificationActionStatus.value = 'Jadwal uji belum dapat disimpan.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal uji belum dapat disimpan.')),
        );
      }
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

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                l.setPrayerOffset(prayer.nameId),
                style: TextStyle(color: textColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.adjustOffsetHint, style: TextStyle(color: textMuted)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[-0-9]')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      suffixText: l.minutes,
                      suffixStyle: TextStyle(color: textMuted),
                      helperText: l.isEnglish
                          ? 'Use negative values to make it earlier.'
                          : 'Gunakan nilai minus untuk memajukan waktu.',
                      helperStyle: TextStyle(color: textMuted, fontSize: 11),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: primaryColor.withValues(alpha: 0.35),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primaryColor),
                      ),
                    ),
                    onChanged: (value) {
                      selectedOffset = int.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove_circle,
                          size: 36,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          stfSetState(() {
                            selectedOffset--;
                            controller.text = selectedOffset.toString();
                          });
                        },
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          size: 36,
                          color: primaryColor,
                        ),
                        onPressed: () {
                          stfSetState(() {
                            selectedOffset++;
                            controller.text = selectedOffset.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    l.cancel,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ref
                        .read(settingsProvider.notifier)
                        .updatePrayerOffsets(prayer.key, selectedOffset);
                    Navigator.pop(dialogContext);
                  },
                  child: Text(l.save),
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
                    style: TextStyle(color: textColor, fontSize: 14),
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
                  style: TextStyle(color: textColor, fontSize: 14),
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

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveLayout.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    l.navSettings,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(context, 'PENGATURAN UMUM'),
                  const SizedBox(height: 12),
                  GlassContainer(
                    blur: 15,
                    opacity: isDark ? 0.03 : 0.015,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        // Method selection
                        ListTile(
                          title: Text(
                            l.calculationMethod,
                            style: TextStyle(color: textColor, fontSize: 15),
                          ),
                          subtitle: Text(
                            displayMethod,
                            style: TextStyle(color: accentColor, fontSize: 12),
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
                            style: TextStyle(color: textColor, fontSize: 15),
                          ),
                          subtitle: Text(
                            displayLang,
                            style: TextStyle(color: accentColor, fontSize: 12),
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
                                    fontSize: 15,
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
                  const SizedBox(height: 32),

                  _buildSectionHeader(context, 'NOTIFIKASI'),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<NotificationReadiness>(
                    valueListenable: _notificationReadiness,
                    builder: (context, readiness, _) {
                      return _buildNotificationSection(
                        context,
                        readiness,
                        textColor,
                        textSecondary,
                        dividerColor,
                        isDark,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader(context, 'KOREKSI WAKTU SALAT'),
                  const SizedBox(height: 12),
                  GlassContainer(
                    blur: 15,
                    opacity: isDark ? 0.03 : 0.015,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                  const SizedBox(height: 96),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
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
        child: Icon(icon, color: iconColor, size: 16),
      ),
    );
  }

  Widget _buildNotificationSection(
    BuildContext context,
    NotificationReadiness readiness,
    Color textColor,
    Color textSecondary,
    Color dividerColor,
    bool isDark,
  ) {
    final primaryColor = AppTheme.readableAccent(context);

    return GlassContainer(
      blur: 15,
      opacity: isDark ? 0.03 : 0.015,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              readiness.status == NotificationReadinessStatus.ready
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: primaryColor,
            ),
            title: Text(
              readiness.title,
              style: TextStyle(color: textColor, fontSize: 15),
            ),
            subtitle: Text(
              readiness.message,
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
            trailing: IconButton(
              tooltip: 'Periksa ulang notifikasi',
              icon: Icon(Icons.refresh, color: textSecondary),
              onPressed: _refreshNotificationReadiness,
            ),
          ),
          Divider(color: dividerColor, height: 16),
          ValueListenableBuilder<int>(
            valueListenable: _pendingNotificationCount,
            builder: (context, pendingCount, _) {
              return ValueListenableBuilder<String>(
                valueListenable: _notificationActionStatus,
                builder: (context, actionStatus, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      'Status aksi',
                      style: TextStyle(color: textColor, fontSize: 13),
                    ),
                    subtitle: Text(
                      '$actionStatus Pending: $pendingCount',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  );
                },
              );
            },
          ),
          Divider(color: dividerColor, height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isNotificationActionRunning
                      ? null
                      : _requestNotificationPermissions,
                  child: Text(
                    readiness.needsPermissionAction
                        ? 'Aktifkan izin notifikasi'
                        : 'Periksa izin notifikasi',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isNotificationActionRunning
                      ? null
                      : _sendTestNotification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kirim notifikasi uji'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isNotificationActionRunning
                  ? null
                  : _scheduleDiagnosticNotification,
              icon: const Icon(Icons.schedule, size: 17),
              label: const Text('Jadwalkan tes 2 menit'),
            ),
          ),
        ],
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
        l.isEnglish ? '${prayer.nameId} Offset' : '${prayer.nameId} Ofset',
        style: TextStyle(color: textColor, fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${offset > 0 ? '+' : ''}$offset ${l.minutes}',
            style: TextStyle(
              color: primaryColor,
              fontSize: 13,
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
