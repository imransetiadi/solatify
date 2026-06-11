import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double maxContentWidth = 760;
}

class ResponsiveLayout {
  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).width < AppBreakpoints.compact;
  }

  static bool isMediumOrLarger(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= AppBreakpoints.compact;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360
        ? 16.0
        : width < AppBreakpoints.compact
        ? 20.0
        : 32.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 12);
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
