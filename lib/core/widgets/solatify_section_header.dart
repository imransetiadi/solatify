import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

class SolatifySectionHeader extends StatelessWidget {
  const SolatifySectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.tertiary;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = SolatifyColors.muted(context);

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      borderColor: SolatifyColors.border(context),
      fillColor: SolatifyColors.softSurface(context),
      padding: ResponsiveLayout.cardPadding,
      child: Row(
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
              color: SolatifyColors.onAccent(context),
              size: SolatifyIconSize.heroIcon,
            ),
          ),
          const SizedBox(width: ResponsiveLayout.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: SolatifyType.eyebrow,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: SolatifyType.pageTitle,
                    height: 1.12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: SolatifyType.caption,
                    height: 1.35,
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
