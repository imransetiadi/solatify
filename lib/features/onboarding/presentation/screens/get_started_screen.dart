import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

import '../../../../core/widgets/responsive_layout.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<GetStartedPage> pages = [
    GetStartedPage(
      title: 'Selamat Datang di Solatify',
      description: 'Aplikasi komprehensif untuk ibadah dan pengetahuan Islami',
      icon: Icons.mosque,
      color: const Color(0xFFC94B3D),
    ),
    GetStartedPage(
      title: 'Jadwal Sholat Akurat',
      description:
          'Dapatkan jadwal sholat real-time dengan 6 metode kalkulasi berbeda sesuai lokasi Anda',
      icon: Icons.schedule,
      color: const Color(0xFFC78A4C),
    ),
    GetStartedPage(
      title: 'Al-Qur\'an Digital',
      description:
          'Baca Al-Qur\'an 114 surah dengan terjemahan, bookmark, dan akses offline',
      icon: Icons.menu_book,
      color: const Color(0xFFC94B3D),
    ),
    GetStartedPage(
      title: 'Asmaul Husna & Doa',
      description:
          '99 Nama Allah dan 30+ doa harian untuk setiap waktu dan situasi',
      icon: Icons.favorite,
      color: const Color(0xFFC78A4C),
    ),
    GetStartedPage(
      title: 'Kalender Hijriah',
      description:
          'Pantau event Islam penting dan tanggal-tanggal bersejarah dalam Islam',
      icon: Icons.calendar_month,
      color: const Color(0xFFC94B3D),
    ),
    GetStartedPage(
      title: 'Arah Kiblat & Masjid',
      description:
          'Temukan arah kiblat akurat dengan kompas dan cari masjid terdekat',
      icon: Icons.explore,
      color: const Color(0xFFC78A4C),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF160F0A) : const Color(0xFFFFF7ED);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ResponsiveCenter(
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
                padding: ResponsiveLayout.pagePadding(
                  context,
                ).copyWith(top: 8, bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? pages[index].color
                                : pages[index].color.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _currentPage > 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                  ),
                                  child: const Text(
                                    'Kembali',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                ref
                                    .read(settingsProvider.notifier)
                                    .completeOnboarding();
                                context.go(AppRoutes.home);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: pages[_currentPage].color,
                            ),
                            child: Text(
                              _currentPage == pages.length - 1
                                  ? 'Mulai Sekarang'
                                  : 'Lanjut',
                              style: const TextStyle(color: Colors.white),
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
    );
  }
}

class GetStartedPage {
  GetStartedPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class GetStartedPageView extends StatelessWidget {
  const GetStartedPageView({required this.page, super.key});
  final GetStartedPage page;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFFFF7ED)
        : const Color(0xFF241A12);
    final textMuted = isDark
        ? const Color(0xFFC8B8A8)
        : const Color(0xFF5D4E47);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(page.icon, size: 80, color: page.color),
            const SizedBox(height: 30),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                page.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textMuted, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
