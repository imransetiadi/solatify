import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/qibla/presentation/providers/qibla_heading_provider.dart';

import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  double _simulatedHeading = 0.0;
  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final coordinates = Coordinates(location.latitude, location.longitude);

    // Calculate Qibla angle from North using adhan library
    final double qiblaAngle = Qibla(coordinates).direction;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFFAFA19A);
    final textMuted = isDark
        ? const Color(0xFF999999)
        : const Color(0xFFAFA19A);
    final textHint = isDark ? const Color(0xFF666666) : const Color(0xFF9A8A7D);
    final accentColor = AppTheme.readableAccent(context);
    final appBarColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: isDark ? 0.96 : 0.94);
    final headingState = ref.watch(qiblaHeadingProvider);
    final sensorHeading = headingState.valueOrNull?.degrees;
    final hasSensor = sensorHeading != null;
    final heading = sensorHeading ?? _simulatedHeading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
        backgroundColor: appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: IslamicBackground(
        child: Builder(
          builder: (context) {
            // Qibla direction relative to the top of the phone
            // (Bearing to Mecca - Phone's Heading)
            final qiblaRelativeAngle = (qiblaAngle - heading + 360) % 360;

            // Check if user is pointing exactly towards Mecca (tolerance: +/- 3 degrees)
            final isAligned =
                qiblaRelativeAngle <= 2 || qiblaRelativeAngle >= 358;

            if (isAligned && !_wasAligned) {
              HapticFeedback.heavyImpact();
              _wasAligned = true;
            } else if (!isAligned && _wasAligned) {
              _wasAligned = false;
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: ResponsiveLayout.pagePadding(
                context,
              ).copyWith(top: 16, bottom: 96),
              child: ResponsiveCenter(
                child: Column(
                  children: [
                    // Location Status Card
                    GlassContainer(
                      opacity: isDark ? 0.03 : 0.015,
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.my_location,
                                color: accentColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: max(
                                    160,
                                    MediaQuery.sizeOf(context).width - 150,
                                  ).toDouble(),
                                ),
                                child: Text(
                                  '${location.city}, ${location.country}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Kiblat: ${qiblaAngle.toStringAsFixed(1)}°',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Aligned indicator Banner
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isAligned ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isAligned
                              ? accentColor
                              : textHint.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isAligned
                            ? 'KIBLAT TERARAH 🕋'
                            : 'Putar Perangkat Anda',
                        style: TextStyle(
                          color: isAligned ? Colors.white : textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Compass Ring Dial Viewports wrapper
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final size = (constraints.maxWidth * 0.82).clamp(
                          220.0,
                          340.0,
                        );

                        return SizedBox(
                          width: size,
                          height: size,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotate the dial according to the compass heading
                              Transform.rotate(
                                angle: -heading * pi / 180,
                                child: CompassDialPaint(size: size),
                              ),

                              // Rotate the pointing Qibla needle relative to top
                              Transform.rotate(
                                angle: qiblaRelativeAngle * pi / 180,
                                child: QiblaNeedlePaint(size: size),
                              ),

                              // Center decorative hub
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accentColor,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Details description helper text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        hasSensor
                            ? 'Posisikan HP Anda mendatar. Sejajarkan jarum kiblat yang berlambang Kabah di atas agar lurus tegak ke arah depan Anda.'
                            : 'Sensor kompas tidak terdeteksi pada perangkat Anda. Gunakan simulasi di bawah untuk menguji arah kiblat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (!hasSensor) _buildSimulationPanel(heading, qiblaAngle),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSimulationPanel(double currentVal, double qiblaAngle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark
        ? const Color(0xFFC8B8A8)
        : const Color(0xFFAFA19A);
    final accentColor = AppTheme.readableAccent(context);

    return Column(
      children: [
        const Divider(height: 32),
        Text(
          'Simulasi Heading HP (°)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textSecondary,
          ),
        ),
        Slider(
          min: 0,
          max: 360,
          value: currentVal,
          activeColor: accentColor,
          onChanged: (val) {
            setState(() {
              _simulatedHeading = val;
            });
          },
        ),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _simulatedHeading = qiblaAngle; // Instantly align
            });
          },
          child: const Text('Simulasikan Lurus Kiblat'),
        ),
      ],
    );
  }
}

// Custom Painter for the Compass Card (North, South, East, West indices)
class CompassDialPaint extends StatelessWidget {
  const CompassDialPaint({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _CompassDialPainter(isDark: isDark),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint = Paint()
      ..color = isDark ? Colors.white24 : Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw compass degree ticks
    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final isMajor = i % 90 == 0;
      final isMedium = i % 30 == 0 && !isMajor;

      final startOffset = Offset(
        center.dx +
            (radius -
                    (isMajor
                        ? 12
                        : isMedium
                        ? 8
                        : 4)) *
                sin(angle),
        center.dy -
            (radius -
                    (isMajor
                        ? 12
                        : isMedium
                        ? 8
                        : 4)) *
                cos(angle),
      );
      final endOffset = Offset(
        center.dx + radius * sin(angle),
        center.dy - radius * cos(angle),
      );

      canvas.drawLine(startOffset, endOffset, tickPaint);
    }

    // Draw Cardinal Letters (N, E, S, W)
    final cardinals = {
      'U': 0,
      'T': 90,
      'S': 180,
      'B': 270,
    }; // Indonesian labels: Utara, Timur, Selatan, Barat
    cardinals.forEach((label, degree) {
      final angle = degree * pi / 180;

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: label == 'U'
              ? (isDark ? Colors.white : const Color(0xFF241A12))
              : (isDark
                    ? const Color(0xFFC8B8A8)
                    : const Color(0xFFAFA19A)), // Black for North
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();

      final offset = Offset(
        center.dx + (radius - 28) * sin(angle) - textPainter.width / 2,
        center.dy - (radius - 28) * cos(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    });
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// Custom Painter for the pointing Qibla needle (decorated black arrow pointed up)
class QiblaNeedlePaint extends StatelessWidget {
  const QiblaNeedlePaint({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomPaint(
      size: Size.square(size),
      painter: _QiblaNeedlePainter(isDark: isDark),
    );
  }
}

class _QiblaNeedlePainter extends CustomPainter {
  _QiblaNeedlePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final needlePaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF241A12)
      ..style = PaintingStyle.fill;

    // Draw arrow path (pointing straight up on the canvas)
    final path = Path();
    path.moveTo(center.dx, center.dy - radius + 15); // Top Tip
    path.lineTo(center.dx - 12, center.dy - radius + 55); // Bottom Left
    path.lineTo(center.dx - 4, center.dy - radius + 48); // Notch Left
    path.lineTo(center.dx - 4, center.dy); // Shaft bottom left
    path.lineTo(center.dx + 4, center.dy); // Shaft bottom right
    path.lineTo(center.dx + 4, center.dy - radius + 48); // Notch Right
    path.lineTo(center.dx + 12, center.dy - radius + 55); // Bottom Right
    path.close();

    canvas.drawPath(path, needlePaint);

    // Draw a small Kaaba icon or decor at the tip
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = const TextSpan(
      text: '🕋',
      style: TextStyle(fontSize: 20),
    );
    iconPainter.layout();

    // Draw icon just above the needle tip
    final iconOffset = Offset(
      center.dx - iconPainter.width / 2,
      center.dy - radius - 8,
    );
    iconPainter.paint(canvas, iconOffset);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
