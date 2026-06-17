import 'package:flutter/material.dart';

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

class SolatifyColors {
  static Color muted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFC7B3A1) : const Color(0xFF725F52);
  }

  static Color softSurface(BuildContext context) {
    final theme = Theme.of(context);
    return theme.colorScheme.surface;
  }

  static Color border(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.10 : 0.08);
  }
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
