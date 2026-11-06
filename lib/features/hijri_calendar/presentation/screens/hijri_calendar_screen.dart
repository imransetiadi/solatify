import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/localization/islamic_content_localizer.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_screen_scaffold.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/hijri_calendar/domain/entities/hijri_event.dart';
import 'package:solatify/features/hijri_calendar/presentation/providers/hijri_calendar_provider.dart';

const List<String> _hijriMonthsId = [
  'Muharram',
  'Safar',
  'Rabiul Awal',
  'Rabiul Akhir',
  'Jumadil Awal',
  'Jumadil Akhir',
  'Rajab',
  'Syaban',
  'Ramadhan',
  'Syawal',
  'Dzulqaidah',
  'Dzulhijjah',
];

const List<String> _hijriMonthsEn = [
  'Muharram',
  'Safar',
  'Rabi al-Awwal',
  'Rabi al-Thani',
  'Jumada al-Ula',
  'Jumada al-Akhirah',
  'Rajab',
  'Shaban',
  'Ramadan',
  'Shawwal',
  'Dhu al-Qadah',
  'Dhu al-Hijjah',
];

String _hijriDateLabel(AppLocalizations l, HijriEvent event) {
  final months = l.isEnglish ? _hijriMonthsEn : _hijriMonthsId;
  final index = event.hijriMonth - 1;
  if (index < 0 || index >= months.length) {
    return '${event.hijriDay}/${event.hijriMonth}/${event.hijriYear} H';
  }
  return '${event.hijriDay} ${months[index]} ${event.hijriYear} H';
}

String _countdownLabel(AppLocalizations l, int days) {
  if (days <= 0) return l.isEnglish ? 'Today' : 'Hari ini';
  if (days == 1) return l.isEnglish ? 'Tomorrow' : 'Besok';
  return l.isEnglish ? 'In $days days' : '$days hari lagi';
}

class HijriCalendarScreen extends ConsumerWidget {
  const HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final eventsAsync = ref.watch(upcomingHijriEventsProvider);

    return SolatifyScreenScaffold(
      title: l.isEnglish ? 'Hijri Calendar' : 'Kalender Hijriah',
      backRoute: AppRoutes.islamicContent,
      padding: ResponsiveLayout.pagePadding(context).copyWith(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.event,
                  size: 20,
                  color: SolatifyColors.accent(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l.isEnglish
                        ? 'Upcoming Islamic Holidays & Events'
                        : 'Hari Raya & Event Islam Mendatang',
                    style: TextStyle(
                      fontSize: SolatifyType.sectionTitle,
                      fontWeight: FontWeight.bold,
                      color: SolatifyColors.text(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.md),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return SolatifyStateView.empty(
                    title: l.isEnglish
                        ? 'No Hijri events'
                        : 'Tidak ada event Hijriah',
                    description: l.isEnglish
                        ? 'There are no upcoming events in the Hijri calendar yet.'
                        : 'Belum ada event mendatang di kalender Hijriah.',
                    icon: Icons.event_busy_outlined,
                    compact: true,
                  );
                }
                final today = DateUtils.dateOnly(DateTime.now());
                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: ResponsiveLayout.bottomSafeGap,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final days = DateUtils.dateOnly(
                      event.gregorianDate,
                    ).difference(today).inDays;
                    return _HijriEventCard(
                      event: event,
                      daysUntil: days,
                      isNext: index == 0,
                    );
                  },
                );
              },
              loading: () => SolatifyStateView.loading(
                title: l.isEnglish
                    ? 'Loading Hijri calendar'
                    : 'Memuat kalender Hijriah',
                description: l.isEnglish
                    ? 'Preparing upcoming Hijri events.'
                    : 'Menyiapkan event Hijriah mendatang.',
              ),
              error: (error, stackTrace) {
                debugPrint('Hijri events failed to load: $error');
                return SolatifyStateView.error(
                  title: l.tr('Gagal memuat event Hijriah'),
                  description: l.isEnglish
                      ? 'Please try again.'
                      : 'Silakan coba lagi.',
                  actionLabel: l.isEnglish ? 'Try again' : 'Coba lagi',
                  onAction: () => ref.invalidate(hijriEventsProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HijriEventCard extends StatelessWidget {
  const _HijriEventCard({
    required this.event,
    required this.daysUntil,
    required this.isNext,
  });

  final HijriEvent event;
  final int daysUntil;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = l.isEnglish ? 'en_US' : 'id_ID';
    final accent = SolatifyColors.accent(context);
    final textColor = SolatifyColors.text(context);
    final muted = SolatifyColors.muted(context);
    final dateStr = DateFormat(
      'EEEE, d MMMM yyyy',
      locale,
    ).format(event.gregorianDate);
    final monthShort = DateFormat('MMM', locale).format(event.gregorianDate);
    final countdown = _countdownLabel(l, daysUntil);

    return GlassContainer(
      margin: const EdgeInsets.symmetric(vertical: 6),
      borderRadius: SolatifyRadius.lg,
      borderColor: isNext ? SolatifyColors.borderStrong(context) : null,
      padding: SolatifySpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gregorian date badge.
              ExcludeSemantics(
                child: Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isNext ? accent : SolatifyColors.accentSoft(context),
                    borderRadius: SolatifyRadius.icon,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${event.gregorianDate.day}',
                        style: TextStyle(
                          fontSize: SolatifyType.heroTitle,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: isNext
                              ? SolatifyColors.onAccent(context)
                              : accent,
                        ),
                      ),
                      Text(
                        monthShort.toUpperCase(),
                        style: TextStyle(
                          fontSize: SolatifyType.eyebrow,
                          fontWeight: FontWeight.w700,
                          color: isNext
                              ? SolatifyColors.onAccent(context)
                              : accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: SolatifySpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (isNext)
                          _Badge(
                            label: l.isEnglish ? 'Next' : 'Terdekat',
                            icon: Icons.near_me_outlined,
                            color: accent,
                          ),
                        _Badge(
                          label: countdown,
                          icon: Icons.schedule_rounded,
                          color: daysUntil <= 7
                              ? SolatifyColors.warning(context)
                              : muted,
                        ),
                        if (event.isImportant)
                          _Badge(
                            label: l.isEnglish ? 'Important' : 'Penting',
                            icon: Icons.star_rounded,
                            color: SolatifyColors.success(context),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Semantics(
                      header: true,
                      child: Text(
                        l.tr(event.nameId),
                        style: TextStyle(
                          fontSize: SolatifyType.sectionTitle,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (event.nameAr.isNotEmpty) ...[
            const SizedBox(height: SolatifySpacing.sm),
            SizedBox(
              width: double.infinity,
              child: Text(
                event.nameAr,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 22,
                  height: 1.6,
                  color: SolatifyColors.text(context),
                ),
              ),
            ),
          ],
          const SizedBox(height: SolatifySpacing.xs),
          _InfoRow(
            icon: Icons.brightness_3_outlined,
            text: _hijriDateLabel(l, event),
            color: textColor,
            bold: true,
          ),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.calendar_today, text: dateStr, color: muted),
          const SizedBox(height: SolatifySpacing.sm),
          Text(
            l.tr(event.description),
            style: TextStyle(
              fontSize: SolatifyType.body,
              color: textColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ExcludeSemantics(
            child: Icon(icon, size: 14, color: SolatifyColors.accent(context)),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: SolatifyType.body,
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 12, color: color)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: SolatifyType.eyebrow,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
