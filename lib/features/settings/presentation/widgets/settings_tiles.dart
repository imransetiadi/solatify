import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

/// Minimum height of a settings row (Material list guidance).
const double _kSettingsRowMinHeight = 56;

/// Horizontal inset used by rows inside a [SettingsGroup].
const double _kRowHorizontalPadding = SolatifySpacing.sm;

/// Width of the leading icon box + gap, used to indent dividers.
const double _kDividerIndent =
    _kRowHorizontalPadding + SolatifyIconSize.cardBox + SolatifySpacing.md;

/// Uppercase section label announced as a header by screen readers.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.description,
  });

  final String title;
  final IconData? icon;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final muted = SolatifyColors.muted(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SolatifySpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: SolatifyIconSize.inline,
                    color: SolatifyColors.accent(context),
                  ),
                  const SizedBox(width: SolatifySpacing.xs),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: SolatifyType.caption,
                      fontWeight: FontWeight.w800,
                      color: muted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: TextStyle(
                fontSize: SolatifyType.caption,
                color: SolatifyColors.subtle(context),
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card that stacks settings rows with inset dividers between them.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      thickness: 1,
      indent: _kDividerIndent,
      endIndent: _kRowHorizontalPadding,
      color: SolatifyColors.border(context),
    );

    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) separated.add(divider);
      separated.add(children[i]);
    }

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      padding: const EdgeInsets.all(SolatifySpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: separated,
      ),
    );
  }
}

/// Tinted rounded box holding a row's leading icon.
class SettingsIconBox extends StatelessWidget {
  const SettingsIconBox({super.key, required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? SolatifyColors.accent(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: Container(
        width: SolatifyIconSize.cardBox,
        height: SolatifyIconSize.cardBox,
        decoration: BoxDecoration(
          color: tint.withValues(alpha: isDark ? 0.16 : 0.10),
          borderRadius: SolatifyRadius.icon,
        ),
        child: Icon(icon, color: tint, size: SolatifyIconSize.cardIcon),
      ),
    );
  }
}

/// Standard settings row: icon box, title, current value, trailing widget.
///
/// When [onTap] is set, the whole row is tappable with an ink ripple and a
/// chevron is shown unless a custom [trailing] widget is provided.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.valueMaxLines = 2,
    this.highlightValue = false,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.semanticHint,
  });

  final IconData icon;
  final String title;

  /// Current value / description rendered under the title.
  final String? value;
  final int? valueMaxLines;

  /// Render [value] in the accent color (e.g. a non-default value).
  final bool highlightValue;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final textColor = SolatifyColors.text(context);
    final valueColor = highlightValue
        ? SolatifyColors.accent(context)
        : SolatifyColors.muted(context);
    final duration = SolatifyMotion.of(context, SolatifyMotion.fast);

    final effectiveTrailing =
        trailing ??
        (onTap == null
            ? null
            : ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: SolatifyColors.subtle(context),
                ),
              ));

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _kSettingsRowMinHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kRowHorizontalPadding,
          vertical: SolatifySpacing.sm,
        ),
        child: Row(
          children: [
            SettingsIconBox(icon: icon, color: iconColor),
            const SizedBox(width: SolatifySpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: SolatifyType.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (value != null) ...[
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: duration,
                      switchInCurve: SolatifyMotion.curve,
                      layoutBuilder: (current, previous) => Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [...previous, if (current != null) current],
                      ),
                      child: Text(
                        value!,
                        key: ValueKey<String>(value!),
                        maxLines: valueMaxLines,
                        overflow: valueMaxLines == null
                            ? null
                            : TextOverflow.ellipsis,
                        style: TextStyle(
                          color: valueColor,
                          fontSize: SolatifyType.caption,
                          fontWeight: highlightValue
                              ? FontWeight.w700
                              : FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (effectiveTrailing != null) ...[
              const SizedBox(width: SolatifySpacing.sm),
              effectiveTrailing,
            ],
          ],
        ),
      ),
    );

    if (onTap == null) return MergeSemantics(child: row);

    return MergeSemantics(
      child: Semantics(
        hint: semanticHint,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: SolatifyRadius.icon,
            onTap: onTap,
            child: row,
          ),
        ),
      ),
    );
  }
}

/// Settings row with a trailing switch; tapping anywhere toggles it.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: icon,
      title: title,
      value: description,
      valueMaxLines: null,
      onTap: () => onChanged(!value),
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
    );
  }
}

/// Small bold label introducing a group of chips inside a settings card.
class SettingsSubheading extends StatelessWidget {
  const SettingsSubheading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        title,
        style: TextStyle(
          color: SolatifyColors.text(context),
          fontSize: SolatifyType.caption,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
