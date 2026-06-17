import 'package:flutter/material.dart';
import 'package:solatify/core/theme/theme.dart';

class IslamicGeometricPattern extends StatelessWidget {
  const IslamicGeometricPattern({
    super.key,
    this.opacity = 0.05,
    this.color,
    this.strokeWidth = 1.0,
  });
  final double opacity;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final themeColor =
        color ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Opacity(
      opacity: opacity,
      child: CustomPaint(
        painter: _GeometricPainter(themeColor, strokeWidth),
        child: Container(),
      ),
    );
  }
}

class _GeometricPainter extends CustomPainter {
  _GeometricPainter(this.color, this.strokeWidth);
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    const spacing = 60.0;
    for (double i = -spacing; i < size.width + spacing; i += spacing) {
      for (double j = -spacing; j < size.height + spacing; j += spacing) {
        _drawPatternUnit(canvas, Offset(i, j), spacing, paint);
      }
    }
  }

  void _drawPatternUnit(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final path = Path();
    final half = size / 2;

    // Simple geometric Islamic star pattern logic
    path.moveTo(center.dx, center.dy - half);
    path.lineTo(center.dx + half, center.dy);
    path.lineTo(center.dx, center.dy + half);
    path.lineTo(center.dx - half, center.dy);
    path.close();

    path.moveTo(center.dx - half * 0.7, center.dy - half * 0.7);
    path.lineTo(center.dx + half * 0.7, center.dy - half * 0.7);
    path.lineTo(center.dx + half * 0.7, center.dy + half * 0.7);
    path.lineTo(center.dx - half * 0.7, center.dy + half * 0.7);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IslamicBackground extends StatelessWidget {
  const IslamicBackground({
    super.key,
    required this.child,
    this.showPattern = false,
  });
  final Widget child;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6),
      ),
      child: Stack(
        children: [
          if (showPattern)
            Positioned.fill(
              child: IslamicGeometricPattern(
                color: isDark ? Colors.white : colorScheme.secondary,
                opacity: isDark ? 0.015 : 0.02,
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class IslamicDivider extends StatelessWidget {
  const IslamicDivider({super.key, this.color, this.width = 100});
  final Color? color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? AppTheme.readableAccent(context);

    return Center(
      child: SizedBox(
        width: width,
        child: Row(
          children: [
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.star_outline, size: 14, color: dividerColor),
            ),
            Expanded(child: Divider(color: dividerColor, thickness: 1)),
          ],
        ),
      ),
    );
  }
}

class IslamicHeaderDecoration extends StatelessWidget {
  const IslamicHeaderDecoration({
    super.key,
    required this.title,
    this.subtitle,
  });
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = AppTheme.readableAccent(context);

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.readableAccent(context),
            letterSpacing: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFC8B8A8) : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 12),
        IslamicDivider(color: primary, width: 160),
        const SizedBox(height: 20),
      ],
    );
  }
}
