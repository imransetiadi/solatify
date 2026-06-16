import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';

import '../../../prayer_schedule/presentation/location_provider.dart';

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
        : const Color(0xFF5D4E47);
    final textMuted = isDark
        ? const Color(0xFF999999)
        : const Color(0xFF5D4E47);
    final textHint = isDark ? const Color(0xFF666666) : const Color(0xFF9A8A7D);

    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: SafeArea(
        child: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            // Check if compass is available or we need simulation
            final hasSensor =
                snapshot.hasData && snapshot.data?.heading != null;
            final heading = hasSensor
                ? snapshot.data!.heading!
                : _simulatedHeading;

            // Qibla direction relative to the top of the phone
            // (Bearing to Mecca - Phone's Heading)
            final qiblaRelativeAngle = (qiblaAngle - heading + 360) % 360;

            // Check if user is pointing exactly towards Mecca (tolerance: +/- 3 degrees)
            final isAligned = qiblaRelativeAngle <= 2 || qiblaRelativeAngle >= 358;

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
              ).copyWith(bottom: 96),
              child: ResponsiveCenter(
                child: Column(
                  children: [
                    // Location Status Card
                    GlassContainer(
                      blur: 15,
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
                              const Icon(
                                Icons.my_location,
                                color: Color(0xFF0E4D31),
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
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isAligned
                            ? const Color(0xFF0E4D31).withValues(alpha: 0.15)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.black.withValues(alpha: 0.02)),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAligned
                              ? const Color(0xFF0E4D31).withValues(alpha: 0.5)
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08)),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAligned ? Icons.verified : Icons.explore,
                            color: isAligned
                                ? const Color(0xFF0E4D31)
                                : textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isAligned
                                  ? 'Terarah ke Kakbah'
                                  : 'Putar Perangkat Anda: ${(qiblaRelativeAngle.round())}°',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isAligned
                                    ? const Color(0xFF0E4D31)
                                    : textMuted,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Animated Compass Art
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compassSize = constraints.maxWidth
                            .clamp(220.0, 300.0)
                            .toDouble();
                        final paintSize = compassSize - 40;

                        return SizedBox(
                          height: compassSize,
                          width: compassSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Compass Outer Ring Decor
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isAligned
                                        ? const Color(
                                            0xFF0E4D31,
                                          ).withValues(alpha: 0.4)
                                        : (isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.08,
                                                )),
                                    width: 3.0,
                                  ),
                                  boxShadow: isAligned
                                      ? [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF0E4D31,
                                            ).withValues(alpha: 0.15),
                                            blurRadius: 32,
                                            spreadRadius: 4,
                                          ),
                                        ]
                                      : [],
                                ),
                              ),

                              // Compass Dial (Rotates in negative heading to align North correctly)
                              Transform.rotate(
                                angle: -heading * pi / 180,
                                child: CompassDialPaint(size: paintSize),
                              ),

                              // Black Qibla Needle (points towards Mecca)
                              Transform.rotate(
                                angle: qiblaRelativeAngle * pi / 180,
                                child: QiblaNeedlePaint(size: paintSize),
                              ),

                              // Center Hub
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF241A12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Calibration Tip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Tips: Pegang ponsel Anda mendatar (horizontal) dan hindari meletakkannya dekat dengan bahan magnetik untuk hasil terbaik.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textHint,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Simulation panel is only shown when compass sensor is unavailable.
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

  Widget _buildSimulationPanel(double currentHeading, double qiblaAngle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark
        ? const Color(0xFFB8A898)
        : const Color(0xFF5D4E47);
    final textMuted = isDark
        ? const Color(0xFF999999)
        : const Color(0xFF5D4E47);
    final sliderInactive = isDark ? Colors.white12 : Colors.black12;

    return GlassContainer(
      blur: 10,
      opacity: isDark ? 0.02 : 0.01,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Simulator Sensor Kompas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textMuted,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFC78A4C).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFC78A4C).withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  'Simulator Active',
                  style: TextStyle(color: Color(0xFFC78A4C), fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Gunakan slider di bawah untuk mensimulasikan putaran ponsel Anda untuk mencari kiblat.',
            style: TextStyle(color: textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Heading Ponsel: ${currentHeading.round()}°',
                style: TextStyle(color: textColor, fontSize: 13),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _simulatedHeading = qiblaAngle; // Instantly align
                  });
                },
                child: const Text(
                  'Luruskan Kiblat',
                  style: TextStyle(color: Color(0xFF0E4D31), fontSize: 12),
                ),
              ),
            ],
          ),
          Slider(
            min: 0,
            max: 360,
            value: _simulatedHeading,
            activeColor: const Color(0xFF0E4D31),
            inactiveColor: sliderInactive,
            onChanged: (val) {
              setState(() {
                _simulatedHeading = val;
              });
            },
          ),
        ],
      ),
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
                    : const Color(0xFF5D4E47)), // Black for North
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
