import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/location_entity.dart';
import 'package:solatify/features/settings/presentation/providers/settings_provider.dart';

import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/islamic/islamic_decorations.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showManualCityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            final filteredCities = LocationService.defaultCities.where((city) {
              return city.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  city.country.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
            }).toList();

            final dialogWidth = (MediaQuery.sizeOf(context).width - 48).clamp(
              320.0,
              520.0,
            );
            final dialogHeight = MediaQuery.sizeOf(context).height * 0.62;

            return AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF),
              title: const Text(
                'Pilih Kota Manual',
                style: TextStyle(color: Color(0xFF241A12)),
              ),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Column(
                  children: [
                    TextField(
                      style: const TextStyle(color: Color(0xFF241A12)),
                      decoration: InputDecoration(
                        hintText: 'Cari Kota...',
                        hintStyle: const TextStyle(color: Color(0xFF5D4E47)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF5D4E47),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFFCFE7D5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF0E4D31),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        setStateBuilder(() {
                          searchQuery = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          return ListTile(
                            title: Text(
                              city.name,
                              style: const TextStyle(color: Color(0xFF241A12)),
                            ),
                            subtitle: Text(
                              city.country,
                              style: const TextStyle(color: Color(0xFF5D4E47)),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Color(0xFF0E4D31),
                            ),
                            onTap: () {
                              ref
                                  .read(locationProvider.notifier)
                                  .setManualCity(city);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lokasi diatur ke ${city.name}, ${city.country}',
                                  ),
                                  backgroundColor: const Color(0xFF0E4D31),
                                ),
                              );
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Color(0xFF5D4E47)),
                  ),
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
    if (success) {
      final loc = ref.read(locationProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi terdeteksi: ${loc.city}, ${loc.country}'),
            backgroundColor: const Color(0xFF0E4D31),
          ),
        );
        _nextPage();
      }
    } else {
      final error = ref.read(locationProvider).errorMessage;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal mendeteksi lokasi'),
            backgroundColor: const Color(0xFF241A12),
          ),
        );
      }
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IslamicBackground(
        child: Stack(
          children: [
            SafeArea(
              child: ResponsiveCenter(
                maxWidth: 680,
                child: Column(
                  children: [
                    // Header Brand Logo
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.sizeOf(context).height < 680
                            ? 14
                            : 24,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/images/masjid_nabawi.svg',
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SOLATIFY',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF241A12),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Slide Pages
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        children: [
                          // Slide 1: Welcome
                          _buildWelcomeSlide(),
                          // Slide 2: Location
                          _buildLocationSlide(location),
                          // Slide 3: Notifications
                          _buildNotificationSlide(),
                          // Slide 4: Final Summary
                          _buildSummarySlide(location),
                        ],
                      ),
                    ),

                    // Footer Navigation Controls
                    Padding(
                      padding: ResponsiveLayout.pagePadding(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Back Button
                          Opacity(
                            opacity: _currentPage > 0 ? 1.0 : 0.0,
                            child: TextButton(
                              onPressed: _currentPage > 0 ? _prevPage : null,
                              child: const Text(
                                'KEMBALI',
                                style: TextStyle(
                                  color: Color(0xFF5D4E47),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),

                          // Indicators
                          Row(
                            children: List.generate(4, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: _currentPage == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? const Color(0xFF0E4D31)
                                      : const Color(0xFFCFE7D5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),

                          // Next Button (hidden or replaces by custom buttons depending on slide requirements)
                          _currentPage == 3
                              ? TextButton(
                                  onPressed: _finishOnboarding,
                                  child: Text(
                                    'MULAI',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF241A12), // Black
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                )
                              : TextButton(
                                  onPressed:
                                      _currentPage == 1 || _currentPage == 2
                                      ? null
                                      : _nextPage,
                                  child: Opacity(
                                    opacity:
                                        _currentPage == 1 || _currentPage == 2
                                        ? 0.0
                                        : 1.0,
                                    child: const Text(
                                      'LANJUT',
                                      style: TextStyle(
                                        color: Color(0xFF0E4D31),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSlide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OnboardingSlideFrame(
      child: Center(
        child: GlassContainer(
          blur: 20,
          opacity: 0.92,
          borderRadius: 20,
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.spatial_audio_off_outlined,
                size: 80,
                color: isDark ? Colors.white : const Color(0xFF241A12),
              ),
              const SizedBox(height: 32),
              Text(
                'Selamat Datang',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF241A12),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Solatify membantu Anda mengelola jadwal salat, membaca Al-Qur'an, mencari kiblat, dan menemukan masjid terdekat.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D4E47),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSlide(LocationEntity location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OnboardingSlideFrame(
      child: Center(
        child: GlassContainer(
          blur: 20,
          opacity: 0.92,
          borderRadius: 20,
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 72,
                color: Color(0xFF0E4D31),
              ),
              const SizedBox(height: 24),
              Text(
                'Atur Lokasi Anda',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF241A12),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Untuk menghitung jadwal salat dan menentukan arah kiblat yang akurat, izinkan akses lokasi Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D4E47),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              if (location.isLoading)
                const CircularProgressIndicator()
              else ...[
                // GPS Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E4D31),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _detectLocationAutomatically,
                  icon: const Icon(Icons.my_location),
                  label: const Text(
                    'Deteksi Lokasi Otomatis (GPS)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                // Manual Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0E4D31),
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Color(0xFFCFE7D5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _showManualCityDialog,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text(
                    'Pilih Kota Manual (Offline)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSlide() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OnboardingSlideFrame(
      child: Center(
        child: GlassContainer(
          blur: 20,
          opacity: 0.92,
          borderRadius: 20,
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_active_outlined,
                size: 72,
                color: isDark ? Colors.white : const Color(0xFF241A12),
              ),
              const SizedBox(height: 24),
              Text(
                'Aktifkan Pengingat',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF241A12),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aktifkan pengaturan preferensi Anda sesuai kebutuhan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF5D4E47),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF241A12),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _nextPage,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'Izinkan Notifikasi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _nextPage,
                child: const Text(
                  'Lewati dahulu',
                  style: TextStyle(color: Color(0xFF5D4E47)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySlide(LocationEntity location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _OnboardingSlideFrame(
      child: Center(
        child: GlassContainer(
          blur: 20,
          opacity: 0.92,
          borderRadius: 20,
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF0E4D31),
              ),
              const SizedBox(height: 24),
              Text(
                'Solatify Siap Digunakan!',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF241A12),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Summary details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCFE7D5)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'Kota Aktif:',
                      '${location.city}, ${location.country}',
                      const Color(0xFF241A12),
                    ),
                    const Divider(color: Color(0xFFCFE7D5), height: 24),
                    _buildSummaryRow(
                      'Koordinat:',
                      '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                      const Color(0xFF5D4E47),
                    ),
                    const Divider(color: Color(0xFFCFE7D5), height: 24),
                    _buildSummaryRow(
                      'Metode Kalkulasi:',
                      'Kemenag RI',
                      const Color(0xFF0E4D31),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E4D31),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _finishOnboarding,
                child: const Text(
                  'Masuk ke Beranda',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF5D4E47))),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingSlideFrame extends StatelessWidget {
  const _OnboardingSlideFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: ResponsiveLayout.pagePadding(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: (MediaQuery.sizeOf(context).height - 220)
              .clamp(360.0, 720.0)
              .toDouble(),
        ),
        child: child,
      ),
    );
  }
}
