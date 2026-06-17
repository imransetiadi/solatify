import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_hero_card.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

import '../../data/prayer_calculation_service.dart';
import '../../data/prayer_timezone_service.dart';
import '../location_provider.dart';

class PrayerScheduleScreen extends ConsumerStatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  ConsumerState<PrayerScheduleScreen> createState() =>
      _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends ConsumerState<PrayerScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  static String _getFormatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showManualCityDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context);
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final filteredCities = LocationService.defaultCities.where((city) {
              return city.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  city.country.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();

            final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
            final dialogBg = isDarkTheme
                ? const Color(0xFF2A1B12)
                : Colors.white;
            final dTextColor = isDarkTheme
                ? Colors.white
                : const Color(0xFF241A12);
            final dTextSecondary = isDarkTheme
                ? const Color(0xFFB8A898)
                : const Color(0xFFAFA19A);
            final dTextHint = isDarkTheme
                ? const Color(0xFFAFA19A)
                : const Color(0xFFAFA19A);
            final dBorderColor = isDarkTheme
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black12;
            final dialogAccentColor = AppTheme.readableAccent(context);

            final dialogWidth = (MediaQuery.sizeOf(context).width - 48).clamp(
              320.0,
              520.0,
            );
            final dialogHeight = MediaQuery.sizeOf(context).height * 0.62;

            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text(
                l.changeLocation,
                style: TextStyle(color: dTextColor),
              ),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Column(
                  children: [
                    TextField(
                      style: TextStyle(color: dTextColor),
                      decoration: InputDecoration(
                        hintText: l.searchCity,
                        hintStyle: TextStyle(color: dTextHint),
                        prefixIcon: Icon(Icons.search, color: dTextSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: dBorderColor),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: dialogAccentColor),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onChanged: (val) {
                        setStateBuilder(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          return ListTile(
                            title: Text(
                              city.name,
                              style: TextStyle(color: dTextColor),
                            ),
                            subtitle: Text(
                              city.country,
                              style: TextStyle(color: dTextSecondary),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: SolatifyIconSize.inline,
                              color: dialogAccentColor,
                            ),
                            onTap: () {
                              ref
                                  .read(locationProvider.notifier)
                                  .setManualCity(city);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final location = ref.watch(locationProvider);
    final settings = ref.watch(settingsProvider);

    // Calculate prayer times for selected date
    final timezoneName = PrayerTimezoneService.inferTimezoneName(
      latitude: location.latitude,
      longitude: location.longitude,
      country: location.country,
    );
    final computedTimes = PrayerCalculationService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: _selectedDate,
      method: settings.calculationMethod,
      timezoneName: timezoneName,
      offsets: settings.prayerOffsets,
    );

    final String displayDate = DateFormat(
      'EEEE, d MMMM yyyy',
      settings.language == 'id' ? 'id_ID' : 'en_US',
    ).format(_selectedDate);

    // Horizontal date strip: yesterday, today, and next 5 days
    final today = DateTime.now();
    final List<DateTime> dateStrip = List.generate(7, (index) {
      return today.subtract(const Duration(days: 1)).add(Duration(days: index));
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark
        ? const Color(0xFFC8B8A8)
        : const Color(0xFFAFA19A);
    final textMuted = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFFAFA19A);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.05);
    final selectedDateColor = isDark
        ? theme.colorScheme.tertiary
        : theme.colorScheme.secondary;
    final selectedDateTextColor = theme.colorScheme.onTertiary;

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context).copyWith(
                      top: ResponsiveLayout.pageTopGap,
                      bottom: ResponsiveLayout.itemGap,
                    ),
                    child: SolatifyHeroCard(
                      eyebrow: l.prayerSchedule,
                      title: l.prayerSchedule,
                      subtitle:
                          '$displayDate • ${location.city}, ${location.country} • ${settings.calculationMethod}',
                      icon: Icons.access_time_filled_rounded,
                      trailing: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.tertiary,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(
                          Icons.edit_location_alt_outlined,
                          size: SolatifyIconSize.inline,
                        ),
                        label: const Text('Ubah'),
                        onPressed: _showManualCityDialog,
                      ),
                    ),
                  ),
                ),

                // Horizontal Date Strip Widget list
                SliverToBoxAdapter(
                  child: Container(
                    height: 84,
                    margin: const EdgeInsets.symmetric(
                      vertical: ResponsiveLayout.itemGap,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: ResponsiveLayout.pagePadding(
                        context,
                      ).copyWith(top: 0, bottom: 0),
                      itemCount: dateStrip.length,
                      itemBuilder: (context, index) {
                        final date = dateStrip[index];
                        final isSelected =
                            _getFormatDate(date) ==
                            _getFormatDate(_selectedDate);
                        final isToday =
                            _getFormatDate(date) == _getFormatDate(today);

                        final dayName = DateFormat('EEE').format(date);
                        final dayNum = date.day.toString();

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedDateColor
                                  : isToday
                                  ? selectedDateColor.withValues(alpha: 0.18)
                                  : (isDark
                                        ? theme.colorScheme.surface.withValues(
                                            alpha: 0.72,
                                          )
                                        : Colors.black.withValues(alpha: 0.02)),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? selectedDateColor
                                    : isToday
                                    ? selectedDateColor.withValues(alpha: 0.45)
                                    : (isDark
                                          ? theme.colorScheme.outline
                                                .withValues(alpha: 0.55)
                                          : Colors.black.withValues(
                                              alpha: 0.06,
                                            )),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: SolatifyType.eyebrow,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? selectedDateTextColor
                                        : textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dayNum,
                                  style: TextStyle(
                                    fontSize: SolatifyType.sectionTitle,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? selectedDateTextColor
                                        : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Selected Date Indicator
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context).copyWith(
                      top: ResponsiveLayout.itemGap,
                      bottom: ResponsiveLayout.itemGap,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: textSecondary,
                          size: SolatifyIconSize.inline,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: SolatifyType.body,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Prayer times checklist card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(context).copyWith(
                      top: ResponsiveLayout.itemGap,
                      bottom: ResponsiveLayout.bottomSafeGap,
                    ),
                    child: GlassContainer(
                      opacity: isDark ? 0.04 : 0.02,
                      borderRadius: 24,
                      padding: ResponsiveLayout.cardPadding,
                      child: Column(
                        children: [
                          _buildPrayerTimeRow(
                            l.prayerName('subuh'),
                            computedTimes['subuh']!,
                            Icons.brightness_5,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            l.prayerName('dzuhur'),
                            computedTimes['dzuhur']!,
                            Icons.wb_sunny,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            l.prayerName('ashar'),
                            computedTimes['ashar']!,
                            Icons.wb_twilight,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            l.prayerName('magrib'),
                            computedTimes['magrib']!,
                            Icons.nights_stay,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            l.prayerName('isya'),
                            computedTimes['isya']!,
                            Icons.dark_mode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(String name, DateTime time, IconData icon) {
    final formattedTime = DateFormat('HH:mm').format(time);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF9A6A3A),
                size: SolatifyIconSize.cardIcon,
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: SolatifyType.cardTitle,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: SolatifyType.sectionTitle,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
