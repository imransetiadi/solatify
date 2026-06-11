import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/get_started_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/prayer_schedule/presentation/screens/prayer_schedule_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/tracker/presentation/screens/tracker_screen.dart';
import '../../features/mosque/presentation/screens/nearby_mosque_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/quran/presentation/screens/quran_home_screen.dart';
import '../../features/quran/presentation/screens/surah_detail_screen.dart';
import '../../features/islamic_content/presentation/screens/islamic_content_screen.dart';
import '../../features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart';
import '../../features/duas/presentation/screens/duas_screen.dart';
import '../../features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart';
import '../../features/islamic_tips/presentation/screens/islamic_tips_screen.dart';
import '../../features/dhikr/presentation/screens/dhikr_screen.dart';
import '../widgets/responsive_layout.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final goRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/get-started', builder: (context, state) => const GetStartedScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Full screen route for reading a Surah
    GoRoute(
      path: '/quran/surah/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '1';
        final surahId = int.tryParse(idStr) ?? 1;

        final scrollToStr = state.uri.queryParameters['scroll_to'];
        final scrollTo = scrollToStr != null ? int.tryParse(scrollToStr) : null;

        return SurahDetailScreen(
          surahId: surahId,
          initialScrollVerse: scrollTo,
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayoutScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/schedule',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PrayerScheduleScreen()),
        ),
        GoRoute(
          path: '/quran',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: QuranHomeScreen()),
        ),
        GoRoute(
          path: '/islamic-content',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: IslamicContentScreen()),
        ),
        GoRoute(
          path: '/islamic-content/asmaul-husna',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AsmaulHusnaScreen()),
        ),
        GoRoute(
          path: '/islamic-content/duas',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DuasScreen()),
        ),
        GoRoute(
          path: '/islamic-content/hijri-calendar',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HijriCalendarScreen()),
        ),
        GoRoute(
          path: '/islamic-content/tips',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: IslamicTipsScreen()),
        ),
        GoRoute(
          path: '/islamic-content/dhikr',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DhikrScreen()),
        ),
        GoRoute(
          path: '/qibla',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: QiblaScreen()),
        ),
        GoRoute(
          path: '/tracker',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TrackerScreen()),
        ),
        GoRoute(
          path: '/mosque',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: NearbyMosqueScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);

class MainLayoutScreen extends StatelessWidget {
  final Widget child;

  const MainLayoutScreen({super.key, required this.child});

  static const _destinations = [
    _MainDestination(Icons.home_outlined, Icons.home, 'Beranda', '/home'),
    _MainDestination(
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      'Jadwal',
      '/schedule',
    ),
    _MainDestination(
      Icons.menu_book_outlined,
      Icons.menu_book,
      'Qur\'an',
      '/quran',
    ),
    _MainDestination(
      Icons.auto_stories_outlined,
      Icons.auto_stories,
      'Konten',
      '/islamic-content',
    ),
    _MainDestination(Icons.explore_outlined, Icons.explore, 'Kiblat', '/qibla'),
    _MainDestination(
      Icons.fact_check_outlined,
      Icons.fact_check,
      'Jurnal',
      '/tracker',
    ),
    _MainDestination(Icons.map_outlined, Icons.map, 'Masjid', '/mosque'),
    _MainDestination(
      Icons.settings_outlined,
      Icons.settings,
      'Pengaturan',
      '/settings',
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/schedule')) return 1;
    if (location.startsWith('/quran')) return 2;
    if (location.startsWith('/islamic-content')) return 3;
    if (location.startsWith('/qibla')) return 4;
    if (location.startsWith('/tracker')) return 5;
    if (location.startsWith('/mosque')) return 6;
    if (location.startsWith('/settings')) return 7;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    GoRouter.of(context).go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);
    final useNavigationRail = ResponsiveLayout.isMediumOrLarger(context);
    final isDesktopWidth =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;

    if (useNavigationRail) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) => _onItemTapped(index, context),
                extended: isDesktopWidth,
                labelType: isDesktopWidth
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                minWidth: 88,
                minExtendedWidth: 184,
                groupAlignment: -0.82,
                destinations: _destinations.map((destination) {
                  return NavigationRailDestination(
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(destination.activeIcon),
                    label: Text(destination.label),
                  );
                }).toList(),
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: theme.dividerColor.withValues(alpha: 0.35),
              ),
              Expanded(child: child),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          backgroundColor: theme.colorScheme.surface,
          indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.14),
          destinations: _destinations.map((destination) {
            return NavigationDestination(
              icon: Icon(destination.icon, color: isDark ? Colors.white60 : Colors.black45),
              selectedIcon: Icon(destination.activeIcon, color: theme.colorScheme.secondary),
              label: destination.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MainDestination {
  const _MainDestination(this.icon, this.activeIcon, this.label, this.path);

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}
