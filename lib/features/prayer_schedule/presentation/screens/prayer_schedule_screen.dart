import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';

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

            final dialogWidth = (MediaQuery.sizeOf(context).width - 48).clamp(
              320.0,
              520.0,
            );
            final dialogHeight = MediaQuery.sizeOf(context).height * 0.62;

            return AlertDialog(
              backgroundColor: dialogBg,
              title: Text('Ubah Lokasi', style: TextStyle(color: dTextColor)),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Column(
                  children: [
                    TextField(
                      style: TextStyle(color: dTextColor),
                      decoration: InputDecoration(
                        hintText: 'Cari Kota...',
                        hintStyle: TextStyle(color: dTextHint),
                        prefixIcon: Icon(Icons.search, color: dTextSecondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: dBorderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF0E4D31),
                          ),
                          borderRadius: BorderRadius.circular(12),
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
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Color(0xFF0E4D31),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF0E4D31),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF241A14) : Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF241A12),
            ),
            dialogBackgroundColor:
                isDark ? const Color(0xFF2A1B12) : Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      return today.subtract(const Duration(days: 1)).add(
            Duration(days: index),
          );
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header Title with Location selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 16, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Jadwal Salat',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_location, color: textSecondary),
                          onPressed: () => _showManualCityDialog(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Location Details Banner Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 8, bottom: 8),
                    child: GlassContainer(
                      blur: 15,
                      opacity: isDark ? 0.03 : 0.015,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF0E4D31),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        location.city,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Text(
                                        'Metode: ${settings.calculationMethod}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: textColor,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Ubah'),
                            onPressed: _showManualCityDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Horizontal Date Strip Widget list
                SliverToBoxAdapter(
                  child: Container(
                    height: 84,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: dateStrip.length,
                      itemBuilder: (context, index) {
                        final date = dateStrip[index];
                        final isSelected =
                            _getFormatDate(date) == _getFormatDate(_selectedDate);
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
                                  ? const Color(0xFF0E4D31)
                                  : isToday
                                      ? const Color(0xFF0E4D31)
                                          .withValues(alpha: 0.15)
                                      : (isDark
                                          ? Colors.white.withValues(alpha: 0.02)
                                          : Colors.black.withValues(alpha: 0.02)),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0E4D31)
                                    : isToday
                                        ? const Color(0xFF0E4D31)
                                            .withValues(alpha: 0.3)
                                        : (isDark
                                            ? Colors.white.withValues(alpha: 0.06)
                                            : Colors.black.withValues(alpha: 0.06)),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dayNum,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : textColor,
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
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 8, bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.today, color: textSecondary, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 8, bottom: 96),
                    child: GlassContainer(
                      blur: 20,
                      opacity: isDark ? 0.04 : 0.02,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildPrayerTimeRow(
                            'Subuh',
                            computedTimes['subuh']!,
                            Icons.brightness_5,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            'Dzuhur',
                            computedTimes['dzuhur']!,
                            Icons.wb_sunny,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            'Ashar',
                            computedTimes['ashar']!,
                            Icons.wb_twilight,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            'Magrib',
                            computedTimes['magrib']!,
                            Icons.nights_stay,
                          ),
                          Divider(color: dividerColor, height: 24),
                          _buildPrayerTimeRow(
                            'Isya',
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
              Icon(icon, color: const Color(0xFF9A6A3A), size: 20),
              const SizedBox(width: 16),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 18,
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
