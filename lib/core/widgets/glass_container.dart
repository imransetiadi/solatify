import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:solatify/core/performance/performance_tuning.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultFill =
        fillColor ?? (isDark ? const Color(0xFF123724) : Colors.white);

    final defaultBorder =
        borderColor ??
        (isDark
            ? const Color(0xFFE85D4F).withValues(alpha: 0.10)
            : const Color(0xFFC0392B).withValues(alpha: 0.08));
    final effectiveBlur = blur
        .clamp(0, PerformanceTuning.maxGlassBlurSigma)
        .toDouble();

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: const BoxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: effectiveBlur > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: _GlassBody(
                  padding: padding,
                  borderRadius: borderRadius,
                  fill: defaultFill,
                  border: defaultBorder,
                  child: child,
                ),
              )
            : _GlassBody(
                padding: padding,
                borderRadius: borderRadius,
                fill: defaultFill,
                border: defaultBorder,
                child: child,
              ),
      ),
    );
  }
}

class _GlassBody extends StatelessWidget {
  const _GlassBody({
    required this.child,
    required this.borderRadius,
    required this.fill,
    required this.border,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final Color fill;
  final Color border;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border),
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
