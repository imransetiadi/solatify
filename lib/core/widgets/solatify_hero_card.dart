import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

class SolatifyHeroCard extends StatelessWidget {
  const SolatifyHeroCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.actions = const [],
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = theme.colorScheme.tertiary;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = isDark
        ? const Color(0xFFC7B3A1)
        : const Color(0xFF725F52);

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      borderColor: SolatifyColors.border(context),
      fillColor: SolatifyColors.softSurface(context),
      padding: SolatifySpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SolatifyIconSize.heroBox,
                height: SolatifyIconSize.heroBox,
                decoration: BoxDecoration(
                  borderRadius: SolatifyRadius.icon,
                  color: accent,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: SolatifyIconSize.heroIcon,
                ),
              ),
              const SizedBox(width: ResponsiveLayout.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: TextStyle(
                        color: accent,
                        fontSize: SolatifyType.eyebrow,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: SolatifyType.heroTitle,
                        height: 1.12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
          const SizedBox(height: ResponsiveLayout.itemGap),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mutedColor,
              fontSize: SolatifyType.body,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: ResponsiveLayout.itemGap),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}
