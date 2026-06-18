import 'package:flutter/material.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

enum SolatifyStateVariant { loading, empty, error, permission }

class SolatifyStateView extends StatelessWidget {
  const SolatifyStateView({
    super.key,
    required this.variant,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  const SolatifyStateView.loading({
    super.key,
    this.title = 'Memuat data',
    this.description = 'Sebentar ya, Solatify sedang menyiapkan konten.',
    this.icon = Icons.hourglass_empty_rounded,
    this.compact = false,
  }) : variant = SolatifyStateVariant.loading,
       actionLabel = null,
       onAction = null;

  const SolatifyStateView.empty({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : variant = SolatifyStateVariant.empty;

  const SolatifyStateView.error({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.error_outline_rounded,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : variant = SolatifyStateVariant.error;

  const SolatifyStateView.permission({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.lock_outline_rounded,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  }) : variant = SolatifyStateVariant.permission;

  final SolatifyStateVariant variant;
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFF6A5B51);
    final accentColor = _accentColor(context);

    return Center(
      child: GlassContainer(
        borderRadius: SolatifyRadius.md,
        borderColor: accentColor.withValues(alpha: 0.12),
        fillColor: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.88 : 0.96,
        ),
        padding: compact
            ? ResponsiveLayout.listCardPadding
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (variant == SolatifyStateVariant.loading)
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: accentColor,
                ),
              )
            else
              Container(
                width: SolatifyIconSize.heroBox,
                height: SolatifyIconSize.heroBox,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: SolatifyRadius.icon,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: SolatifyIconSize.heroIcon,
                ),
              ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: SolatifyType.cardTitle,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedColor,
                fontSize: SolatifyType.caption,
                height: 1.4,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh, size: SolatifyIconSize.inline),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _accentColor(BuildContext context) {
    return switch (variant) {
      SolatifyStateVariant.error => Theme.of(context).colorScheme.error,
      SolatifyStateVariant.permission => Theme.of(context).colorScheme.tertiary,
      SolatifyStateVariant.empty => AppTheme.readableAccent(context),
      SolatifyStateVariant.loading => AppTheme.readableAccent(context),
    };
  }
}
