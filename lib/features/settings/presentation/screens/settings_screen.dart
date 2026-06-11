import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/database/hive_service.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../settings_provider.dart';

enum PrayerOffsetType {
  subuh,
  dzuhur,
  ashar,
  magrib,
  isya,
}

extension PrayerOffsetTypeExtension on PrayerOffsetType {
  String get nameId {
    switch (this) {
      case PrayerOffsetType.subuh: return 'Subuh';
      case PrayerOffsetType.dzuhur: return 'Dzuhur';
      case PrayerOffsetType.ashar: return 'Ashar';
      case PrayerOffsetType.magrib: return 'Magrib';
      case PrayerOffsetType.isya: return 'Isya';
    }
  }

  String get key {
    switch (this) {
      case PrayerOffsetType.subuh: return 'subuh';
      case PrayerOffsetType.dzuhur: return 'dzuhur';
      case PrayerOffsetType.ashar: return 'ashar';
      case PrayerOffsetType.magrib: return 'magrib';
      case PrayerOffsetType.isya: return 'isya';
    }
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showPrayerOffsetDialog(
    BuildContext context,
    WidgetRef ref,
    PrayerOffsetType prayer,
    int currentOffset,
  ) {
    int selectedOffset = currentOffset;
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkTheme ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDarkTheme ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDarkTheme ? Colors.white70 : const Color(0xFF6E5B4B);
    final primaryColor = isDarkTheme ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                'Atur Ofset Waktu ${prayer.nameId}',
                style: TextStyle(color: textColor),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tambahkan atau kurangi menit dari waktu standar.',
                    style: TextStyle(color: textMuted),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, size: 36, color: primaryColor),
                        onPressed: () {
                          stfSetState(() {
                            selectedOffset--;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${selectedOffset > 0 ? '+' : ''}$selectedOffset menit',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.add_circle, size: 36, color: primaryColor),
                        onPressed: () {
                          stfSetState(() {
                            selectedOffset++;
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
                  child: Text('Batal', style: TextStyle(color: textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).updatePrayerOffsets(prayer.key, selectedOffset);
                    Navigator.pop(dialogContext);
                  },
                  child: Text('Simpan', style: TextStyle(color: primaryColor)),
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
    final methods = {
      'Kemenag': 'Kemenag RI (Indonesia)',
      'MuslimWorldLeague': 'Muslim World League (MWL)',
      'Egypt': 'Egyptian General Authority',
      'Karachi': 'Univ. of Islamic Sciences, Karachi',
      'UmmAlQura': 'Umm Al-Qura University, Makkah',
      'NorthAmerica': 'ISNA (North America)',
    };

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkTheme ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDarkTheme ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDarkTheme ? Colors.white70 : const Color(0xFF6E5B4B);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text('Metode Perhitungan', style: TextStyle(color: textColor)),
          content: SizedBox(
            width: double.maxFinite,
            child: RadioGroup<String>(
              groupValue: currentMethod,
              onChanged: (val) {
                if (val != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .updateCalculationMethod(val);
                  Navigator.pop(context);
                }
              },
              child: ListView(
                shrinkWrap: true,
                children: methods.entries.map((entry) {
                  return RadioListTile<String>(
                    activeColor: const Color(0xFF0E4D31),
                    title: Text(
                      entry.value,
                      style: TextStyle(color: textColor),
                    ),
                    value: entry.key,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: textMuted)),
            ),
          ],
        );
      },
    );
  }

  void _showAdhanSoundDialog(
    BuildContext context,
    WidgetRef ref,
    String currentSound,
  ) {
    final sounds = {
      'default': 'Bip Standar / Default',
      'adhan_makkah': 'Adzan Makkah',
      'adhan_madinah': 'Adzan Madinah',
      'silent': 'Hening / Silent',
    };

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkTheme ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDarkTheme ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDarkTheme ? Colors.white70 : const Color(0xFF6E5B4B);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text(
            'Suara Pengingat Adzan',
            style: TextStyle(color: textColor),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: RadioGroup<String>(
              groupValue: currentSound,
              onChanged: (val) {
                if (val != null) {
                  ref.read(settingsProvider.notifier).updateAdhanSound(val);
                  Navigator.pop(context);
                }
              },
              child: ListView(
                shrinkWrap: true,
                children: sounds.entries.map((entry) {
                  return RadioListTile<String>(
                    activeColor: const Color(0xFF0E4D31),
                    title: Text(
                      entry.value,
                      style: TextStyle(color: textColor),
                    ),
                    value: entry.key,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: textMuted)),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    final langs = {
      'id': 'Bahasa Indonesia',
      'en': 'English',
      'ar': 'العربية (Arabic)',
    };

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDarkTheme ? const Color(0xFF2A1B12) : Colors.white;
    final textColor = isDarkTheme ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDarkTheme ? Colors.white70 : const Color(0xFF6E5B4B);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBg,
          title: Text('Pilih Bahasa', style: TextStyle(color: textColor)),
          content: SizedBox(
            width: double.maxFinite,
            child: RadioGroup<String>(
              groupValue: currentLang,
              onChanged: (val) {
                if (val != null) {
                  ref.read(settingsProvider.notifier).updateLanguage(val);
                  Navigator.pop(context);
                }
              },
              child: ListView(
                shrinkWrap: true,
                children: langs.entries.map((entry) {
                  return RadioListTile<String>(
                    activeColor: const Color(0xFF0E4D31),
                    title: Text(
                      entry.value,
                      style: TextStyle(color: textColor),
                    ),
                    value: entry.key,
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: textMuted)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final String displayMethod = _getCalculationMethodLabel(
      settings.calculationMethod,
    );
    final String displaySound = _getAdhanSoundLabel(settings.adhanSound);
    final String displayLang = _getLanguageLabel(settings.language);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);
    final textHint = isDark ? Colors.white38 : const Color(0xFF7A6A5D);
    final textExtraMuted = isDark ? Colors.white24 : const Color(0xFFD7C6B4);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SafeArea(
        child: ResponsiveCenter(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: ResponsiveLayout.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Reminder & Audio
                _buildSectionHeader(context, 'Notifikasi & Adzan'),
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
                      // Global notifications switch
                      SwitchListTile(
                        activeThumbColor: const Color(0xFF0E4D31),
                        title: Text(
                          'Pengingat Salat',
                          style: TextStyle(color: textColor, fontSize: 15),
                        ),
                        subtitle: Text(
                          'Aktifkan pengingat notifikasi masuk waktu salat',
                          style: TextStyle(color: textSecondary, fontSize: 11),
                        ),
                        value: settings.notificationEnabled,
                        onChanged: (val) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateNotificationEnabled(val);
                        },
                      ),
                      Divider(color: dividerColor, height: 16),
                      // Audio selection
                      ListTile(
                        title: Text(
                          'Suara Adzan',
                          style: TextStyle(color: textColor, fontSize: 15),
                        ),
                        subtitle: Text(
                          displaySound,
                          style: const TextStyle(
                            color: Color(0xFF0E4D31),
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: textSecondary,
                        ),
                        onTap: () => _showAdhanSoundDialog(
                          context,
                          ref,
                          settings.adhanSound,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Calculation Settings
                _buildSectionHeader(context, 'Kalkulasi Jadwal'),
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
                          'Metode Perhitungan',
                          style: TextStyle(color: textColor, fontSize: 15),
                        ),
                        subtitle: Text(
                          displayMethod,
                          style: const TextStyle(
                            color: Color(0xFF0E4D31),
                            fontSize: 12,
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2b: Prayer Time Offsets
                _buildSectionHeader(context, 'Ofset Waktu Salat'),
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
                      _buildOffsetTile(context, ref, PrayerOffsetType.subuh, settings.prayerOffsets['subuh'] ?? 0, textColor, textSecondary),
                      Divider(color: dividerColor, height: 16),
                      _buildOffsetTile(context, ref, PrayerOffsetType.dzuhur, settings.prayerOffsets['dzuhur'] ?? 0, textColor, textSecondary),
                      Divider(color: dividerColor, height: 16),
                      _buildOffsetTile(context, ref, PrayerOffsetType.ashar, settings.prayerOffsets['ashar'] ?? 0, textColor, textSecondary),
                      Divider(color: dividerColor, height: 16),
                      _buildOffsetTile(context, ref, PrayerOffsetType.magrib, settings.prayerOffsets['magrib'] ?? 0, textColor, textSecondary),
                      Divider(color: dividerColor, height: 16),
                      _buildOffsetTile(context, ref, PrayerOffsetType.isya, settings.prayerOffsets['isya'] ?? 0, textColor, textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: Localization & UI
                _buildSectionHeader(context, 'Tampilan & Bahasa'),
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
                      // Language
                      ListTile(
                        title: Text(
                          'Bahasa',
                          style: TextStyle(color: textColor, fontSize: 15),
                        ),
                        subtitle: Text(
                          displayLang,
                          style: const TextStyle(
                            color: Color(0xFF0E4D31),
                            fontSize: 12,
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
                                'Tema Aplikasi',
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

                // Section 4: App Information
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Solatify v1.0.0 (MVP)',
                        style: TextStyle(color: textHint, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Made with ♥ for Muslim Companions',
                        style: TextStyle(color: textExtraMuted, fontSize: 10),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // Reset onboarding (developer toggle)
                          HiveService.saveSetting(
                            'onboarding_completed',
                            false,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Onboarding telah direset. Jalankan ulang aplikasi.',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Reset Onboarding (Dev)',
                          style: TextStyle(
                            color: Color(0xFF241A12),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.04);
    final unselectedBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final iconColor = isSelected
        ? Colors.black
        : (isDark ? Colors.white70 : const Color(0xFF6E5B4B));
    return GestureDetector(
      onTap: () => ref.read(settingsProvider.notifier).updateTheme(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0E4D31) : unselectedBg,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF0E4D31) : unselectedBorder,
            width: 1.2,
          ),
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
    );
  }

  String _getCalculationMethodLabel(String val) {
    switch (val) {
      case 'MuslimWorldLeague':
        return 'Muslim World League (MWL)';
      case 'Egypt':
        return 'Egyptian General Authority';
      case 'Karachi':
        return 'Univ. of Islamic Sciences, Karachi';
      case 'UmmAlQura':
        return 'Umm Al-Qura University, Makkah';
      case 'NorthAmerica':
        return 'ISNA (North America)';
      case 'Kemenag':
      default:
        return 'Kemenag RI (Indonesia)';
    }
  }

  String _getAdhanSoundLabel(String val) {
    switch (val) {
      case 'adhan_makkah':
        return 'Adzan Makkah';
      case 'adhan_madinah':
        return 'Adzan Madinah';
      case 'silent':
        return 'Hening / Silent';
      case 'default':
      default:
        return 'Bip Standar / Default';
    }
  }

  String _getLanguageLabel(String val) {
    switch (val) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية (Arabic)';
      case 'id':
      default:
        return 'Bahasa Indonesia';
    }
  }

  Widget _buildOffsetTile(
    BuildContext context,
    WidgetRef ref,
    PrayerOffsetType prayer,
    int offset,
    Color textColor,
    Color textSecondary,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);

    return ListTile(
      title: Text(
        '${prayer.nameId} Ofset',
        style: TextStyle(color: textColor, fontSize: 15),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${offset > 0 ? '+' : ''}$offset menit',
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
