import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double maxContentWidth = 760;
}

class ResponsiveLayout {
  static double itemGapFor(BuildContext context) =>
      isCompact(context) ? 10 : 12;
  static double sectionGapFor(BuildContext context) =>
      isCompact(context) ? 16 : 22;
  static const double itemGap = 12;
  static const double sectionGap = 22;
  static const double pageTopGap = 12;
  static const double bottomSafeGap = SolatifySpacing.bottomNav;
  static const EdgeInsets cardPadding = SolatifySpacing.card;
  static const EdgeInsets listCardPadding = EdgeInsets.symmetric(
    horizontal: 15,
    vertical: 13,
  );

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.compact;
  }

  static bool isMediumOrLarger(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppBreakpoints.compact;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360
        ? 14.0
        : width < AppBreakpoints.compact
        ? 17.0
        : 26.0;
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: itemGapFor(context),
    );
  }

  static double constrainedWidth(
    BuildContext context, {
    double maxWidth = AppBreakpoints.maxContentWidth,
  }) {
    return math.min(MediaQuery.sizeOf(context).width, maxWidth);
  }
}

class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
