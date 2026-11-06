import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:solatify/core/performance/performance_tuning.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';

/// Card surface used across Solatify.
///
/// Pass [onTap] to make the whole card interactive: it then gets an ink
/// ripple clipped to the card shape, keyboard focus, and is announced as a
/// button by screen readers (optionally with [semanticLabel]).
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 0.0,
    this.opacity = 0.0,
    this.borderRadius = 24.0,
    this.borderColor,
    this.fillColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.semanticLabel,
    this.selected = false,
  });
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? semanticLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final defaultFill = fillColor ?? SolatifyColors.softSurface(context);
    final defaultBorder = borderColor ?? SolatifyColors.border(context);
    final effectiveBlur = blur
        .clamp(0, PerformanceTuning.maxGlassBlurSigma)
        .toDouble();
    final radius = BorderRadius.circular(borderRadius);

    final body = _GlassBody(
      padding: padding,
      borderRadius: radius,
      fill: defaultFill,
      border: defaultBorder,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );

    Widget card = ClipRRect(
      borderRadius: radius,
      child: effectiveBlur > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlur,
                sigmaY: effectiveBlur,
              ),
              child: body,
            )
          : body,
    );

    if (onTap != null || semanticLabel != null) {
      card = Semantics(
        button: onTap != null,
        selected: selected,
        label: semanticLabel,
        container: true,
        child: card,
      );
    }

    return Container(width: width, height: height, margin: margin, child: card);
  }
}

class _GlassBody extends StatelessWidget {
  const _GlassBody({
    required this.child,
    required this.borderRadius,
    required this.fill,
    required this.border,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Color fill;
  final Color border;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null && onLongPress == null
          ? content
          : InkWell(onTap: onTap, onLongPress: onLongPress, child: content),
    );
  }
}
