import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/performance/performance_tuning.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/asmaul_husna/presentation/screens/asmaul_husna_screen.dart';
import 'package:solatify/features/dhikr/presentation/screens/dhikr_screen.dart';
import 'package:solatify/features/duas/presentation/screens/duas_screen.dart';
import 'package:solatify/features/hijri_calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:solatify/features/home/presentation/screens/home_screen.dart';
import 'package:solatify/features/islamic_content/presentation/screens/islamic_content_screen.dart';
import 'package:solatify/features/islamic_tips/presentation/screens/islamic_tips_screen.dart';
import 'package:solatify/features/mosque/presentation/screens/nearby_mosque_screen.dart';
import 'package:solatify/features/onboarding/presentation/screens/get_started_screen.dart';
import 'package:solatify/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:solatify/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:solatify/features/prayer_guide/presentation/screens/prayer_guide_screen.dart';
import 'package:solatify/features/prayer_schedule/presentation/screens/prayer_schedule_screen.dart';
import 'package:solatify/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:solatify/features/quran/presentation/screens/quran_home_screen.dart';
import 'package:solatify/features/quran/presentation/screens/surah_detail_screen.dart';
import 'package:solatify/features/quran/presentation/widgets/quran_mini_player.dart';
import 'package:solatify/features/settings/presentation/screens/notification_health_screen.dart';
import 'package:solatify/features/settings/presentation/screens/settings_screen.dart';
import 'package:solatify/features/tracker/presentation/screens/tracker_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

CustomTransitionPage<void> _buildSeamlessPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: PerformanceTuning.routeTransitionDuration,
    reverseTransitionDuration: PerformanceTuning.routeReverseTransitionDuration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(0, PerformanceTuning.routeTransitionYOffset),
        end: Offset.zero,
      ).animate(curvedAnimation);
      final scaleAnimation = Tween<double>(
        begin: PerformanceTuning.routeTransitionScaleBegin,
        end: 1,
      ).animate(curvedAnimation);

      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: offsetAnimation,
          child: ScaleTransition(scale: scaleAnimation, child: child),
        ),
      );
    },
  );
}

final goRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.getStarted,
      builder: (context, state) => const GetStartedScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.quran}/surah/:id',
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (context, state) {
        final idStr = state.pathParameters['id'] ?? '1';
        final surahId = int.tryParse(idStr) ?? 1;

        final scrollToStr = state.uri.queryParameters['scroll_to'];
        final scrollTo = scrollToStr != null ? int.tryParse(scrollToStr) : null;

        return _buildSeamlessPage(
          state,
          SurahDetailScreen(surahId: surahId, initialScrollVerse: scrollTo),
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
          path: AppRoutes.home,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.schedule,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const PrayerScheduleScreen()),
        ),
        GoRoute(
          path: AppRoutes.quran,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const QuranHomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.islamicContent,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const IslamicContentScreen()),
        ),
        GoRoute(
          path: AppRoutes.asmaulHusna,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const AsmaulHusnaScreen()),
        ),
        GoRoute(
          path: AppRoutes.duas,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const DuasScreen()),
        ),
        GoRoute(
          path: AppRoutes.hijriCalendar,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const HijriCalendarScreen()),
        ),
        GoRoute(
          path: AppRoutes.islamicTips,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const IslamicTipsScreen()),
        ),
        GoRoute(
          path: AppRoutes.dhikr,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const DhikrScreen()),
        ),
        GoRoute(
          path: AppRoutes.prayerGuide,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const PrayerGuideScreen()),
        ),
        GoRoute(
          path: AppRoutes.qibla,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const QiblaScreen()),
        ),
        GoRoute(
          path: AppRoutes.mosque,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const NearbyMosqueScreen()),
        ),
        GoRoute(
          path: AppRoutes.tracker,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const TrackerScreen()),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const SettingsScreen()),
        ),
        GoRoute(
          path: AppRoutes.notificationHealth,
          pageBuilder: (context, state) =>
              _buildSeamlessPage(state, const NotificationHealthScreen()),
        ),
      ],
    ),
  ],
);

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key, required this.child});
  final Widget child;

  static const _destinations = [
    _MainDestination(
      Icons.home_outlined,
      Icons.home,
      'Beranda',
      AppRoutes.home,
    ),
    _MainDestination(
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      'Jadwal',
      AppRoutes.schedule,
    ),
    _MainDestination(
      Icons.menu_book_outlined,
      Icons.menu_book,
      'Qur\'an',
      AppRoutes.quran,
    ),
    _MainDestination(
      Icons.auto_stories_outlined,
      Icons.auto_stories,
      'Konten',
      AppRoutes.islamicContent,
    ),
    _MainDestination(
      Icons.explore_outlined,
      Icons.explore,
      'Kiblat',
      AppRoutes.qibla,
    ),
    _MainDestination(Icons.map_outlined, Icons.map, 'Masjid', AppRoutes.mosque),
    _MainDestination(
      Icons.check_circle_outline,
      Icons.check_circle,
      'Tracker Ibadah',
      AppRoutes.tracker,
    ),
    _MainDestination(
      Icons.settings_outlined,
      Icons.settings,
      'Pengaturan',
      AppRoutes.settings,
    ),
  ];

  static const _mobileDestinations = [
    _MainDestination(
      Icons.home_outlined,
      Icons.home,
      'Beranda',
      AppRoutes.home,
    ),
    _MainDestination(
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      'Jadwal',
      AppRoutes.schedule,
    ),
    _MainDestination(
      Icons.menu_book_outlined,
      Icons.menu_book,
      'Qur\'an',
      AppRoutes.quran,
    ),
    _MainDestination(
      Icons.auto_stories_outlined,
      Icons.auto_stories,
      'Konten',
      AppRoutes.islamicContent,
    ),
    _MainDestination(
      Icons.apps_outlined,
      Icons.apps,
      'Lainnya',
      AppRoutes.more,
    ),
  ];

  static const _moreDestinations = [
    _MainDestination(
      Icons.explore_outlined,
      Icons.explore,
      'Kiblat',
      AppRoutes.qibla,
    ),
    _MainDestination(Icons.map_outlined, Icons.map, 'Masjid', AppRoutes.mosque),
    _MainDestination(
      Icons.check_circle_outline,
      Icons.check_circle,
      'Tracker Ibadah',
      AppRoutes.tracker,
    ),
    _MainDestination(
      Icons.settings_outlined,
      Icons.settings,
      'Pengaturan',
      AppRoutes.settings,
    ),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.schedule)) return 1;
    if (location.startsWith(AppRoutes.quran)) return 2;
    if (location.startsWith(AppRoutes.islamicContent)) return 3;
    if (location.startsWith(AppRoutes.qibla)) return 4;
    if (location.startsWith(AppRoutes.mosque)) return 5;
    if (location.startsWith(AppRoutes.tracker)) return 6;
    if (location.startsWith(AppRoutes.settings)) return 7;
    return 0;
  }

  int _calculateMobileSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.schedule)) return 1;
    if (location.startsWith(AppRoutes.quran)) return 2;
    if (location.startsWith(AppRoutes.islamicContent)) return 3;
    return 4;
  }

  /// Where the system back gesture should lead from [location], or `null`
  /// when back should leave the app (we are already on Home).
  static String? _backTargetFor(String location) {
    if (location.startsWith(AppRoutes.home)) return null;
    if (location.startsWith('${AppRoutes.islamicContent}/')) {
      return AppRoutes.islamicContent;
    }
    if (location.startsWith(AppRoutes.notificationHealth)) {
      return AppRoutes.settings;
    }
    return AppRoutes.home;
  }

  Widget _withBackHandling(BuildContext context, Widget child) {
    final location = GoRouterState.of(context).uri.path;
    final backTarget = _backTargetFor(location);
    return PopScope(
      canPop: backTarget == null,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || backTarget == null) return;
        GoRouter.of(context).go(backTarget);
      },
      child: child,
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    SolatifyHaptics.selection();
    GoRouter.of(context).go(_destinations[index].path);
  }

  void _onMobileItemTapped(int index, BuildContext context) {
    final destination = _mobileDestinations[index];
    SolatifyHaptics.selection();
    if (destination.path == AppRoutes.more) {
      _showMoreMenu(context);
      return;
    }
    GoRouter.of(context).go(destination.path);
  }

  void _showMoreMenu(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.path;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                    child: Text(
                      l.navMore,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: SolatifyType.sectionTitle,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                ..._moreDestinations.map((destination) {
                  final isCurrent = currentLocation.startsWith(
                    destination.path,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Material(
                      color: isCurrent
                          ? SolatifyColors.accentSoft(context)
                          : SolatifyColors.raisedSurface(context),
                      borderRadius: SolatifyRadius.compactCard,
                      child: ListTile(
                        selected: isCurrent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 2,
                        ),
                        shape: const RoundedRectangleBorder(
                          borderRadius: SolatifyRadius.compactCard,
                        ),
                        leading: Icon(
                          isCurrent ? destination.activeIcon : destination.icon,
                          color: theme.colorScheme.tertiary,
                        ),
                        title: Text(
                          _labelForDestination(l, destination),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: SolatifyType.body,
                            fontWeight: isCurrent
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _descriptionForDestination(l, destination),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: SolatifyColors.muted(context),
                        ),
                        onTap: () {
                          SolatifyHaptics.selection();
                          Navigator.pop(context);
                          GoRouter.of(context).go(destination.path);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedIndex = _calculateSelectedIndex(context);
    final useNavigationRail = ResponsiveLayout.isMediumOrLarger(context);
    final isDesktopWidth =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;

    if (useNavigationRail) {
      return _withBackHandling(
        context,
        Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) =>
                      _onItemTapped(index, context),
                  extended: isDesktopWidth,
                  labelType: isDesktopWidth
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.all,
                  minWidth: 80,
                  minExtendedWidth: 200,
                  // Center the items so they are distributed proportionally
                  // along the rail instead of clustering at the top.
                  groupAlignment: 0.0,
                  destinations: _destinations.map((destination) {
                    return NavigationRailDestination(
                      icon: Icon(destination.icon),
                      selectedIcon: Icon(destination.activeIcon),
                      label: Text(_labelForDestination(l, destination)),
                    );
                  }).toList(),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.35),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: child),
                      const QuranMiniPlayer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Proportional sizing for the bottom navigation: scale icons and bar
    // height relative to the device width, clamped so it stays balanced on
    // both small and large phones.
    final width = MediaQuery.sizeOf(context).width;
    final scale = (width / 390).clamp(0.88, 1.12);
    final iconSize = 22.0 * scale;
    final selectedIconSize = 24.0 * scale;
    final barHeight = (64.0 * scale).clamp(60.0, 72.0);
    // Show every label when there is room; collapse to selected-only on
    // narrow devices so the 5 items stay evenly proportioned.
    final labelBehavior = width < 360
        ? NavigationDestinationLabelBehavior.onlyShowSelected
        : NavigationDestinationLabelBehavior.alwaysShow;

    return _withBackHandling(
      context,
      Scaffold(
        body: child,
        // The Quran mini-player sits directly above the navigation bar and
        // collapses to nothing when no recitation is loaded.
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const QuranMiniPlayer(),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _calculateMobileSelectedIndex(context),
                onDestinationSelected: (index) =>
                    _onMobileItemTapped(index, context),
                height: barHeight,
                labelBehavior: labelBehavior,
                backgroundColor: theme.colorScheme.surface,
                elevation: 0,
                destinations: _mobileDestinations.map((destination) {
                  return NavigationDestination(
                    tooltip: _labelForDestination(l, destination),
                    icon: Icon(
                      destination.icon,
                      color: SolatifyColors.muted(context),
                      size: iconSize,
                    ),
                    selectedIcon: Icon(
                      destination.activeIcon,
                      color: theme.colorScheme.tertiary,
                      size: selectedIconSize,
                    ),
                    label: _labelForDestination(l, destination),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _descriptionForDestination(
    AppLocalizations l,
    _MainDestination destination,
  ) {
    switch (destination.path) {
      case AppRoutes.qibla:
        return l.navQiblaHint;
      case AppRoutes.mosque:
        return l.navMosqueHint;
      case AppRoutes.tracker:
        return l.navTrackerHint;
      case AppRoutes.settings:
        return l.navSettingsHint;
      default:
        return '';
    }
  }

  String _labelForDestination(
    AppLocalizations l,
    _MainDestination destination,
  ) {
    switch (destination.path) {
      case AppRoutes.home:
        return l.navHome;
      case AppRoutes.schedule:
        return l.navSchedule;
      case AppRoutes.quran:
        return l.navQuran;
      case AppRoutes.islamicContent:
        return l.navContent;
      case AppRoutes.qibla:
        return l.navQibla;
      case AppRoutes.mosque:
        return l.navMosque;
      case AppRoutes.tracker:
        return l.navTracker;
      case AppRoutes.settings:
        return l.navSettings;
      case AppRoutes.more:
        return l.navMore;
      default:
        return destination.label;
    }
  }
}

class _MainDestination {
  const _MainDestination(this.icon, this.activeIcon, this.label, this.path);

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}
