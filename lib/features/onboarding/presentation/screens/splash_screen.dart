import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  /// Kept short so the splash only covers app start-up, not the user's time.
  static const Duration _splashHold = Duration(milliseconds: 1400);
  static const Duration _fadeDuration = Duration(milliseconds: 600);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _fadeDuration);
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: SolatifyMotion.curve,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    // Respect the OS "reduce motion" setting: show content immediately.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future<void>.delayed(_splashHold);
    if (!mounted) return;

    final settings = ref.read(settingsProvider);
    if (settings.onboardingCompleted) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tagline = l.isEnglish
        ? 'Your Worship Companion'
        : 'Pendamping Ibadah Anda';
    final loadingLabel = l.isEnglish ? 'Loading' : 'Memuat';

    return Scaffold(
      body: IslamicBackground(
        child: SafeArea(
          child: ResponsiveCenter(
            maxWidth: 480,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Semantics(
                        container: true,
                        label: 'Solatify. $tagline. $loadingLabel…',
                        child: ExcludeSemantics(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: ResponsiveLayout.pagePadding(context),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      SolatifySpacing.xl,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: SolatifyColors.softSurface(
                                        context,
                                      ),
                                      border: Border.all(
                                        color: SolatifyColors.borderStrong(
                                          context,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/images/masjid_nabawi.svg',
                                      width: 76,
                                      height: 76,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'SOLATIFY',
                                      style: TextStyle(
                                        color: SolatifyColors.text(context),
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 4.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: SolatifySpacing.xs),
                                  Text(
                                    tagline,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: SolatifyColors.muted(context),
                                      fontSize: SolatifyType.sectionTitle,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        SolatifyColors.accent(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
