import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

import '../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../../core/widgets/responsive_layout.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final settings = ref.read(settingsProvider);
    if (settings.onboardingCompleted) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.secondary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF241A12);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF5D4E47);

    return Scaffold(
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: ResponsiveLayout.pagePadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1E150F) : Colors.white,
                        border: Border.all(
                          color: primaryColor.withValues(
                            alpha: isDark ? 0.6 : 0.3,
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
                          color: titleColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pendamping Ibadah Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFC94B3D),
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
    );
  }
}
