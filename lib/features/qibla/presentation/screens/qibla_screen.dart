import 'dart:async';
import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/qibla/presentation/providers/qibla_heading_provider.dart';

/// Location access as seen by the Qibla screen. Qibla is computed from the
/// saved location, so missing access only degrades accuracy (shown as a hint).
enum _LocationAccess {
  unknown,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

const _tabularFigures = [FontFeature.tabularFigures()];

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with WidgetsBindingObserver {
  /// Enter alignment within this offset, leave it only beyond [_exitTolerance]
  /// (hysteresis) so the status does not flicker around the threshold.
  static const double _enterTolerance = 2.0;
  static const double _exitTolerance = 4.0;
  static const Duration _sensorTimeout = Duration(seconds: 4);
  static const Duration _hapticDebounce = Duration(milliseconds: 1500);
  static const Duration _announceThrottle = Duration(seconds: 2);

  double _simulatedHeading = 0.0;
  bool _isAligned = false;
  bool _sensorTimedOut = false;
  bool _isRequestingAccess = false;
  Timer? _sensorTimer;
  DateTime? _lastHapticAt;
  DateTime? _lastAnnouncedAt;
  String _announcedLabel = '';
  bool _announcedAligned = false;
  double _dialTurns = 0;
  double _needleTurns = 0;
  _LocationAccess _locationAccess = _LocationAccess.unknown;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sensorTimer = Timer(_sensorTimeout, () {
      if (!mounted) return;
      setState(() => _sensorTimedOut = true);
    });
    _checkLocationAccess();
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationAccess();
    }
  }

  Future<void> _checkLocationAccess() async {
    try {
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      final permission = await LocationService.checkPermission();
      if (!mounted) return;
      setState(() {
        _locationAccess = !serviceEnabled
            ? _LocationAccess.serviceDisabled
            : switch (permission) {
                LocationPermission.denied => _LocationAccess.denied,
                LocationPermission.deniedForever =>
                  _LocationAccess.deniedForever,
                LocationPermission.unableToDetermine => _LocationAccess.unknown,
                _ => _LocationAccess.granted,
              };
      });
    } catch (error) {
      // Plugin unavailable (tests/desktop): keep using the saved location.
      debugPrint('Qibla location access check skipped: $error');
    }
  }

  Future<void> _resolveLocationAccess() async {
    if (_isRequestingAccess) return;
    setState(() => _isRequestingAccess = true);
    try {
      switch (_locationAccess) {
        case _LocationAccess.serviceDisabled:
          await Geolocator.openLocationSettings();
        case _LocationAccess.deniedForever:
          await Geolocator.openAppSettings();
        case _LocationAccess.denied:
          final permission = await LocationService.requestPermission();
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            await ref.read(locationProvider.notifier).updateLocationWithGPS();
          }
        case _LocationAccess.unknown:
        case _LocationAccess.granted:
          break;
      }
    } catch (error) {
      debugPrint('Qibla location access action failed: $error');
    } finally {
      if (mounted) setState(() => _isRequestingAccess = false);
      await _checkLocationAccess();
    }
  }

  /// Returns a continuous turn value closest to [current] so implicit
  /// rotation never spins the long way round when crossing 0°/360°.
  double _nextTurns(double current, double targetDegrees) {
    final target = targetDegrees / 360;
    var delta = (target - current) % 1.0;
    if (delta > 0.5) delta -= 1.0;
    return current + delta;
  }

  void _updateAlignment(double offsetAbs) {
    final aligned = _isAligned
        ? offsetAbs <= _exitTolerance
        : offsetAbs <= _enterTolerance;
    if (aligned && !_isAligned) {
      final now = DateTime.now();
      final last = _lastHapticAt;
      if (last == null || now.difference(last) >= _hapticDebounce) {
        _lastHapticAt = now;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => SolatifyHaptics.success(),
        );
      }
    }
    _isAligned = aligned;
  }

  /// Screen-reader text for the compass. Updated at most every
  /// [_announceThrottle] (or immediately when alignment flips) so the live
  /// region does not spam announcements on every sensor tick.
  String _spokenLabel({
    required AppLocalizations l,
    required double heading,
    required double offsetSigned,
  }) {
    final now = DateTime.now();
    final last = _lastAnnouncedAt;
    final alignmentChanged = _announcedAligned != _isAligned;
    final throttled = last != null && now.difference(last) < _announceThrottle;
    if (_announcedLabel.isNotEmpty && !alignmentChanged && throttled) {
      return _announcedLabel;
    }

    final headingText = heading.round() % 360;
    final roundedOffset = (offsetSigned.abs() / 5).round() * 5;
    final String label;
    if (_isAligned) {
      label = l.isEnglish
          ? 'Facing Qibla. Phone heading $headingText degrees.'
          : 'Menghadap Kiblat. Arah HP $headingText derajat.';
    } else {
      final right = offsetSigned >= 0;
      label = l.isEnglish
          ? 'Turn about $roundedOffset degrees ${right ? 'right' : 'left'} '
                'to face Qibla. Phone heading $headingText degrees.'
          : 'Putar sekitar $roundedOffset derajat ke '
                '${right ? 'kanan' : 'kiri'} menuju Kiblat. '
                'Arah HP $headingText derajat.';
    }

    if (label != _announcedLabel || alignmentChanged) {
      _announcedLabel = label;
      _announcedAligned = _isAligned;
      _lastAnnouncedAt = now;
    }
    return _announcedLabel;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final location = ref.watch(locationProvider);
    final coordinates = Coordinates(location.latitude, location.longitude);

    // Calculate Qibla angle from North using adhan library
    final double qiblaAngle = Qibla(coordinates).direction;

    final headingState = ref.watch(qiblaHeadingProvider);
    final sensorHeading = headingState.valueOrNull?.degrees;
    final needsCalibration =
        headingState.valueOrNull?.needsCalibration ?? false;
    final hasSensor = sensorHeading != null;
    final sensorUnavailable =
        !hasSensor &&
        (headingState.hasError || headingState.hasValue || _sensorTimedOut);
    final isCompassLoading = !hasSensor && !sensorUnavailable;
    final heading = sensorHeading ?? _simulatedHeading;

    // Qibla direction relative to the top of the phone
    // (Bearing to Mecca - Phone's Heading)
    final qiblaRelativeAngle = (qiblaAngle - heading + 360) % 360;
    // Signed offset: positive = turn right (clockwise), negative = turn left.
    final offsetSigned = qiblaRelativeAngle <= 180
        ? qiblaRelativeAngle
        : qiblaRelativeAngle - 360;

    if (!isCompassLoading) {
      _updateAlignment(offsetSigned.abs());
      _dialTurns = _nextTurns(_dialTurns, -heading);
      _needleTurns = _nextTurns(_needleTurns, qiblaRelativeAngle);
    }

    final appBarColor = Theme.of(context).colorScheme.surface.withValues(
      alpha: Theme.of(context).brightness == Brightness.dark ? 0.96 : 0.94,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.isEnglish ? 'Qibla Direction' : 'Arah Kiblat'),
        backgroundColor: appBarColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: IslamicBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: ResponsiveLayout.pagePadding(context).copyWith(
            top: SolatifySpacing.lg,
            bottom: SolatifySpacing.bottomNav,
          ),
          child: ResponsiveCenter(
            child: Column(
              children: [
                _LocationCard(
                  city: location.city,
                  country: location.country,
                  qiblaAngle: qiblaAngle,
                  isEnglish: l.isEnglish,
                ),
                if (_locationAccessNeedsAttention) ...[
                  const SizedBox(height: SolatifySpacing.md),
                  _buildLocationAccessState(l, location.city),
                ],
                const SizedBox(height: SolatifySpacing.xl),
                if (isCompassLoading)
                  SolatifyStateView.loading(
                    compact: true,
                    title: l.isEnglish
                        ? 'Preparing compass'
                        : 'Menyiapkan kompas',
                    description: l.isEnglish
                        ? 'Hold your phone flat while the sensor starts.'
                        : 'Pegang HP mendatar sementara sensor dimulai.',
                  )
                else ...[
                  if (!hasSensor) ...[
                    SolatifyStateView(
                      variant: SolatifyStateVariant.empty,
                      compact: true,
                      icon: Icons.explore_off_outlined,
                      title: l.isEnglish
                          ? 'Compass not available'
                          : 'Sensor kompas tidak tersedia',
                      description: l.isEnglish
                          ? 'Qibla is ${qiblaAngle.toStringAsFixed(0)}° from '
                                'North. Use the simulation below to preview it.'
                          : 'Kiblat berada ${qiblaAngle.toStringAsFixed(0)}° '
                                'dari Utara. Gunakan simulasi di bawah untuk '
                                'melihat arahnya.',
                    ),
                    const SizedBox(height: SolatifySpacing.xl),
                  ],
                  if (hasSensor && needsCalibration) ...[
                    SolatifyStateView(
                      variant: SolatifyStateVariant.empty,
                      compact: true,
                      icon: Icons.screen_rotation_alt_outlined,
                      title: l.isEnglish
                          ? 'Compass needs calibration'
                          : 'Kompas perlu dikalibrasi',
                      description: l.isEnglish
                          ? 'Move your phone in a figure-eight a few times, '
                                'away from metal and magnets.'
                          : 'Gerakkan HP membentuk angka 8 beberapa kali, '
                                'jauh dari benda logam dan magnet.',
                    ),
                    const SizedBox(height: SolatifySpacing.xl),
                  ],
                  _AlignmentStatus(
                    isAligned: _isAligned,
                    offsetSigned: offsetSigned,
                    isEnglish: l.isEnglish,
                  ),
                  const SizedBox(height: SolatifySpacing.xxl),
                  Semantics(
                    container: true,
                    liveRegion: true,
                    label: _spokenLabel(
                      l: l,
                      heading: heading,
                      offsetSigned: offsetSigned,
                    ),
                    child: ExcludeSemantics(
                      child: _Compass(
                        dialTurns: _dialTurns,
                        needleTurns: _needleTurns,
                        isAligned: _isAligned,
                        isEnglish: l.isEnglish,
                      ),
                    ),
                  ),
                  const SizedBox(height: SolatifySpacing.xl),
                  _HeadingReadout(
                    heading: heading,
                    qiblaAngle: qiblaAngle,
                    isEnglish: l.isEnglish,
                  ),
                  const SizedBox(height: SolatifySpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SolatifySpacing.sm,
                    ),
                    child: Text(
                      hasSensor
                          ? (l.isEnglish
                                ? 'Hold your phone flat. Turn until the Kaaba '
                                      'needle points straight up, ahead of you.'
                                : 'Posisikan HP Anda mendatar. Putar hingga '
                                      'jarum berlambang Kabah lurus tegak ke '
                                      'arah depan Anda.')
                          : (l.isEnglish
                                ? 'Drag the slider to simulate your phone '
                                      'heading.'
                                : 'Geser slider untuk menyimulasikan arah HP '
                                      'Anda.'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SolatifyColors.muted(context),
                        fontSize: SolatifyType.caption + 1,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: SolatifySpacing.lg),
                  if (hasSensor)
                    _CalibrationHint(isEnglish: l.isEnglish)
                  else
                    _buildSimulationPanel(l, heading, qiblaAngle),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _locationAccessNeedsAttention =>
      _locationAccess == _LocationAccess.denied ||
      _locationAccess == _LocationAccess.deniedForever ||
      _locationAccess == _LocationAccess.serviceDisabled;

  Widget _buildLocationAccessState(AppLocalizations l, String city) {
    final isEnglish = l.isEnglish;
    final (
      String title,
      String action,
      IconData actionIcon,
    ) = switch (_locationAccess) {
      _LocationAccess.serviceDisabled => (
        isEnglish ? 'Location (GPS) is off' : 'GPS perangkat belum aktif',
        isEnglish ? 'Turn on GPS' : 'Aktifkan GPS',
        Icons.location_on_outlined,
      ),
      _LocationAccess.deniedForever => (
        isEnglish ? 'Location permission blocked' : 'Izin lokasi diblokir',
        isEnglish ? 'Open Settings' : 'Buka Pengaturan',
        Icons.settings_outlined,
      ),
      _ => (
        isEnglish ? 'Location permission needed' : 'Izin lokasi belum aktif',
        isEnglish ? 'Allow location' : 'Izinkan Lokasi',
        Icons.my_location_rounded,
      ),
    };

    return SolatifyStateView.permission(
      compact: true,
      icon: Icons.location_off_outlined,
      title: title,
      description: isEnglish
          ? 'Qibla is calculated from your saved location ($city). '
                'Enable location for a more accurate direction.'
          : 'Kiblat dihitung dari lokasi tersimpan ($city). Aktifkan lokasi '
                'agar arah lebih akurat.',
      actionLabel: action,
      actionIcon: actionIcon,
      onAction: _isRequestingAccess ? null : _resolveLocationAccess,
    );
  }

  Widget _buildSimulationPanel(
    AppLocalizations l,
    double currentVal,
    double qiblaAngle,
  ) {
    final accentColor = SolatifyColors.accent(context);
    final sliderValue = currentVal.clamp(0.0, 360.0);

    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      padding: SolatifySpacing.compactCard,
      child: Column(
        children: [
          Text(
            l.isEnglish ? 'Simulated phone heading' : 'Simulasi Heading HP (°)',
            style: TextStyle(
              fontSize: SolatifyType.caption,
              fontWeight: FontWeight.bold,
              color: SolatifyColors.muted(context),
            ),
          ),
          Slider(
            min: 0,
            max: 360,
            value: sliderValue,
            activeColor: accentColor,
            label: '${sliderValue.round()}°',
            semanticFormatterCallback: (value) =>
                '${value.round()} ${l.isEnglish ? 'degrees' : 'derajat'}',
            onChanged: (val) {
              setState(() {
                _simulatedHeading = val;
              });
            },
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, SolatifyTapTarget.min),
            ),
            onPressed: () {
              setState(() {
                _simulatedHeading = qiblaAngle; // Instantly align
              });
            },
            icon: const Icon(
              Icons.center_focus_strong_outlined,
              size: SolatifyIconSize.inline,
            ),
            label: Text(
              l.isEnglish
                  ? 'Simulate facing Qibla'
                  : 'Simulasikan Lurus Kiblat',
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.city,
    required this.country,
    required this.qiblaAngle,
    required this.isEnglish,
  });

  final String city;
  final String country;
  final double qiblaAngle;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.readableAccent(context);
    final bearing = '${qiblaAngle.toStringAsFixed(1)}°';

    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      padding: SolatifySpacing.compactCard,
      semanticLabel: isEnglish
          ? 'Location $city, $country. Qibla $bearing from North.'
          : 'Lokasi $city, $country. Kiblat $bearing dari Utara.',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Container(
              width: SolatifyIconSize.cardBox,
              height: SolatifyIconSize.cardBox,
              decoration: BoxDecoration(
                color: SolatifyColors.accentSoft(context),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Icon(
                Icons.my_location,
                color: accent,
                size: SolatifyIconSize.cardIcon,
              ),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$city, $country',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SolatifyType.cardTitle,
                      color: SolatifyColors.text(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEnglish
                        ? 'Qibla: $bearing from North'
                        : 'Kiblat: $bearing dari Utara',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: SolatifyColors.muted(context),
                      fontWeight: FontWeight.w600,
                      fontSize: SolatifyType.caption,
                      fontFeatures: _tabularFigures,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlignmentStatus extends StatelessWidget {
  const _AlignmentStatus({
    required this.isAligned,
    required this.offsetSigned,
    required this.isEnglish,
  });

  final bool isAligned;
  final double offsetSigned;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final success = SolatifyColors.success(context);
    final textColor = SolatifyColors.text(context);
    final offset = offsetSigned.abs().round();
    final turnRight = offsetSigned >= 0;

    final label = isAligned
        ? (isEnglish ? 'Facing Qibla ✓' : 'Menghadap Kiblat ✓')
        : isEnglish
        ? 'Turn $offset° ${turnRight ? 'right' : 'left'}'
        : 'Putar $offset° ke ${turnRight ? 'kanan' : 'kiri'}';
    final icon = isAligned
        ? Icons.check_circle_rounded
        : turnRight
        ? Icons.rotate_right_rounded
        : Icons.rotate_left_rounded;
    final foreground = isAligned ? success : textColor;

    return ExcludeSemantics(
      child: AnimatedContainer(
        duration: SolatifyMotion.of(context, SolatifyMotion.medium),
        curve: SolatifyMotion.curve,
        constraints: const BoxConstraints(minHeight: SolatifyTapTarget.min),
        padding: const EdgeInsets.symmetric(
          vertical: SolatifySpacing.sm,
          horizontal: SolatifySpacing.xl,
        ),
        decoration: BoxDecoration(
          color: isAligned
              ? success.withValues(alpha: 0.14)
              : SolatifyColors.softSurface(context).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(SolatifyRadius.lg),
          border: Border.all(
            color: isAligned ? success : SolatifyColors.border(context),
            width: isAligned ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: SolatifyIconSize.cardIcon),
            const SizedBox(width: SolatifySpacing.xs),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.w800,
                  fontSize: SolatifyType.sectionTitle,
                  fontFeatures: _tabularFigures,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Compass extends StatelessWidget {
  const _Compass({
    required this.dialTurns,
    required this.needleTurns,
    required this.isAligned,
    required this.isEnglish,
  });

  final double dialTurns;
  final double needleTurns;
  final bool isAligned;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final rotationDuration = SolatifyMotion.of(context, SolatifyMotion.fast);
    final success = SolatifyColors.success(context);
    final ringColor = isAligned
        ? success
        : SolatifyColors.borderStrong(context);
    final hubColor = isAligned ? success : SolatifyColors.accent(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = (constraints.maxWidth * 0.82).clamp(200.0, 340.0);

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dial face so ticks/labels stay readable on any background.
              AnimatedContainer(
                duration: SolatifyMotion.of(context, SolatifyMotion.medium),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SolatifyColors.softSurface(
                    context,
                  ).withValues(alpha: 0.92),
                  border: Border.all(
                    color: ringColor,
                    width: isAligned ? 3 : 1.5,
                  ),
                ),
              ),
              // Rotate the dial according to the compass heading
              AnimatedRotation(
                turns: dialTurns,
                duration: rotationDuration,
                curve: Curves.easeOut,
                child: CompassDialPaint(size: size, isEnglish: isEnglish),
              ),
              // Rotate the pointing Qibla needle relative to top
              AnimatedRotation(
                turns: needleTurns,
                duration: rotationDuration,
                curve: Curves.easeOut,
                child: QiblaNeedlePaint(size: size, isAligned: isAligned),
              ),
              // Center hub
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hubColor,
                  border: Border.all(
                    color: SolatifyColors.softSurface(context),
                    width: 2.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeadingReadout extends StatelessWidget {
  const _HeadingReadout({
    required this.heading,
    required this.qiblaAngle,
    required this.isEnglish,
  });

  final double heading;
  final double qiblaAngle;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final headingValue = ((heading % 360) + 360) % 360;
    return ExcludeSemantics(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: SolatifySpacing.sm,
        runSpacing: SolatifySpacing.sm,
        children: [
          _ReadoutTile(
            label: isEnglish ? 'Phone' : 'Arah HP',
            value: '${headingValue.round()}°',
          ),
          _ReadoutTile(
            label: isEnglish ? 'Qibla' : 'Kiblat',
            value: '${qiblaAngle.round()}°',
          ),
        ],
      ),
    );
  }
}

class _ReadoutTile extends StatelessWidget {
  const _ReadoutTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(
        horizontal: SolatifySpacing.md,
        vertical: SolatifySpacing.xs,
      ),
      decoration: BoxDecoration(
        color: SolatifyColors.raisedSurface(context),
        borderRadius: SolatifyRadius.icon,
        border: Border.all(color: SolatifyColors.border(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: SolatifyColors.muted(context),
              fontSize: SolatifyType.eyebrow,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: SolatifyColors.text(context),
              fontSize: SolatifyType.heroTitle,
              fontWeight: FontWeight.w800,
              fontFeatures: _tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationHint extends StatelessWidget {
  const _CalibrationHint({required this.isEnglish});

  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final warning = SolatifyColors.warning(context);
    return GlassContainer(
      borderRadius: SolatifyRadius.md,
      padding: SolatifySpacing.compactCard,
      child: Semantics(
        container: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: SolatifyIconSize.cardBox,
              height: SolatifyIconSize.cardBox,
              decoration: BoxDecoration(
                color: warning.withValues(alpha: 0.14),
                borderRadius: SolatifyRadius.icon,
              ),
              child: Icon(
                Icons.all_inclusive_rounded,
                color: warning,
                size: SolatifyIconSize.cardIcon,
              ),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish
                        ? 'Direction unstable? Calibrate'
                        : 'Arah tidak stabil? Kalibrasi',
                    style: TextStyle(
                      color: SolatifyColors.text(context),
                      fontWeight: FontWeight.w800,
                      fontSize: SolatifyType.body,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEnglish
                        ? 'Move your phone in a figure-8 a few times and keep '
                              'it away from magnets, metal and electronics.'
                        : 'Gerakkan HP membentuk angka 8 beberapa kali dan '
                              'jauhkan dari magnet, logam, serta perangkat '
                              'elektronik.',
                    style: TextStyle(
                      color: SolatifyColors.muted(context),
                      fontSize: SolatifyType.caption,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for the Compass Card (North, South, East, West indices)
class CompassDialPaint extends StatelessWidget {
  const CompassDialPaint({
    super.key,
    required this.size,
    this.isEnglish = false,
  });

  final double size;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CompassDialPainter(
        tickColor: SolatifyColors.muted(context).withValues(alpha: 0.55),
        majorTickColor: SolatifyColors.text(context),
        northColor: SolatifyColors.accent(context),
        labelColor: SolatifyColors.muted(context),
        // Indonesian labels: Utara, Timur, Selatan, Barat
        labels: isEnglish
            ? const ['N', 'E', 'S', 'W']
            : const ['U', 'T', 'S', 'B'],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({
    required this.tickColor,
    required this.majorTickColor,
    required this.northColor,
    required this.labelColor,
    required this.labels,
  });

  final Color tickColor;
  final Color majorTickColor;
  final Color northColor;
  final Color labelColor;
  final List<String> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final tickPaint = Paint()
      ..color = tickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final majorTickPaint = Paint()
      ..color = majorTickColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw compass degree ticks
    for (int i = 0; i < 360; i += 10) {
      final angle = i * pi / 180;
      final isMajor = i % 90 == 0;
      final isMedium = i % 30 == 0 && !isMajor;
      final length = isMajor
          ? 12
          : isMedium
          ? 8
          : 4;

      final startOffset = Offset(
        center.dx + (radius - length) * sin(angle),
        center.dy - (radius - length) * cos(angle),
      );
      final endOffset = Offset(
        center.dx + radius * sin(angle),
        center.dy - radius * cos(angle),
      );

      canvas.drawLine(
        startOffset,
        endOffset,
        isMajor ? majorTickPaint : tickPaint,
      );
    }

    // Draw cardinal letters (N/U, E/T, S, W/B)
    for (var index = 0; index < 4; index++) {
      final angle = index * 90 * pi / 180;
      final isNorth = index == 0;

      textPainter.text = TextSpan(
        text: labels[index],
        style: TextStyle(
          color: isNorth ? northColor : labelColor,
          fontSize: isNorth ? 18 : 16,
          fontWeight: isNorth ? FontWeight.w900 : FontWeight.bold,
        ),
      );
      textPainter.layout();

      final offset = Offset(
        center.dx + (radius - 28) * sin(angle) - textPainter.width / 2,
        center.dy - (radius - 28) * cos(angle) - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.tickColor != tickColor ||
      oldDelegate.majorTickColor != majorTickColor ||
      oldDelegate.northColor != northColor ||
      oldDelegate.labelColor != labelColor ||
      oldDelegate.labels != labels;
}

// Custom Painter for the pointing Qibla needle (arrow pointed up)
class QiblaNeedlePaint extends StatelessWidget {
  const QiblaNeedlePaint({
    super.key,
    required this.size,
    this.isAligned = false,
  });

  final double size;
  final bool isAligned;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _QiblaNeedlePainter(
        color: isAligned
            ? SolatifyColors.success(context)
            : SolatifyColors.text(context),
      ),
    );
  }
}

class _QiblaNeedlePainter extends CustomPainter {
  _QiblaNeedlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final needlePaint = Paint()
      ..color = color
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

    // Draw a small Kaaba icon at the tip
    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = const TextSpan(
      text: '🕋',
      style: TextStyle(fontSize: 20),
    );
    iconPainter.layout();

    final iconOffset = Offset(
      center.dx - iconPainter.width / 2,
      center.dy - radius - 8,
    );
    iconPainter.paint(canvas, iconOffset);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.color != color;
}
