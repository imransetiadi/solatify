import 'package:flutter/material.dart';
import 'package:solatify/core/theme/theme.dart';

class SolatifySpacing {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 22;
  static const double xxl = 30;
  static const double bottomNav = 96;

  static EdgeInsets page(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360
        ? 16.0
        : width < 600
        ? 20.0
        : 32.0;
    return EdgeInsets.fromLTRB(horizontal, md, horizontal, bottomNav);
  }

  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets compactCard = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  static const EdgeInsets listTile = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets pill = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
}

class SolatifyRadius {
  static const double sm = 14;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 30;
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius compactCard = BorderRadius.all(Radius.circular(md));
  static const BorderRadius icon = BorderRadius.all(Radius.circular(sm));
}

/// Semantic color helpers. Prefer these over hardcoded `Color(0x...)` values
/// in widgets so light/dark mode stay consistent and readable.
class SolatifyColors {
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Primary text color on cards and backgrounds.
  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// Secondary text (subtitles, captions). Meets WCAG AA on cards.
  static Color muted(BuildContext context) =>
      _isDark(context) ? AppTheme.textMutedOnDark : AppTheme.textMutedOnLight;

  /// Tertiary/decorative text (hints, disabled). Use for non-essential copy.
  static Color subtle(BuildContext context) =>
      muted(context).withValues(alpha: 0.72);

  /// Brand accent (red) used for highlights, active states and CTAs.
  static Color accent(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  /// Foreground placed on top of a solid [accent] fill.
  static Color onAccent(BuildContext context) =>
      Theme.of(context).colorScheme.onTertiary;

  /// Tinted accent background for chips, icon boxes and selected rows.
  static Color accentSoft(BuildContext context) =>
      accent(context).withValues(alpha: _isDark(context) ? 0.16 : 0.09);

  static Color success(BuildContext context) =>
      _isDark(context) ? AppTheme.successDark : AppTheme.success;

  static Color warning(BuildContext context) =>
      _isDark(context) ? AppTheme.warningDark : AppTheme.warning;

  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  /// Page background behind cards.
  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  /// Default card fill.
  static Color softSurface(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface;
  }

  /// Slightly raised fill for nested elements inside a card.
  static Color raisedSurface(BuildContext context) => Theme.of(context)
      .colorScheme
      .surfaceContainerHighest
      .withValues(alpha: _isDark(context) ? 0.55 : 0.6);

  static Color border(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.14 : 0.10);
  }

  /// Stronger border for focused/highlighted cards.
  static Color borderStrong(BuildContext context) =>
      accent(context).withValues(alpha: _isDark(context) ? 0.55 : 0.40);
}

class SolatifyMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 360);
  static const Curve curve = Curves.easeOutCubic;

  /// Respect the OS "reduce motion" accessibility setting.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false
      ? Duration.zero
      : duration;
}

class SolatifyType {
  static const double heroTitle = 21;
  static const double pageTitle = 19;
  static const double sectionTitle = 16;
  static const double cardTitle = 15;
  static const double body = 14;
  static const double caption = 12;
  static const double eyebrow = 11;
}

class SolatifyIconSize {
  static const double heroBox = 44;
  static const double cardBox = 38;
  static const double heroIcon = 22;
  static const double cardIcon = 19;
  static const double inline = 16;
}

/// Minimum interactive size per Material/HIG accessibility guidance.
class SolatifyTapTarget {
  static const double min = 44;
}
