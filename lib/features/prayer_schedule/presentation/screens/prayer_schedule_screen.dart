import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/utils/location_service.dart';
import '../location_provider.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../data/prayer_calculation_service.dart';

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
    showDialog(
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
            final dTextMuted = isDarkTheme
                ? Colors.white70
                : const Color(0xFF6E5B4B);
            final dTextSecondary = isDarkTheme
                ? Colors.white60
                : const Color(0xFF7A6A5D);
            final dTextHint = isDarkTheme
                ? Colors.white54
                : const Color(0xFF7A6A5D);
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lokasi diubah ke ${city.name}, ${city.country}',
                                  ),
                                  backgroundColor: const Color(0xFF0E4D31),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: TextStyle(color: dTextMuted)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkTheme
                ? const ColorScheme.dark(
                    primary: Color(0xFF0E4D31), // Brown
                    onPrimary: Colors.black,
                    surface: Color(0xFF2A1B12),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF0E4D31), // Brown
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Color(0xFF241A12),
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0E4D31),
              ),
            ),
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
    final computedTimes = PrayerCalculationService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      date: _selectedDate,
      method: settings.calculationMethod,
    );

    final String displayDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(_selectedDate);

    // List of 7 days around selected date for horizontal strip
    final DateTime today = DateTime.now();
    final List<DateTime> dateStrip = List.generate(7, (index) {
      return today.add(
        Duration(days: index - 1),
      ); // Shows yesterday, today, and 5 days forward
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textMuted = isDark ? Colors.white70 : const Color(0xFF6E5B4B);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header title
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveLayout.pagePadding(
                    context,
                  ).copyWith(top: 16, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Color(0xFF0E4D31),
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Jadwal Salat',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Color(0xFF0E4D31),
                        ),
                        tooltip: 'Pilih Tanggal',
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Location card
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                        const SizedBox(width: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: textColor,
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
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

              // Horizontal Date Selector
              SliverToBoxAdapter(
                child: Container(
                  height: 84,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dateStrip.length,
                    itemBuilder: (context, index) {
                      final date = dateStrip[index];
                      final isSelected =
                          _getFormatDate(date) == _getFormatDate(_selectedDate);
                      final isToday =
                          _getFormatDate(date) == _getFormatDate(today);

                      final dayName = DateFormat(
                        'E',
                        'id_ID',
                      ).format(date).toUpperCase();
                      final dayNum = DateFormat('d').format(date);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 58,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0E4D31)
                                : isToday
                                ? const Color(
                                    0xFF0E4D31,
                                  ).withValues(alpha: 0.15)
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.02)
                                      : Colors.black.withValues(alpha: 0.02)),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0E4D31)
                                  : isToday
                                  ? const Color(
                                      0xFF0E4D31,
                                    ).withValues(alpha: 0.3)
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
                                      ? Colors.black
                                      : textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dayNum,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black : textColor,
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
              Icon(icon, color: Color(0xFF0E4D31), size: 20),
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
