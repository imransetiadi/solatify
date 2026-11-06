import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/home/presentation/providers/countdown_provider.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/location_entity.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/prayer_item_entity.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/widgets/manual_location_dialog.dart';
import 'package:solatify/features/prayer_widget/presentation/prayer_widget_provider.dart';

/// Icon used for each prayer, shared by the Home list.
IconData _prayerIcon(String key) {
  switch (key) {
    case 'subuh':
      return Icons.brightness_5_rounded;
    case 'dzuhur':
      return Icons.wb_sunny_rounded;
    case 'ashar':
      return Icons.wb_twilight_rounded;
    case 'magrib':
      return Icons.nights_stay_rounded;
    case 'isya':
      return Icons.dark_mode_rounded;
    default:
      return Icons.access_time_rounded;
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final location = ref.watch(locationProvider);
    final countdownMarkers = ref.watch(
      countdownProvider.select(
        (state) => (
          nextPrayerKey: state.nextPrayerKey,
          activePrayerName: state.activePrayerName,
        ),
      ),
    );
    ref.listen(prayerWidgetPayloadProvider, (previous, next) {
      if (previous == next) return;
      if (defaultTargetPlatform == TargetPlatform.android) {
        ref.read(androidPrayerWidgetServiceProvider).sync(next);
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        ref.read(iosPrayerWidgetServiceProvider).sync(next);
      }
    });
    final prayerList = ref.watch(prayerListProvider);
    final pagePadding = ResponsiveLayout.pagePadding(context);

    String? nextPrayerTime;
    for (final item in prayerList) {
      if (item.key == countdownMarkers.nextPrayerKey) {
        nextPrayerTime = DateFormat('HH:mm').format(item.time);
      }
    }

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          bottom: false,
          child: ResponsiveCenter(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pagePadding.copyWith(
                      top: ResponsiveLayout.pageTopGap,
                    ),
                    child: _HomeHeader(
                      location: location,
                      onChangeLocation: () {
                        SolatifyHaptics.selection();
                        showManualLocationDialog(context: context, ref: ref);
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pagePadding.copyWith(
                      top: SolatifySpacing.lg,
                      bottom: SolatifySpacing.xs,
                    ),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final countdown = ref.watch(countdownProvider);
                        return _PrayerCountdownCard(
                          countdown: countdown,
                          nextPrayerTime: nextPrayerTime,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pagePadding.copyWith(
                      top: SolatifySpacing.xl,
                      bottom: SolatifySpacing.sm,
                    ),
                    child: _SectionTitle(
                      title: l.isEnglish ? 'Quick Access' : 'Akses Cepat',
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: pagePadding.left),
                    child: const _QuickAccessGrid(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: pagePadding.copyWith(
                      top: SolatifySpacing.xl,
                      bottom: SolatifySpacing.sm,
                    ),
                    child: _SectionTitle(
                      title: l.prayerSchedule,
                      trailing: TextButton(
                        onPressed: () => context.go(AppRoutes.schedule),
                        child: Text(l.isEnglish ? 'See all' : 'Lihat semua'),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: pagePadding.left),
                  sliver: prayerList.isEmpty
                      ? SliverToBoxAdapter(
                          child: SolatifyStateView.loading(
                            compact: true,
                            title: l.preparingPrayerSchedule,
                            description: l.countdownWaiting,
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = prayerList[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: SolatifySpacing.sm,
                              ),
                              child: _PrayerRow(
                                item: item,
                                isNext:
                                    countdownMarkers.nextPrayerKey == item.key,
                                isActive:
                                    countdownMarkers.activePrayerName ==
                                    item.name,
                              ),
                            );
                          }, childCount: prayerList.length),
                        ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: SolatifySpacing.bottomNav),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.location, required this.onChangeLocation});

  final LocationEntity location;
  final VoidCallback onChangeLocation;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final locationLabel = '${location.city}, ${location.country}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: SolatifyColors.accentSoft(context),
                  borderRadius: SolatifyRadius.compactCard,
                  border: Border.all(color: SolatifyColors.border(context)),
                ),
                child: SvgPicture.asset(
                  'assets/images/masjid_nabawi.svg',
                  width: 34,
                  height: 34,
                ),
              ),
            ),
            const SizedBox(width: SolatifySpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.greeting,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: SolatifyColors.muted(context),
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Semantics(
                    header: true,
                    child: Text(
                      'Solatify',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SolatifyColors.text(context),
                        fontSize: SolatifyType.heroTitle,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: SolatifySpacing.md),
        // Whole location row is one large, clearly tappable chip.
        GlassContainer(
          onTap: onChangeLocation,
          semanticLabel: l.isEnglish
              ? 'Location: $locationLabel. Tap to change location'
              : 'Lokasi: $locationLabel. Ketuk untuk ubah lokasi',
          borderRadius: 999,
          borderColor: SolatifyColors.borderStrong(context),
          padding: const EdgeInsets.symmetric(
            horizontal: SolatifySpacing.md,
            vertical: SolatifySpacing.xs,
          ),
          child: ExcludeSemantics(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: SolatifyTapTarget.min - 2 * SolatifySpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place_rounded,
                    size: SolatifyIconSize.inline + 2,
                    color: accent,
                  ),
                  const SizedBox(width: SolatifySpacing.xs),
                  Flexible(
                    child: Text(
                      locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SolatifyColors.text(context),
                        fontSize: SolatifyType.body,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: SolatifySpacing.sm),
                  AnimatedSwitcher(
                    duration: SolatifyMotion.of(context, SolatifyMotion.fast),
                    child: location.isLoading
                        ? SizedBox.square(
                            key: const ValueKey('location-loading'),
                            dimension: SolatifyIconSize.inline,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: accent,
                            ),
                          )
                        : Row(
                            key: const ValueKey('location-edit'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_location_alt_outlined,
                                size: SolatifyIconSize.inline,
                                color: accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l.isEnglish ? 'Change' : 'Ubah',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: SolatifyType.caption,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SolatifyColors.text(context),
                fontSize: SolatifyType.sectionTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _QuickAccessItem {
  const _QuickAccessItem(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      _QuickAccessItem(l.navQibla, Icons.explore_outlined, AppRoutes.qibla),
      // Same word in both languages; navTracker is too long for a tile.
      const _QuickAccessItem(
        'Tracker',
        Icons.task_alt_rounded,
        AppRoutes.tracker,
      ),
      _QuickAccessItem(l.navMosque, Icons.mosque_outlined, AppRoutes.mosque),
      _QuickAccessItem(
        l.isEnglish ? 'Dhikr' : 'Dzikir',
        Icons.auto_awesome_outlined,
        AppRoutes.dhikr,
      ),
      _QuickAccessItem(l.navQuran, Icons.menu_book_outlined, AppRoutes.quran),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 5 tiles in one row on typical phones and wider; 3 per row on very
        // narrow screens (e.g. 320px) so labels stay legible.
        final columns = constraints.maxWidth < 300 ? 3 : items.length;
        const spacing = SolatifySpacing.sm;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: tileWidth,
                child: _QuickAccessTile(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({required this.item});

  final _QuickAccessItem item;

  @override
  Widget build(BuildContext context) {
    final accent = SolatifyColors.accent(context);

    return Tooltip(
      message: item.label,
      excludeFromSemantics: true,
      child: GlassContainer(
        borderRadius: SolatifyRadius.md,
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: SolatifySpacing.sm,
        ),
        onTap: () {
          SolatifyHaptics.selection();
          context.go(item.route);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: SolatifyIconSize.cardBox,
              height: SolatifyIconSize.cardBox,
              decoration: BoxDecoration(
                color: SolatifyColors.accentSoft(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Icon(
                item.icon,
                color: accent,
                size: SolatifyIconSize.cardIcon,
              ),
            ),
            const SizedBox(height: SolatifySpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: SolatifyColors.text(context),
                  fontSize: SolatifyType.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.item,
    required this.isNext,
    required this.isActive,
  });

  final PrayerItemEntity item;
  final bool isNext;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = SolatifyColors.accent(context);
    final name = l.prayerName(item.key);
    final formattedTime = DateFormat('HH:mm').format(item.time);
    final highlighted = isActive || isNext;

    final String? badge = isActive
        ? (l.isEnglish ? 'Now' : 'Sekarang')
        : isNext
        ? (l.isEnglish ? 'Next' : 'Berikutnya')
        : null;

    final semanticsLabel = [
      name,
      formattedTime,
      if (badge != null) badge,
    ].join(', ');

    return Semantics(
      container: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: GlassContainer(
        borderRadius: SolatifyRadius.md,
        fillColor: isActive
            ? Color.alphaBlend(
                SolatifyColors.accentSoft(context),
                SolatifyColors.softSurface(context),
              )
            : null,
        borderColor: isActive
            ? SolatifyColors.borderStrong(context)
            : isNext
            ? accent.withValues(alpha: 0.30)
            : null,
        padding: const EdgeInsets.symmetric(
          horizontal: SolatifySpacing.lg,
          vertical: SolatifySpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: SolatifyIconSize.cardBox,
              height: SolatifyIconSize.cardBox,
              decoration: BoxDecoration(
                color: highlighted
                    ? accent
                    : SolatifyColors.raisedSurface(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Icon(
                _prayerIcon(item.key),
                size: SolatifyIconSize.cardIcon,
                color: highlighted
                    ? SolatifyColors.onAccent(context)
                    : SolatifyColors.muted(context),
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
                      color: isActive ? accent : SolatifyColors.text(context),
                      fontSize: SolatifyType.cardTitle,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: SolatifyMotion.of(context, SolatifyMotion.medium),
                    child: badge == null
                        ? const SizedBox.shrink(key: ValueKey('no-badge'))
                        : _StatusBadge(
                            key: ValueKey(badge),
                            label: badge,
                            filled: isActive,
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Text(
              formattedTime,
              style: TextStyle(
                color: highlighted ? accent : SolatifyColors.text(context),
                fontSize: SolatifyType.sectionTitle,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({super.key, required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accent = SolatifyColors.accent(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? accent : SolatifyColors.accentSoft(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: TextStyle(
          color: filled ? SolatifyColors.onAccent(context) : accent,
          fontSize: SolatifyType.eyebrow,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PrayerCountdownCard extends StatelessWidget {
  const _PrayerCountdownCard({required this.countdown, this.nextPrayerTime});

  final CountdownState countdown;
  final String? nextPrayerTime;

  String _spokenRemaining(AppLocalizations l) {
    final d = countdown.remainingDuration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final parts = <String>[];
    if (l.isEnglish) {
      if (hours > 0) parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
      parts.add('$minutes ${minutes == 1 ? 'minute' : 'minutes'}');
      return '${parts.join(' ')} left until '
          '${l.prayerName(countdown.nextPrayerName)}';
    }
    if (hours > 0) parts.add('$hours jam');
    parts.add('$minutes menit');
    return 'Sisa ${parts.join(' ')} menuju '
        '${l.prayerName(countdown.nextPrayerName)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWaitingForSchedule = countdown.nextPrayerKey.isEmpty;
    final accent = SolatifyColors.accent(context);
    final muted = SolatifyColors.muted(context);

    return GlassContainer(
      borderColor: SolatifyColors.borderStrong(context),
      padding: const EdgeInsets.fromLTRB(
        SolatifySpacing.lg + 2,
        SolatifySpacing.lg + 2,
        SolatifySpacing.lg + 2,
        SolatifySpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: SolatifyIconSize.cardBox,
                height: SolatifyIconSize.cardBox,
                decoration: BoxDecoration(
                  color: SolatifyColors.accentSoft(context),
                  borderRadius: SolatifyRadius.icon,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: accent,
                  size: SolatifyIconSize.cardIcon,
                ),
              ),
              const SizedBox(width: SolatifySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isWaitingForSchedule
                          ? l.preparingPrayerSchedule
                          : l.headingToPrayer(
                              l.prayerName(countdown.nextPrayerName),
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SolatifyColors.text(context),
                        fontSize: SolatifyType.cardTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isWaitingForSchedule
                          ? l.countdownWaiting
                          : l.currentPrayerTime(
                              l.prayerName(countdown.activePrayerName),
                            ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: muted,
                        fontSize: SolatifyType.caption,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isWaitingForSchedule && nextPrayerTime != null) ...[
                const SizedBox(width: SolatifySpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SolatifySpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: SolatifyColors.accentSoft(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    nextPrayerTime!,
                    style: TextStyle(
                      color: accent,
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SolatifySpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: SolatifySpacing.lg,
              vertical: SolatifySpacing.md,
            ),
            decoration: BoxDecoration(
              color: SolatifyColors.accentSoft(context),
              borderRadius: SolatifyRadius.compactCard,
              border: Border.all(color: SolatifyColors.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.remainingTime,
                  style: TextStyle(
                    color: muted,
                    fontSize: SolatifyType.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SolatifySpacing.xs),
                AnimatedSwitcher(
                  duration: SolatifyMotion.of(context, SolatifyMotion.medium),
                  child: isWaitingForSchedule
                      ? Padding(
                          key: const ValueKey('countdown-waiting'),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: accent,
                              semanticsLabel: l.preparingPrayerSchedule,
                            ),
                          ),
                        )
                      : Semantics(
                          key: const ValueKey('countdown-ready'),
                          label: _spokenRemaining(l),
                          excludeSemantics: true,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              countdown.formattedTime,
                              style: TextStyle(
                                color: accent,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
