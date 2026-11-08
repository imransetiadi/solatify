import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solatify/features/settings/domain/entities/settings_state.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_offsets.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_calculation_service.dart';
import 'package:solatify/features/prayer_schedule/data/prayer_timezone_service.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/widgets/manual_location_dialog.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

class PrayerScheduleScreen extends ConsumerStatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  ConsumerState<PrayerScheduleScreen> createState() =>
      _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends ConsumerState<PrayerScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  static const _prayerKeys = ['subuh', 'dzuhur', 'ashar', 'magrib', 'isya'];

  static const _prayerIcons = <String, IconData>{
    'subuh': Icons.brightness_5_rounded,
    'dzuhur': Icons.wb_sunny_rounded,
    'ashar': Icons.wb_twilight_rounded,
    'magrib': Icons.nights_stay_rounded,
    'isya': Icons.dark_mode_rounded,
  };

  static String _getFormatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _selectDate(DateTime date) {
    if (_getFormatDate(date) == _getFormatDate(_selectedDate)) return;
    SolatifyHaptics.selection();
    setState(() {
      _selectedDate = date;
    });
  }

  void _showManualCityDialog() {
    SolatifyHaptics.selection();
    showDialog<void>(
      context: context,
      builder: (context) {
        final l = AppLocalizations.of(context);
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final query = searchQuery.toLowerCase().trim();
            final filteredCities = LocationService.defaultCities.where((city) {
              return city.name.toLowerCase().contains(query) ||
                  city.country.toLowerCase().contains(query);
            }).toList();

            final accent = SolatifyColors.accent(context);
            final muted = SolatifyColors.muted(context);
            final bodySize = manualLocationDialogBodySize(context);

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: SolatifySpacing.xl,
              ),
              title: Semantics(header: true, child: Text(l.changeLocation)),
              content: SizedBox(
                width: bodySize.width,
                height: bodySize.height,
                child: Column(
                  children: [
                    TextField(
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l.searchCity,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (val) {
                        setStateBuilder(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: SolatifySpacing.sm),
                    Expanded(
                      child: filteredCities.isEmpty
                          ? SingleChildScrollView(
                              child: SolatifyStateView.empty(
                                compact: true,
                                icon: Icons.location_off_outlined,
                                title: l.isEnglish
                                    ? 'City not found'
                                    : 'Kota tidak ditemukan',
                                description: l.isEnglish
                                    ? 'Try another city or province name.'
                                    : 'Coba nama kota atau provinsi lain.',
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = filteredCities[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  leading: Icon(
                                    Icons.location_city_rounded,
                                    color: accent,
                                  ),
                                  title: Text(
                                    city.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: SolatifyColors.text(context),
                                    ),
                                  ),
                                  subtitle: Text(
                                    city.country,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: SolatifyType.caption,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: muted,
                                  ),
                                  onTap: () {
                                    SolatifyHaptics.selection();
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.cancel),
                ),
              ],
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
    final localeName = settings.language == 'id' ? 'id_ID' : 'en_US';

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
      localeName,
    ).format(_selectedDate);

    // Horizontal date strip: yesterday, today, and next 5 days
    final today = DateTime.now();
    final List<DateTime> dateStrip = List.generate(7, (index) {
      return today.subtract(const Duration(days: 1)).add(Duration(days: index));
    });
    final isViewingToday =
        _getFormatDate(_selectedDate) == _getFormatDate(today);

    // Only meaningful when looking at today's schedule.
    String? nextPrayerKey;
    if (isViewingToday) {
      for (final key in _prayerKeys) {
        final time = computedTimes[key];
        if (time != null && time.isAfter(today)) {
          nextPrayerKey = key;
          break;
        }
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);
    final selectedDateColor = isDark
        ? theme.colorScheme.tertiary
        : theme.colorScheme.secondary;
    final selectedDateTextColor = isDark
        ? theme.colorScheme.onTertiary
        : theme.colorScheme.onSecondary;
    final pagePadding = ResponsiveLayout.pagePadding(context);

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pagePadding.copyWith(
                      top: ResponsiveLayout.pageTopGap,
                      bottom: ResponsiveLayout.itemGap,
                    ),
                    child: GlassContainer(
                      borderRadius: SolatifyRadius.lg,
                      padding: SolatifySpacing.compactCard,
                      child: Row(
                        children: [
                          Container(
                            width: SolatifyIconSize.cardBox,
                            height: SolatifyIconSize.cardBox,
                            decoration: BoxDecoration(
                              borderRadius: SolatifyRadius.icon,
                              color: SolatifyColors.accent(context),
                            ),
                            child: Icon(
                              Icons.access_time_filled_rounded,
                              color: SolatifyColors.onAccent(context),
                              size: SolatifyIconSize.cardIcon,
                            ),
                          ),
                          const SizedBox(width: SolatifySpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    l.prayerSchedule,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: SolatifyType.sectionTitle,
                                      height: 1.15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place_rounded,
                                      size: SolatifyType.caption + 2,
                                      color: mutedColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        '${location.city}, ${location.country}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: mutedColor,
                                          fontSize: SolatifyType.caption,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: SolatifySpacing.xs),
                          Tooltip(
                            message: l.changeLocation,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: SolatifyColors.accent(context),
                                minimumSize: const Size(
                                  SolatifyTapTarget.min,
                                  SolatifyTapTarget.min,
                                ),
                              ),
                              icon: const Icon(
                                Icons.edit_location_alt_outlined,
                                size: SolatifyIconSize.inline,
                              ),
                              label: Text(l.isEnglish ? 'Change' : 'Ubah'),
                              onPressed: _showManualCityDialog,
                            ),
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
                    margin: const EdgeInsets.symmetric(
                      vertical: ResponsiveLayout.itemGap,
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: pagePadding.copyWith(top: 0, bottom: 0),
                      itemCount: dateStrip.length,
                      itemBuilder: (context, index) {
                        final date = dateStrip[index];
                        final isSelected =
                            _getFormatDate(date) ==
                            _getFormatDate(_selectedDate);
                        final isToday =
                            _getFormatDate(date) == _getFormatDate(today);

                        final dayName = DateFormat(
                          'EEE',
                          localeName,
                        ).format(date);
                        final dayNum = date.day.toString();
                        final fullDate = DateFormat(
                          'EEEE, d MMMM',
                          localeName,
                        ).format(date);
                        final todayLabel = l.isEnglish ? 'Today' : 'Hari ini';
                        final radius = BorderRadius.circular(SolatifyRadius.md);

                        return Semantics(
                          button: true,
                          selected: isSelected,
                          label: isToday ? '$fullDate, $todayLabel' : fullDate,
                          onTap: () => _selectDate(date),
                          excludeSemantics: true,
                          child: AnimatedContainer(
                            duration: SolatifyMotion.of(
                              context,
                              SolatifyMotion.medium,
                            ),
                            curve: SolatifyMotion.curve,
                            width: 60,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedDateColor
                                  : isToday
                                  ? selectedDateColor.withValues(alpha: 0.18)
                                  : SolatifyColors.softSurface(
                                      context,
                                    ).withValues(alpha: isDark ? 0.72 : 0.9),
                              borderRadius: radius,
                              border: Border.all(
                                color: isSelected
                                    ? selectedDateColor
                                    : isToday
                                    ? selectedDateColor.withValues(alpha: 0.45)
                                    : SolatifyColors.border(context),
                                width: 1.2,
                              ),
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: InkWell(
                                borderRadius: radius,
                                onTap: () => _selectDate(date),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      dayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: SolatifyType.eyebrow,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? selectedDateTextColor
                                            : mutedColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
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
                                    const SizedBox(height: 4),
                                    // Non-color cue for "today".
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isToday
                                            ? (isSelected
                                                  ? selectedDateTextColor
                                                  : selectedDateColor)
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    padding: pagePadding.copyWith(
                      top: ResponsiveLayout.itemGap,
                      bottom: ResponsiveLayout.itemGap,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: mutedColor,
                          size: SolatifyIconSize.inline,
                        ),
                        const SizedBox(width: SolatifySpacing.xs),
                        Expanded(
                          child: Semantics(
                            header: true,
                            child: AnimatedSwitcher(
                              duration: SolatifyMotion.of(
                                context,
                                SolatifyMotion.fast,
                              ),
                              layoutBuilder: (current, previous) => Stack(
                                alignment: Alignment.centerLeft,
                                children: [...previous, ?current],
                              ),
                              child: Text(
                                displayDate,
                                key: ValueKey(displayDate),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: SolatifyType.body,
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: SolatifyMotion.of(
                            context,
                            SolatifyMotion.fast,
                          ),
                          child: isViewingToday
                              ? const SizedBox.shrink()
                              : TextButton(
                                  onPressed: () => _selectDate(DateTime.now()),
                                  child: Text(
                                    l.isEnglish ? 'Today' : 'Hari ini',
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
                    padding: pagePadding.copyWith(
                      top: ResponsiveLayout.itemGap,
                      bottom: ResponsiveLayout.bottomSafeGap,
                    ),
                    child: GlassContainer(
                      borderRadius: SolatifyRadius.lg,
                      padding: ResponsiveLayout.cardPadding,
                      child: Column(
                        children: [
                          for (var i = 0; i < _prayerKeys.length; i++) ...[
                            if (i > 0)
                              Divider(
                                color: SolatifyColors.border(context),
                                height: 20,
                              ),
                            _buildPrayerTimeRow(
                              l.prayerName(_prayerKeys[i]),
                              computedTimes[_prayerKeys[i]]!,
                              _prayerIcons[_prayerKeys[i]]!,
                              isNext: nextPrayerKey == _prayerKeys[i],
                              nextLabel: l.isEnglish ? 'Next' : 'Berikutnya',
                            ),
                          ],
                          ..._buildScheduleFootnote(settings),
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

  /// Says what the times include, so a user who set a correction months
  /// ago is not puzzled that they differ from a printed schedule.
  List<Widget> _buildScheduleFootnote(SettingsState settings) {
    final l = AppLocalizations.of(context);
    final lines = <String>[];
    if (PrayerCalculationService.standardFor(settings.calculationMethod) ==
        PrayerMethodStandard.kemenag) {
      lines.add(
        l.isEnglish
            ? 'Kemenag method, including the official ihtiyat.'
            : 'Metode Kemenag, sudah termasuk ihtiyat resmi.',
      );
    }
    final active = [
      for (final key in prayerOffsetKeys)
        if ((settings.prayerOffsets[key] ?? 0) != 0)
          '${l.prayerName(key)} '
              '${settings.prayerOffsets[key]! > 0 ? '+' : ''}'
              '${settings.prayerOffsets[key]} ${l.minutes}',
    ];
    if (active.isNotEmpty) {
      lines.add(
        l.isEnglish
            ? 'Your corrections: ${active.join(', ')}.'
            : 'Koreksi manualmu: ${active.join(', ')}.',
      );
    }
    if (lines.isEmpty) return const [];
    return [
      Divider(color: SolatifyColors.border(context), height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: SolatifySpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              active.isEmpty
                  ? Icons.verified_outlined
                  : Icons.more_time_rounded,
              size: SolatifyIconSize.inline,
              color: SolatifyColors.muted(context),
            ),
            const SizedBox(width: SolatifySpacing.xs),
            Expanded(
              child: Text(
                lines.join(' '),
                style: TextStyle(
                  color: SolatifyColors.muted(context),
                  fontSize: SolatifyType.caption,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildPrayerTimeRow(
    String name,
    DateTime time,
    IconData icon, {
    required bool isNext,
    required String nextLabel,
  }) {
    final formattedTime = DateFormat('HH:mm').format(time);
    final accent = SolatifyColors.accent(context);
    final textColor = SolatifyColors.text(context);

    return Semantics(
      container: true,
      label: isNext
          ? '$name, $formattedTime, $nextLabel'
          : '$name, $formattedTime',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: SolatifyMotion.of(context, SolatifyMotion.medium),
        curve: SolatifyMotion.curve,
        padding: const EdgeInsets.symmetric(
          horizontal: SolatifySpacing.sm,
          vertical: SolatifySpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isNext
              ? SolatifyColors.accentSoft(context)
              : Colors.transparent,
          borderRadius: SolatifyRadius.icon,
        ),
        child: Row(
          children: [
            Container(
              width: SolatifyIconSize.cardBox,
              height: SolatifyIconSize.cardBox,
              decoration: BoxDecoration(
                color: isNext ? accent : SolatifyColors.raisedSurface(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Icon(
                icon,
                color: isNext
                    ? SolatifyColors.onAccent(context)
                    : SolatifyColors.muted(context),
                size: SolatifyIconSize.cardIcon,
              ),
            ),
            const SizedBox(width: SolatifySpacing.md),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: SolatifySpacing.sm,
                runSpacing: 4,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: SolatifyType.cardTitle,
                      fontWeight: isNext ? FontWeight.w800 : FontWeight.w600,
                      color: isNext ? accent : textColor,
                    ),
                  ),
                  if (isNext)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        nextLabel,
                        maxLines: 1,
                        style: TextStyle(
                          color: SolatifyColors.onAccent(context),
                          fontSize: SolatifyType.eyebrow,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: SolatifyType.sectionTitle,
                fontWeight: FontWeight.bold,
                color: isNext ? accent : textColor,
                letterSpacing: 0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
