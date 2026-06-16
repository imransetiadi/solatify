import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/prayer_guide/domain/models/prayer_guide_step.dart';
import 'package:solatify/features/prayer_guide/presentation/providers/prayer_guide_provider.dart';

class PrayerGuideScreen extends ConsumerWidget {
  const PrayerGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = AppTheme.readableAccent(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = theme.brightness == Brightness.dark
        ? AppTheme.darkModeTextSecondary
        : AppTheme.lightModeTextSecondary;
    final appBarColor = theme.colorScheme.surface.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.96 : 0.94,
    );
    final summaries = ref.watch(prayerGuideSummariesProvider);
    final steps = ref.watch(prayerGuideStepsProvider);
    final dhikrItems = ref.watch(postPrayerDhikrProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/islamic-content'),
        ),
        title: Text(
          'Tuntunan Salat',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: ListView(
            scrollCacheExtent: const ScrollCacheExtent.pixels(10000),
            padding: ResponsiveLayout.pagePadding(
              context,
            ).copyWith(top: 16, bottom: 96),
            children: [
              const IslamicHeaderDecoration(
                title: 'Tuntunan Salat Lengkap',
                subtitle: 'Urutan gerakan, bacaan, dan makna ringkas',
              ),
              const SizedBox(height: 18),
              _OpeningReadingCard(
                primaryColor: primaryColor,
                textColor: textColor,
                mutedColor: mutedColor,
              ),
              const SizedBox(height: 18),
              _SectionHeader(
                icon: Icons.fact_check_outlined,
                title: 'Ringkasan Penting',
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              ...summaries.map(
                (summary) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SummaryCard(
                    summary: summary,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _SectionHeader(
                icon: Icons.format_list_numbered,
                title: 'Urutan Salat',
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              ...steps.map(
                (step) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _PrayerStepCard(
                    step: step,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _SectionHeader(
                icon: Icons.auto_awesome,
                title: 'Dzikir Setelah Salat',
                color: primaryColor,
              ),
              const SizedBox(height: 12),
              ...dhikrItems.map(
                (dhikr) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _DhikrCard(
                    dhikr: dhikr,
                    primaryColor: primaryColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpeningReadingCard extends StatelessWidget {
  const _OpeningReadingCard({
    required this.primaryColor,
    required this.textColor,
    required this.mutedColor,
  });

  final Color primaryColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niat dan Takbiratul Ihram',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Niat',
            style: TextStyle(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Awali salat dengan niat di dalam hati, lalu ucapkan takbir pembuka.',
            style: TextStyle(color: mutedColor, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          _ArabicTextBlock(
            text: 'اَللّٰهُ أَكْبَرُ',
            textColor: textColor,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 10),
          _LabelText(label: 'Latin', value: 'Allahu akbar.', color: mutedColor),
          const SizedBox(height: 6),
          _LabelText(
            label: 'Arti',
            value: 'Allah Maha Besar.',
            color: mutedColor,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.primaryColor,
    required this.textColor,
    required this.mutedColor,
  });

  final PrayerGuideSummary summary;
  final Color primaryColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary.title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...summary.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerStepCard extends StatelessWidget {
  const _PrayerStepCard({
    required this.step,
    required this.primaryColor,
    required this.textColor,
    required this.mutedColor,
  });

  final PrayerGuideStep step;
  final Color primaryColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: primaryColor.withValues(alpha: 0.14),
                child: Text(
                  '${step.number}',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ArabicTextBlock(
            text: step.arabicText,
            textColor: textColor,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),
          _LabelText(label: 'Latin', value: step.latinText, color: mutedColor),
          const SizedBox(height: 8),
          _LabelText(label: 'Arti', value: step.meaning, color: mutedColor),
          if (step.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            _NoteBox(
              text: step.note,
              color: primaryColor,
              textColor: mutedColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.dhikr,
    required this.primaryColor,
    required this.textColor,
    required this.mutedColor,
  });

  final PostPrayerDhikr dhikr;
  final Color primaryColor;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dhikr.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${dhikr.count}x',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ArabicTextBlock(
            text: dhikr.arabicText,
            textColor: textColor,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 12),
          _LabelText(label: 'Latin', value: dhikr.latinText, color: mutedColor),
          const SizedBox(height: 8),
          _LabelText(label: 'Arti', value: dhikr.meaning, color: mutedColor),
        ],
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  const _LabelText({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
      style: TextStyle(color: color, fontSize: 13, height: 1.45),
    );
  }
}

class _ArabicTextBlock extends StatelessWidget {
  const _ArabicTextBlock({
    required this.text,
    required this.textColor,
    required this.primaryColor,
  });

  final String text;
  final Color textColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('prayer_guide_arabic_text'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        softWrap: true,
        style: TextStyle(
          color: textColor,
          fontSize: 23,
          height: 1.9,
          fontFamily: 'Kufi',
        ),
      ),
    );
  }
}

class _NoteBox extends StatelessWidget {
  const _NoteBox({
    required this.text,
    required this.color,
    required this.textColor,
  });

  final String text;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, height: 1.45),
      ),
    );
  }
}
