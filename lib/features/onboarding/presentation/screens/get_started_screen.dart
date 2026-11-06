import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  List<GetStartedPage> _pages(bool isEnglish) => [
    GetStartedPage(
      title: isEnglish ? 'Welcome to Solatify' : 'Selamat Datang di Solatify',
      description: isEnglish
          ? 'A complete companion for worship and Islamic knowledge'
          : 'Aplikasi komprehensif untuk ibadah dan pengetahuan Islami',
      icon: Icons.mosque,
    ),
    GetStartedPage(
      title: isEnglish ? 'Accurate Prayer Times' : 'Jadwal Sholat Akurat',
      description: isEnglish
          ? 'Real-time prayer times with 6 calculation methods for your location'
          : 'Dapatkan jadwal sholat real-time dengan 6 metode kalkulasi berbeda sesuai lokasi Anda',
      icon: Icons.schedule,
    ),
    GetStartedPage(
      title: isEnglish ? 'Digital Qur\'an' : 'Al-Qur\'an Digital',
      description: isEnglish
          ? 'Read all 114 surahs with translation, bookmarks, and offline access'
          : 'Baca Al-Qur\'an 114 surah dengan terjemahan, bookmark, dan akses offline',
      icon: Icons.menu_book,
    ),
    GetStartedPage(
      title: isEnglish ? 'Asmaul Husna & Duas' : 'Asmaul Husna & Doa',
      description: isEnglish
          ? 'The 99 Names of Allah and 30+ daily duas for every moment'
          : '99 Nama Allah dan 30+ doa harian untuk setiap waktu dan situasi',
      icon: Icons.favorite,
    ),
    GetStartedPage(
      title: isEnglish ? 'Hijri Calendar' : 'Kalender Hijriah',
      description: isEnglish
          ? 'Follow important Islamic events and historic dates'
          : 'Pantau event Islam penting dan tanggal-tanggal bersejarah dalam Islam',
      icon: Icons.calendar_month,
    ),
    GetStartedPage(
      title: isEnglish ? 'Qibla & Mosques' : 'Arah Kiblat & Masjid',
      description: isEnglish
          ? 'Find the qibla with a compass and discover nearby mosques'
          : 'Temukan arah kiblat akurat dengan kompas dan cari masjid terdekat',
      icon: Icons.explore,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (!_pageController.hasClients) return;
    final duration = SolatifyMotion.of(context, SolatifyMotion.slow);
    if (duration == Duration.zero) {
      _pageController.jumpToPage(page);
    } else {
      _pageController.animateToPage(
        page,
        duration: duration,
        curve: SolatifyMotion.curve,
      );
    }
  }

  void _complete() {
    ref.read(settingsProvider.notifier).completeOnboarding();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = _pages(l.isEnglish);
    final isLast = _currentPage == pages.length - 1;
    final padding = ResponsiveLayout.pagePadding(context);

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentPage > 0) _goToPage(_currentPage - 1);
      },
      child: Scaffold(
        body: IslamicBackground(
          child: SafeArea(
            child: ResponsiveCenter(
              maxWidth: 600,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return GetStartedPageView(page: pages[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      padding.left,
                      SolatifySpacing.xs,
                      padding.right,
                      SolatifySpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OnboardingStepIndicator(
                          currentStep: _currentPage,
                          stepCount: pages.length,
                        ),
                        const SizedBox(height: SolatifySpacing.md),
                        Row(
                          children: [
                            if (_currentPage > 0)
                              TextButton.icon(
                                onPressed: () => _goToPage(_currentPage - 1),
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: Text(l.back),
                              )
                            else if (!isLast)
                              TextButton(
                                onPressed: _complete,
                                child: Text(l.isEnglish ? 'Skip' : 'Lewati'),
                              ),
                            const SizedBox(width: SolatifySpacing.sm),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  if (!isLast) {
                                    _goToPage(_currentPage + 1);
                                  } else {
                                    _complete();
                                  }
                                },
                                child: Text(
                                  isLast
                                      ? (l.isEnglish
                                            ? 'Start Now'
                                            : 'Mulai Sekarang')
                                      : (l.isEnglish ? 'Next' : 'Lanjut'),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GetStartedPage {
  GetStartedPage({
    required this.title,
    required this.description,
    required this.icon,
  });
  final String title;
  final String description;
  final IconData icon;
}

class GetStartedPageView extends StatelessWidget {
  const GetStartedPageView({required this.page, super.key});
  final GetStartedPage page;

  @override
  Widget build(BuildContext context) {
    final isShort = MediaQuery.sizeOf(context).height < 700;
    final iconBox = isShort ? 72.0 : 96.0;

    return OnboardingSlideFrame(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveLayout.pagePadding(context).left,
        vertical: SolatifySpacing.lg,
      ),
      child: GlassContainer(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: SolatifySpacing.xl,
          vertical: SolatifySpacing.xxl,
        ),
        borderRadius: SolatifyRadius.xl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Container(
                width: iconBox,
                height: iconBox,
                decoration: BoxDecoration(
                  color: SolatifyColors.accentSoft(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: iconBox * 0.5,
                  color: SolatifyColors.accent(context),
                ),
              ),
            ),
            SizedBox(
              height: isShort ? SolatifySpacing.lg : SolatifySpacing.xxl,
            ),
            Semantics(
              header: true,
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                  color: SolatifyColors.text(context),
                ),
              ),
            ),
            const SizedBox(height: SolatifySpacing.md),
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: SolatifyColors.muted(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
