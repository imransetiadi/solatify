import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/prayer_times_provider.dart';
import 'package:solatify/features/prayer_schedule/presentation/widgets/manual_location_dialog.dart';
import '../providers/countdown_provider.dart';

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
    final prayerList = ref.watch(prayerListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.readableAccent(context);
    final redLine = Theme.of(context).colorScheme.tertiary;
    final textColor = isDark
        ? const Color(0xFFFFF7ED)
        : const Color(0xFF241A12);
    final mutedColor = isDark
        ? const Color(0xFFE0D4C4)
        : const Color(0xFFAFA19A);

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
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: ResponsiveLayout.pageTopGap),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.10),
                            borderRadius: SolatifyRadius.compactCard,
                            border: Border.all(
                              color: primary.withValues(alpha: 0.16),
                            ),
                          ),
                          child: SvgPicture.asset(
                            'assets/images/masjid_nabawi.svg',
                            width: 34,
                            height: 34,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.greeting,
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: SolatifyType.caption,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Solatify',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: SolatifyType.heroTitle,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    '${location.city}, ${location.country}',
                                    style: TextStyle(
                                      color: mutedColor,
                                      fontSize: SolatifyType.caption,
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () => showManualLocationDialog(
                                      context: context,
                                      ref: ref,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      child: Icon(
                                        Icons.edit_location_alt_outlined,
                                        size: SolatifyIconSize.inline,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 22, bottom: 4),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final countdown = ref.watch(countdownProvider);
                        return _PrayerCountdownCard(
                          countdown: countdown,
                          primaryColor: primary,
                          accentColor: redLine,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          isDark: isDark,
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveLayout.pagePadding(
                      context,
                    ).copyWith(top: 18, bottom: 12),
                    child: Text(
                      l.prayerSchedule,
                      style: TextStyle(
                        color: textColor,
                        fontSize: SolatifyType.sectionTitle,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveLayout.pagePadding(context).left,
                  ),
                  sliver: prayerList.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = prayerList[index];
                            final isNext =
                                countdownMarkers.nextPrayerKey == item.key;
                            final isActive =
                                countdownMarkers.activePrayerName == item.name;
                            final formattedTime = DateFormat(
                              'HH:mm',
                            ).format(item.time);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassContainer(
                                opacity: isActive ? 0.08 : 0.03,
                                borderColor: isActive || isNext
                                    ? redLine.withValues(
                                        alpha: isActive ? 0.8 : 0.45,
                                      )
                                    : redLine.withValues(
                                        alpha: isDark ? 0.30 : 0.22,
                                      ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      color: isActive || isNext
                                          ? redLine
                                          : mutedColor.withValues(alpha: 0.35),
                                      size: 10,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: isActive
                                                  ? redLine
                                                  : textColor,
                                              fontSize: SolatifyType.cardTitle,
                                              fontWeight: isActive
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            formattedTime,
                                            style: TextStyle(
                                              color: mutedColor,
                                              fontSize: SolatifyType.caption,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: prayerList.length),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerCountdownCard extends StatelessWidget {
  const _PrayerCountdownCard({
    required this.countdown,
    required this.primaryColor,
    required this.accentColor,
    required this.textColor,
    required this.mutedColor,
    required this.isDark,
  });

  final CountdownState countdown;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isWaitingForSchedule = countdown.nextPrayerKey.isEmpty;

    return GlassContainer(
      opacity: isDark ? 0.06 : 0.035,
      borderColor: accentColor.withValues(alpha: isDark ? 0.45 : 0.28),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: SolatifyIconSize.cardBox,
                height: SolatifyIconSize.cardBox,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.13),
                  borderRadius: SolatifyRadius.compactCard,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: primaryColor,
                  size: SolatifyIconSize.cardIcon,
                ),
              ),
              const SizedBox(width: 12),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: SolatifyType.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: SolatifyRadius.compactCard,
              border: Border.all(color: accentColor.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.remainingTime,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: SolatifyType.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    countdown.formattedTime,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
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
