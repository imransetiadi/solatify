import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../../../core/widgets/responsive_layout.dart';
import '../../../islamic_tips/presentation/providers/tips_provider.dart';

class IslamicContentScreen extends ConsumerWidget {
  const IslamicContentScreen({super.key});

  static const _menuItems = [
    _ContentMenuItem(
      title: 'Asmaul Husna',
      subtitle: '99 nama indah Allah',
      icon: Icons.font_download_outlined,
      path: '/islamic-content/asmaul-husna',
    ),
    _ContentMenuItem(
      title: 'Doa Harian',
      subtitle: 'Kumpulan doa sehari-hari',
      icon: Icons.volunteer_activism_outlined,
      path: '/islamic-content/duas',
    ),
    _ContentMenuItem(
      title: 'Kalender Hijriah',
      subtitle: 'Tanggal dan peristiwa Islam',
      icon: Icons.calendar_month_outlined,
      path: '/islamic-content/hijri-calendar',
    ),
    _ContentMenuItem(
      title: 'Dzikir',
      subtitle: 'Dzikir pagi dan petang',
      icon: Icons.wb_twilight_outlined,
      path: '/islamic-content/dhikr',
    ),
    _ContentMenuItem(
      title: 'Tips Islami',
      subtitle: 'Nasihat dan amalan ringan',
      icon: Icons.lightbulb_outline,
      path: '/islamic-content/tips',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF3FBF6) : const Color(0xFF241A12);
    final mutedColor = isDark ? const Color(0xFFC8B8A8) : const Color(0xFF6E5B4B);
    final primaryColor = isDark ? const Color(0xFFC78A4C) : const Color(0xFF0E4D31);
    final surfaceColor = isDark ? const Color(0xFF241A14) : Colors.white;
    final backgroundColor = isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6);
    final randomTip = ref.watch(randomTipProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(
          'Konten Islami',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: IslamicGeometricPattern(
              color: primaryColor,
              opacity: isDark ? 0.03 : 0.05,
            ),
          ),
          ResponsiveCenter(
            child: ListView(
              padding: ResponsiveLayout.pagePadding(context).copyWith(bottom: 96),
              children: [
                const IslamicHeaderDecoration(
                  title: 'Jelajahi Spiritual',
                  subtitle: 'Ilmu, doa, dzikir, dan amalan harian',
                ),
                const SizedBox(height: 8),
                _SectionTitle(
                  icon: Icons.auto_awesome,
                  title: 'Tip Harian',
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                _DailyTipCard(
                  title: randomTip.title,
                  content: randomTip.content,
                  reference: randomTip.reference,
                  surfaceColor: surfaceColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                  onTap: () => context.go('/islamic-content/tips'),
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  icon: Icons.grid_view_rounded,
                  title: 'Menu Konten',
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth >= 720 ? 3 : 2;
                    final cardHeight = constraints.maxWidth < 380 ? 170.0 : 156.0;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _menuItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: cardHeight,
                      ),
                      itemBuilder: (context, index) {
                        final item = _menuItems[index];
                        return _ContentMenuCard(
                          item: item,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          primaryColor: primaryColor,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({
    required this.title,
    required this.content,
    required this.reference,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
    required this.onTap,
  });

  final String title;
  final String content;
  final String reference;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
            ),
            const SizedBox(height: 8),
            Text(content, style: TextStyle(fontSize: 14, height: 1.45, color: mutedColor)),
            const SizedBox(height: 10),
            Text(
              'Ref: $reference',
              style: TextStyle(fontStyle: FontStyle.italic, color: mutedColor, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Lihat Semua Tips'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentMenuCard extends StatelessWidget {
  const _ContentMenuCard({
    required this.item,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
    required this.primaryColor,
  });

  final _ContentMenuItem item;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      elevation: 1,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(item.path),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: primaryColor, size: 23),
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, height: 1.25, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentMenuItem {
  const _ContentMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.path,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String path;
}
