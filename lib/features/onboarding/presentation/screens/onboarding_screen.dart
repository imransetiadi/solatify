import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/core/widgets/solatify_logo.dart';
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/navigation/app_routes.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/features/notifications/data/services/notification_service.dart';
import 'package:solatify/features/onboarding/presentation/widgets/onboarding_step_indicator.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/location_entity.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _stepCount = 4;
  static const int _welcomeStep = 0;
  static const int _locationStep = 1;
  static const int _notificationStep = 2;
  static const int _summaryStep = 3;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Set when GPS detection fails (permission denied, service off, timeout)
  /// so the location step can explain the manual fallback inline.
  bool _gpsFailed = false;

  /// True while the OS notification permission prompt is in flight.
  bool _isRequestingNotifications = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isEnglish => AppLocalizations.of(context).isEnglish;

  String _t(String id, String en) => _isEnglish ? en : id;

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

  void _nextPage() {
    if (_currentPage < _stepCount - 1) {
      _goToPage(_currentPage + 1);
    }
  }

  /// Asks the OS for notification permission (user-initiated, never at app
  /// startup), mirrors the result into settings, then advances. Any platform
  /// failure is logged and the user still continues onboarding.
  Future<void> _requestNotificationPermission() async {
    if (_isRequestingNotifications) return;
    setState(() => _isRequestingNotifications = true);
    try {
      final service = NotificationService();
      await service.requestAndroidPermissions();
      await service.requestIosPermissions();
      final readiness = await service.getReadinessStatus();
      final allowed =
          readiness.status !=
          NotificationReadinessStatus.needsNotificationPermission;
      await ref
          .read(settingsProvider.notifier)
          .syncAdhanNotificationsWithPermission(allowed);
    } catch (e, stack) {
      debugPrint(
        'Onboarding notification permission request failed: $e\n$stack',
      );
    } finally {
      if (mounted) {
        setState(() => _isRequestingNotifications = false);
        _nextPage();
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _showManualCityDialog() {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (dialogContext, setStateBuilder) {
            final filteredCities = LocationService.defaultCities.where((city) {
              return city.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  city.country.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();

            final media = MediaQuery.of(dialogContext);
            // Inset 16 + content padding 16 on each side.
            final dialogWidth = math.min(480.0, media.size.width - 64);
            final availableHeight =
                media.size.height - media.viewInsets.bottom - media.padding.top;
            final dialogHeight = math.max(220.0, availableHeight * 0.55);

            return AlertDialog(
              scrollable: true,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: SolatifySpacing.lg,
                vertical: SolatifySpacing.xl,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                SolatifySpacing.lg,
                SolatifySpacing.lg,
                SolatifySpacing.lg,
                0,
              ),
              title: Text(_t('Pilih Kota Manual', 'Choose City Manually')),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Column(
                  children: [
                    TextField(
                      autofocus: false,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: _t('Cari Kota...', 'Search city...'),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (val) {
                        setStateBuilder(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: SolatifySpacing.md),
                    Expanded(
                      child: filteredCities.isEmpty
                          ? Center(
                              child: Text(
                                _t('Kota tidak ditemukan', 'No matching city'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: SolatifyColors.muted(dialogContext),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredCities.length,
                              itemBuilder: (_, index) {
                                final city = filteredCities[index];
                                return ListTile(
                                  title: Text(city.name),
                                  subtitle: Text(city.country),
                                  trailing: Icon(
                                    Icons.chevron_right,
                                    color: SolatifyColors.accent(dialogContext),
                                  ),
                                  onTap: () {
                                    ref
                                        .read(locationProvider.notifier)
                                        .setManualCity(city);
                                    Navigator.pop(dialogContext);
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _t(
                                            'Lokasi diatur ke ${city.name}, ${city.country}',
                                            'Location set to ${city.name}, ${city.country}',
                                          ),
                                        ),
                                      ),
                                    );
                                    if (!mounted) return;
                                    setState(() => _gpsFailed = false);
                                    _nextPage();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(AppLocalizations.of(dialogContext).cancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _detectLocationAutomatically() async {
    final success = await ref
        .read(locationProvider.notifier)
        .updateLocationWithGPS();
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      final loc = ref.read(locationProvider);
      setState(() => _gpsFailed = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'Lokasi terdeteksi: ${loc.city}, ${loc.country}',
              'Location detected: ${loc.city}, ${loc.country}',
            ),
          ),
        ),
      );
      _nextPage();
    } else {
      final error = ref.read(locationProvider).errorMessage;
      setState(() => _gpsFailed = true);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error ?? _t('Gagal mendeteksi lokasi', 'Could not detect location'),
          ),
          action: SnackBarAction(
            label: _t('Pilih Manual', 'Choose Manually'),
            onPressed: () {
              if (mounted) _showManualCityDialog();
            },
          ),
        ),
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final isShort = MediaQuery.sizeOf(context).height < 700;

    return PopScope(
      canPop: _currentPage == _welcomeStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _prevPage();
      },
      child: Scaffold(
        body: IslamicBackground(
          child: SafeArea(
            child: ResponsiveCenter(
              maxWidth: 600,
              child: Column(
                children: [
                  _buildHeader(isShort),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        _buildWelcomeSlide(isShort),
                        _buildLocationSlide(location, isShort),
                        _buildNotificationSlide(isShort),
                        _buildSummarySlide(location, isShort),
                      ],
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isShort) {
    return Semantics(
      header: true,
      label: 'Solatify',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isShort ? SolatifySpacing.sm : SolatifySpacing.xl,
            horizontal: SolatifySpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SolatifyLogo(size: 32),
              const SizedBox(width: SolatifySpacing.sm),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'SOLATIFY',
                    style: TextStyle(
                      color: SolatifyColors.text(context),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final padding = ResponsiveLayout.pagePadding(context);
    final showBack = _currentPage > _welcomeStep;

    final Widget primary;
    switch (_currentPage) {
      case _locationStep:
      case _notificationStep:
        // The step's own card holds the primary action; the footer only
        // offers a way to move on without granting anything.
        primary = Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: _nextPage,
            child: Text(
              _currentPage == _notificationStep
                  ? _t('Lewati dahulu', 'Skip for now')
                  : _t('Lewati', 'Skip'),
            ),
          ),
        );
      case _summaryStep:
        primary = FilledButton(
          onPressed: _finishOnboarding,
          child: Text(
            _t('Masuk ke Beranda', 'Go to Home'),
            textAlign: TextAlign.center,
          ),
        );
      default:
        primary = FilledButton(
          onPressed: _nextPage,
          child: Text(_t('LANJUT', 'NEXT'), textAlign: TextAlign.center),
        );
    }

    return Padding(
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
            stepCount: _stepCount,
          ),
          const SizedBox(height: SolatifySpacing.md),
          Row(
            children: [
              if (showBack) ...[
                TextButton.icon(
                  onPressed: _prevPage,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text(AppLocalizations.of(context).back),
                ),
                const SizedBox(width: SolatifySpacing.sm),
              ],
              Expanded(child: primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slideCard({required List<Widget> children}) {
    return GlassContainer(
      opacity: 0.92,
      borderRadius: SolatifyRadius.lg,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SolatifySpacing.xl,
        vertical: SolatifySpacing.xxl - 2,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }

  Widget _slideIcon(IconData icon, bool isShort, {Color? color}) {
    final size = isShort ? 64.0 : 84.0;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: SolatifyColors.accentSoft(context),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: color ?? SolatifyColors.accent(context),
        ),
      ),
    );
  }

  Widget _slideTitle(String text) {
    return Semantics(
      header: true,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: SolatifyColors.text(context),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
      ),
    );
  }

  Widget _slideBody(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: SolatifyColors.muted(context),
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  Widget _buildWelcomeSlide(bool isShort) {
    return OnboardingSlideFrame(
      padding: _slidePadding(),
      child: _slideCard(
        children: [
          SolatifyLogo(size: isShort ? 72 : 96),
          SizedBox(height: isShort ? SolatifySpacing.lg : SolatifySpacing.xxl),
          _slideTitle(_t('Selamat Datang', 'Welcome')),
          const SizedBox(height: SolatifySpacing.md),
          _slideBody(
            _t(
              "Solatify membantu Anda mengelola jadwal salat, membaca Al-Qur'an, mencari kiblat, dan menemukan masjid terdekat.",
              "Solatify helps you keep prayer times, read the Qur'an, find the qibla, and discover nearby mosques.",
            ),
          ),
          const SizedBox(height: SolatifySpacing.lg),
          _slideBody(
            _t(
              'Hanya butuh 1 menit untuk menyiapkannya.',
              'Setup takes about a minute.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSlide(LocationEntity location, bool isShort) {
    final hasCity = location.city.trim().isNotEmpty;
    return OnboardingSlideFrame(
      padding: _slidePadding(),
      child: _slideCard(
        children: [
          _slideIcon(Icons.location_on_outlined, isShort),
          SizedBox(height: isShort ? SolatifySpacing.lg : SolatifySpacing.xl),
          _slideTitle(_t('Atur Lokasi Anda', 'Set Your Location')),
          const SizedBox(height: SolatifySpacing.sm),
          _slideBody(
            _t(
              'Lokasi dipakai untuk menghitung jadwal salat dan arah kiblat yang akurat di tempat Anda.',
              'Your location is used to calculate accurate prayer times and qibla direction where you are.',
            ),
          ),
          const SizedBox(height: SolatifySpacing.md),
          _InfoLine(
            icon: Icons.wifi_off_outlined,
            text: _t(
              'Tidak ingin memakai GPS? Pilih kota secara manual, tetap berfungsi offline.',
              "Prefer not to use GPS? Pick a city manually, it works offline too.",
            ),
          ),
          if (hasCity) ...[
            const SizedBox(height: SolatifySpacing.xs),
            _InfoLine(
              icon: Icons.place_outlined,
              text: _t(
                'Lokasi saat ini: ${location.city}, ${location.country}',
                'Current location: ${location.city}, ${location.country}',
              ),
            ),
          ],
          if (_gpsFailed && !location.isLoading) ...[
            const SizedBox(height: SolatifySpacing.md),
            _NoticeBox(
              text: _t(
                'Lokasi tidak dapat dideteksi. Periksa izin lokasi atau GPS, atau pilih kota manual untuk melanjutkan.',
                'Location could not be detected. Check location permission or GPS, or choose a city manually to continue.',
              ),
            ),
          ],
          const SizedBox(height: SolatifySpacing.xl),
          if (location.isLoading)
            Semantics(
              liveRegion: true,
              label: _t('Mendeteksi lokasi…', 'Detecting location…'),
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: SolatifySpacing.sm),
                    Text(
                      _t('Mendeteksi lokasi…', 'Detecting location…'),
                      style: TextStyle(color: SolatifyColors.muted(context)),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _detectLocationAutomatically,
                icon: const Icon(Icons.my_location),
                label: Text(
                  _gpsFailed
                      ? _t('Coba Deteksi Lagi', 'Try Detecting Again')
                      : _t(
                          'Deteksi Lokasi Otomatis (GPS)',
                          'Detect Location Automatically (GPS)',
                        ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: SolatifySpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showManualCityDialog,
                icon: const Icon(Icons.map_outlined),
                label: Text(
                  _t(
                    'Pilih Kota Manual (Offline)',
                    'Choose City Manually (Offline)',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationSlide(bool isShort) {
    return OnboardingSlideFrame(
      padding: _slidePadding(),
      child: _slideCard(
        children: [
          _slideIcon(Icons.notifications_active_outlined, isShort),
          SizedBox(height: isShort ? SolatifySpacing.lg : SolatifySpacing.xl),
          _slideTitle(_t('Aktifkan Pengingat', 'Turn On Reminders')),
          const SizedBox(height: SolatifySpacing.sm),
          _slideBody(
            _t(
              'Dapatkan pengingat saat waktu salat tiba agar ibadah tidak terlewat.',
              'Get a reminder when each prayer time begins so you never miss it.',
            ),
          ),
          const SizedBox(height: SolatifySpacing.md),
          _InfoLine(
            icon: Icons.tune,
            text: _t(
              'Anda dapat mengatur atau mematikan pengingat kapan saja di Pengaturan.',
              'You can adjust or turn off reminders anytime in Settings.',
            ),
          ),
          const SizedBox(height: SolatifySpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isRequestingNotifications
                  ? null
                  : _requestNotificationPermission,
              icon: _isRequestingNotifications
                  ? const SizedBox.square(
                      dimension: SolatifyIconSize.inline,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                _t('Izinkan Notifikasi', 'Allow Notifications'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySlide(LocationEntity location, bool isShort) {
    return OnboardingSlideFrame(
      padding: _slidePadding(),
      child: _slideCard(
        children: [
          _slideIcon(
            Icons.check_circle_outline,
            isShort,
            color: SolatifyColors.success(context),
          ),
          SizedBox(height: isShort ? SolatifySpacing.lg : SolatifySpacing.xl),
          _slideTitle(
            _t('Solatify Siap Digunakan!', 'Solatify Is Ready to Use!'),
          ),
          const SizedBox(height: SolatifySpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SolatifySpacing.lg),
            decoration: BoxDecoration(
              color: SolatifyColors.raisedSurface(context),
              borderRadius: SolatifyRadius.compactCard,
              border: Border.all(color: SolatifyColors.border(context)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(
                  _t('Kota Aktif', 'Active City'),
                  '${location.city}, ${location.country}',
                  SolatifyColors.text(context),
                ),
                const Divider(height: SolatifySpacing.xl),
                _buildSummaryRow(
                  _t('Koordinat', 'Coordinates'),
                  '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                  SolatifyColors.muted(context),
                ),
                const Divider(height: SolatifySpacing.xl),
                _buildSummaryRow(
                  _t('Metode Kalkulasi', 'Calculation Method'),
                  'Kemenag RI',
                  SolatifyColors.accent(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: SolatifySpacing.lg),
          _slideBody(
            _t(
              'Semua ini dapat diubah kapan saja di Pengaturan.',
              'You can change all of this anytime in Settings.',
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _slidePadding() {
    final page = ResponsiveLayout.pagePadding(context);
    return EdgeInsets.symmetric(
      horizontal: page.left,
      vertical: SolatifySpacing.xs,
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    // Stacked label/value so long city names and large text never squeeze.
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: SolatifyColors.muted(context),
              fontSize: SolatifyType.caption,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.bold,
                fontSize: SolatifyType.body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = SolatifyColors.muted(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ExcludeSemantics(
            child: Icon(icon, size: SolatifyIconSize.inline, color: muted),
          ),
        ),
        const SizedBox(width: SolatifySpacing.xs),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: muted,
              fontSize: SolatifyType.caption + 1,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final warning = SolatifyColors.warning(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SolatifySpacing.md),
        decoration: BoxDecoration(
          color: warning.withValues(alpha: 0.10),
          borderRadius: SolatifyRadius.icon,
          border: Border.all(color: warning.withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.info_outline,
                size: SolatifyIconSize.cardIcon,
                color: warning,
              ),
            ),
            const SizedBox(width: SolatifySpacing.sm),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: SolatifyColors.text(context),
                  fontSize: SolatifyType.caption + 1,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
