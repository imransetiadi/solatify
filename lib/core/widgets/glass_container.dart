import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:solatify/core/performance/performance_tuning.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 15.0,
    this.opacity = 0.08,
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
        fillColor ??
        (isDark
            ? const Color(0xFF241A14).withValues(alpha: 0.84)
            : Colors.white.withValues(alpha: 0.92));

    final defaultBorder =
        borderColor ??
        (isDark
            ? const Color(0xFFE85D4F).withValues(alpha: 0.42)
            : const Color(0xFFC0392B).withValues(alpha: 0.32));
    final effectiveBlur = blur
        .clamp(0, PerformanceTuning.maxGlassBlurSigma)
        .toDouble();

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: isDark ? 24 : 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: defaultFill,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: defaultBorder, width: 1.2),
            ),
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      ),
    );
  }
}
