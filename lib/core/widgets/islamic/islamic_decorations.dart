import 'package:flutter/material.dart';

class IslamicGeometricPattern extends StatelessWidget {
  final double opacity;
  final Color? color;
  final double strokeWidth;

  const IslamicGeometricPattern({
    super.key,
    this.opacity = 0.05,
    this.color,
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black);
    
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
  final Color color;
  final double strokeWidth;

  _GeometricPainter(this.color, this.strokeWidth);

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

  void _drawPatternUnit(Canvas canvas, Offset center, double size, Paint paint) {
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
  final Widget child;
  final bool showPattern;

  const IslamicBackground({
    super.key,
    required this.child,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF082E1D), // Very dark green
                  const Color(0xFF0E4D31), // Islamic Green
                  const Color(0xFF153B27),
                ]
              : [
                  const Color(0xFFF3FBF6), // Very light green tint
                  const Color(0xFFE8F5E9),
                  const Color(0xFFF1F8E9),
                ],
        ),
      ),
      child: Stack(
        children: [
          if (showPattern)
            Positioned.fill(
              child: IslamicGeometricPattern(
                color: isDark ? Colors.white : primaryColor,
                opacity: isDark ? 0.04 : 0.06,
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class IslamicDivider extends StatelessWidget {
  final Color? color;
  final double width;

  const IslamicDivider({super.key, this.color, this.width = 100});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor = color ?? theme.colorScheme.secondary; // Use the new Islamic Green

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
  final String title;
  final String? subtitle;

  const IslamicHeaderDecoration({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : theme.colorScheme.secondary,
            letterSpacing: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
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
