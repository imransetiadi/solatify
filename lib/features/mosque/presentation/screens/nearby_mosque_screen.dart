import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:solatify/core/localization/app_localizations.dart';
import 'package:solatify/core/services/solatify_haptics.dart';
import 'package:solatify/core/theme/theme.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/core/widgets/solatify_design_tokens.dart';
import 'package:solatify/core/widgets/solatify_state_view.dart';
import 'package:solatify/features/mosque/data/mosque_search_utils.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Why the GPS position could not be used (presentation-only state).
enum _LocationIssue { none, serviceDisabled, denied, deniedForever }

const _tabularFigures = [FontFeature.tabularFigures()];

class NearbyMosqueScreen extends ConsumerStatefulWidget {
  const NearbyMosqueScreen({super.key});

  @override
  ConsumerState<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

class _NearbyMosqueScreenState extends ConsumerState<NearbyMosqueScreen>
    with WidgetsBindingObserver {
  static const _searchRadiusMeters = 5000;
  static const _fallbackRadiusMeters = [5000, 2500];
  static const _requestTimeout = Duration(seconds: 12);
  static const _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];
  static final Map<String, List<MosqueItem>> _mosqueMemoryCache = {};

  final TextEditingController _searchController = TextEditingController();
  List<MosqueItem> _mosques = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String _locationStatusMessage = 'Menyiapkan lokasi...';
  _LocationIssue _locationIssue = _LocationIssue.none;
  double? _gpsLatitude;
  double? _gpsLongitude;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyMosques());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Returning from system settings: retry with GPS if access was missing.
    if (state == AppLifecycleState.resumed &&
        _locationIssue != _LocationIssue.none &&
        !_isLoading) {
      _loadNearbyMosques();
    }
  }

  Future<void> _loadNearbyMosques() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _locationStatusMessage = 'Mengecek GPS perangkat...';
    });

    try {
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      final permission = await LocationService.checkPermission();
      final position = await LocationService.getCurrentPosition().timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );

      final location = ref.read(locationProvider);
      final latitude = position?.latitude ?? location.latitude;
      final longitude = position?.longitude ?? location.longitude;
      final cacheKey = buildMosqueCacheKey(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: _searchRadiusMeters,
      );

      if (position != null) {
        final details = await LocationService.getCityCountry(
          latitude,
          longitude,
        );
        await ref
            .read(locationProvider.notifier)
            .setManualCity(
              OfflineCity(
                name: details['city'] ?? location.city,
                country: details['country'] ?? location.country,
                latitude: latitude,
                longitude: longitude,
              ),
            );
      }

      final locationStatusMessage = position != null
          ? 'Menggunakan lokasi GPS saat ini.'
          : _buildFallbackLocationMessage(serviceEnabled, permission);
      final locationIssue = position != null
          ? _LocationIssue.none
          : !serviceEnabled
          ? _LocationIssue.serviceDisabled
          : permission == LocationPermission.deniedForever
          ? _LocationIssue.deniedForever
          : permission == LocationPermission.denied
          ? _LocationIssue.denied
          : _LocationIssue.none;

      final cachedMosques = _mosqueMemoryCache[cacheKey];
      if (cachedMosques != null && mounted) {
        setState(() {
          _gpsLatitude = latitude;
          _gpsLongitude = longitude;
          _locationStatusMessage = '$locationStatusMessage Memuat pembaruan...';
          _locationIssue = locationIssue;
          _mosques = cachedMosques;
          _errorMessage = null;
        });
      }

      final mosques = await _fetchMosquesFromOverpass(
        latitude: latitude,
        longitude: longitude,
      );
      _mosqueMemoryCache[cacheKey] = mosques;

      if (!mounted) return;

      setState(() {
        _gpsLatitude = latitude;
        _gpsLongitude = longitude;
        _locationStatusMessage = locationStatusMessage;
        _locationIssue = locationIssue;
        _mosques = mosques;
        _isLoading = false;
        _hasLoaded = true;
        // An empty result is rendered as an empty state, not an error.
        _errorMessage = null;
      });
    } catch (error) {
      debugPrint('Nearby mosque search failed: $error');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
        _errorMessage = _isNetworkError(error)
            ? 'Server peta tidak merespons. Periksa koneksi internet lalu coba lagi.'
            : 'Terjadi kendala saat mencari masjid terdekat. Silakan coba lagi.';
      });
    }
  }

  bool _isNetworkError(Object error) {
    final text = error.toString().toLowerCase();
    return error is TimeoutException ||
        text.contains('socket') ||
        text.contains('timeout') ||
        text.contains('connection') ||
        text.contains('overpass');
  }

  Future<void> _resolveLocationIssue() async {
    try {
      switch (_locationIssue) {
        case _LocationIssue.serviceDisabled:
          await Geolocator.openLocationSettings();
          return; // Reloaded on app resume.
        case _LocationIssue.deniedForever:
          await Geolocator.openAppSettings();
          return; // Reloaded on app resume.
        case _LocationIssue.denied:
          await LocationService.requestPermission();
        case _LocationIssue.none:
          break;
      }
    } catch (error) {
      debugPrint('Mosque location access action failed: $error');
    }
    await _loadNearbyMosques();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  List<MosqueItem> get _filteredMosques {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _mosques;
    return _mosques
        .where(
          (mosque) =>
              mosque.name.toLowerCase().contains(query) ||
              mosque.address.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  String _buildFallbackLocationMessage(
    bool serviceEnabled,
    LocationPermission permission,
  ) {
    if (!serviceEnabled) {
      return 'GPS perangkat belum aktif. Menggunakan lokasi tersimpan.';
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return 'Izin lokasi belum aktif. Menggunakan lokasi tersimpan.';
    }

    return 'GPS belum mendapatkan posisi. Menggunakan lokasi tersimpan.';
  }

  Future<List<MosqueItem>> _fetchMosquesFromOverpass({
    required double latitude,
    required double longitude,
  }) async {
    Object? lastError;

    // For each radius, query all Overpass endpoints CONCURRENTLY and take the
    // first one that responds successfully. This avoids waiting through a long
    // chain of sequential timeouts when public servers are slow/unreachable.
    for (final radius in _fallbackRadiusMeters) {
      final futures = _overpassEndpoints
          .map(
            (endpoint) => _fetchMosquesFromEndpoint(
              endpoint: endpoint,
              radiusMeters: radius,
              latitude: latitude,
              longitude: longitude,
            ),
          )
          .toList();
      try {
        return await _firstSuccess(futures);
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? 'Semua endpoint Overpass gagal merespons.';
  }

  /// Returns the value of the first future that completes successfully.
  /// If all futures fail, completes with the last error.
  Future<T> _firstSuccess<T>(List<Future<T>> futures) {
    final completer = Completer<T>();
    var remaining = futures.length;
    Object? lastError;

    for (final future in futures) {
      future
          .then((value) {
            if (!completer.isCompleted) completer.complete(value);
          })
          .catchError((Object error) {
            lastError = error;
            remaining--;
            if (remaining == 0 && !completer.isCompleted) {
              completer.completeError(lastError ?? 'Semua future gagal.');
            }
          });
    }

    return completer.future;
  }

  Future<List<MosqueItem>> _fetchMosquesFromEndpoint({
    required String endpoint,
    required int radiusMeters,
    required double latitude,
    required double longitude,
  }) async {
    final query = buildMosqueOverpassQuery(
      radiusMeters: radiusMeters,
      latitude: latitude,
      longitude: longitude,
    );
    final response = await http
        .post(
          Uri.parse(endpoint),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'Solatify/1.0 mosque-search',
          },
          body: {'data': query},
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Format respons Overpass tidak valid.');
      }
      return parseMosqueOverpassElements(
        data: decoded,
        originLatitude: latitude,
        originLongitude: longitude,
      );
    }

    debugPrint(
      'Overpass mosque search failed at $endpoint with status ${response.statusCode}: ${response.body.substring(0, math.min(response.body.length, 160))}',
    );
    throw Exception('Gagal memuat data masjid dari $endpoint');
  }

  Future<void> _launchMapUri(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;

      debugPrint('Map launch returned false for $uri');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
      );
    } catch (e) {
      debugPrint('Error launching map URL $uri: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi peta.')),
      );
    }
  }

  Future<void> _openInMap(MosqueItem mosque) async {
    final uri = buildMosqueMapUri(
      latitude: mosque.latitude,
      longitude: mosque.longitude,
      platform: _currentMapPlatform(),
    );
    await _launchMapUri(uri);
  }

  Future<void> _openRoute(MosqueItem mosque) async {
    final uri = buildMosqueRouteUri(
      latitude: mosque.latitude,
      longitude: mosque.longitude,
      platform: _currentMapPlatform(),
    );
    await _launchMapUri(uri);
  }

  MosqueMapPlatform _currentMapPlatform() {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? MosqueMapPlatform.ios
        : MosqueMapPlatform.android;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEnglish = l.isEnglish;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = AppTheme.readableAccent(context);
    final textColor = SolatifyColors.text(context);
    final mutedColor = SolatifyColors.muted(context);
    final appBarColor = theme.colorScheme.surface.withValues(
      alpha: isDark ? 0.96 : 0.94,
    );
    final filtered = _filteredMosques;
    final showSkeleton = !_hasLoaded || (_isLoading && _mosques.isEmpty);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        title: Text(
          isEnglish ? 'Nearby Mosques' : 'Masjid Terdekat',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: ResponsiveLayout.pagePadding(
                  context,
                ).copyWith(top: SolatifySpacing.lg, bottom: 0),
                sliver: SliverList.list(
                  children: [
                    _buildHeader(
                      isEnglish,
                      primaryColor,
                      textColor,
                      mutedColor,
                    ),
                    if (_locationIssue != _LocationIssue.none) ...[
                      const SizedBox(height: SolatifySpacing.md),
                      _buildLocationIssueState(isEnglish),
                    ],
                    const SizedBox(height: SolatifySpacing.lg),
                    _AreaMapCard(
                      latitude: _gpsLatitude,
                      longitude: _gpsLongitude,
                      mosques: _mosques,
                      primary: primaryColor,
                      textColor: textColor,
                      mutedColor: mutedColor,
                      isEnglish: isEnglish,
                    ),
                    const SizedBox(height: SolatifySpacing.lg),
                    if (_mosques.isNotEmpty) ...[
                      _buildSearchField(isEnglish),
                      const SizedBox(height: SolatifySpacing.sm),
                      _buildResultSummary(
                        isEnglish,
                        filtered.length,
                        mutedColor,
                      ),
                      const SizedBox(height: SolatifySpacing.sm),
                    ],
                    AnimatedSwitcher(
                      duration: SolatifyMotion.of(context, SolatifyMotion.fast),
                      child: _isLoading && _mosques.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(
                                bottom: SolatifySpacing.sm,
                              ),
                              child: Semantics(
                                label: isEnglish
                                    ? 'Updating mosque list'
                                    : 'Memperbarui daftar masjid',
                                child: LinearProgressIndicator(
                                  minHeight: 2,
                                  color: primaryColor,
                                  backgroundColor: primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (_errorMessage != null && _mosques.isNotEmpty) ...[
                      SolatifyStateView.error(
                        compact: true,
                        title: isEnglish
                            ? 'Could not refresh'
                            : 'Pembaruan belum berhasil',
                        description: isEnglish
                            ? 'Showing the last results. Check your connection and try again.'
                            : '${_errorMessage!} Menampilkan hasil terakhir.',
                        actionLabel: isEnglish ? 'Try Again' : 'Coba Lagi',
                        onAction: _loadNearbyMosques,
                      ),
                      const SizedBox(height: SolatifySpacing.md),
                    ],
                  ],
                ),
              ),
              SliverPadding(
                padding: ResponsiveLayout.pagePadding(
                  context,
                ).copyWith(top: 0, bottom: SolatifySpacing.bottomNav),
                sliver: showSkeleton
                    ? _MosqueSkeletonList(isEnglish: isEnglish)
                    : _errorMessage != null && _mosques.isEmpty
                    ? SliverToBoxAdapter(
                        child: SolatifyStateView.error(
                          title: isEnglish
                              ? 'Search did not succeed'
                              : 'Pencarian belum berhasil',
                          description: isEnglish
                              ? 'The map server did not respond. Check your connection and try again.'
                              : _errorMessage!,
                          icon: Icons.wifi_off_rounded,
                          actionLabel: isEnglish ? 'Try Again' : 'Coba Lagi',
                          onAction: _loadNearbyMosques,
                        ),
                      )
                    : _mosques.isEmpty
                    ? SliverToBoxAdapter(
                        child: SolatifyStateView.empty(
                          title: isEnglish
                              ? 'No mosques found'
                              : 'Belum ada masjid ditemukan',
                          description: isEnglish
                              ? 'No mosques found on OpenStreetMap within ${_searchRadiusMeters ~/ 1000} km.'
                              : 'Tidak ada masjid yang ditemukan di OpenStreetMap dalam radius ${_searchRadiusMeters ~/ 1000} km.',
                          icon: Icons.mosque_outlined,
                          actionLabel: isEnglish ? 'Search Again' : 'Cari Lagi',
                          onAction: _loadNearbyMosques,
                        ),
                      )
                    : filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: SolatifyStateView.empty(
                          title: isEnglish
                              ? 'No matching mosques'
                              : 'Tidak ada masjid yang cocok',
                          description: isEnglish
                              ? 'Nothing matches "${_query.trim()}". Try another name or street.'
                              : 'Tidak ada hasil untuk "${_query.trim()}". Coba nama atau jalan lain.',
                          icon: Icons.search_off_rounded,
                          actionLabel: isEnglish
                              ? 'Clear search'
                              : 'Hapus pencarian',
                          actionIcon: Icons.close_rounded,
                          onAction: _clearSearch,
                        ),
                      )
                    : SliverList.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final mosque = filtered[index];
                          return _MosqueCard(
                            key: ValueKey(mosque.id),
                            mosque: mosque,
                            primary: primaryColor,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            isEnglish: isEnglish,
                            onOpenMap: () => _openInMap(mosque),
                            onOpenRoute: () => _openRoute(mosque),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    bool isEnglish,
    Color primaryColor,
    Color textColor,
    Color mutedColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEnglish
                    ? 'Find mosques around you'
                    : 'Temukan Masjid terdekat di sekitar Anda',
                style: TextStyle(
                  color: textColor,
                  fontSize: SolatifyType.body,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Text(
                  _locationStatusMessage,
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: SolatifyType.caption,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_gpsLatitude != null && _gpsLongitude != null) ...[
                const SizedBox(height: 2),
                Text(
                  'GPS: ${_gpsLatitude!.toStringAsFixed(4)}, ${_gpsLongitude!.toStringAsFixed(4)}',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: SolatifyType.eyebrow,
                    fontWeight: FontWeight.w600,
                    fontFeatures: _tabularFigures,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: SolatifySpacing.xs),
        IconButton(
          icon: const Icon(Icons.my_location),
          color: primaryColor,
          constraints: const BoxConstraints(
            minWidth: SolatifyTapTarget.min,
            minHeight: SolatifyTapTarget.min,
          ),
          tooltip: isEnglish
              ? 'Use current GPS location'
              : 'Gunakan Lokasi GPS Saat Ini',
          onPressed: _isLoading
              ? null
              : () {
                  SolatifyHaptics.selection();
                  _loadNearbyMosques();
                },
        ),
      ],
    );
  }

  Widget _buildLocationIssueState(bool isEnglish) {
    final (String title, String action) = switch (_locationIssue) {
      _LocationIssue.serviceDisabled => (
        isEnglish ? 'Location (GPS) is off' : 'GPS perangkat belum aktif',
        isEnglish ? 'Turn on GPS' : 'Aktifkan GPS',
      ),
      _LocationIssue.deniedForever => (
        isEnglish ? 'Location permission blocked' : 'Izin lokasi diblokir',
        isEnglish ? 'Open Settings' : 'Buka Pengaturan',
      ),
      _ => (
        isEnglish ? 'Location permission needed' : 'Izin lokasi belum aktif',
        isEnglish ? 'Allow location' : 'Izinkan Lokasi',
      ),
    };

    return SolatifyStateView.permission(
      compact: true,
      icon: Icons.location_off_outlined,
      title: title,
      description: isEnglish
          ? 'Results use your saved location, so distances may be off.'
          : 'Hasil memakai lokasi tersimpan, jadi jarak bisa kurang akurat.',
      actionLabel: action,
      actionIcon: _locationIssue == _LocationIssue.denied
          ? Icons.my_location_rounded
          : null,
      onAction: _isLoading ? null : _resolveLocationIssue,
    );
  }

  Widget _buildSearchField(bool isEnglish) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: isEnglish
            ? 'Search mosque name or address'
            : 'Cari nama masjid atau alamat',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: isEnglish ? 'Clear search' : 'Hapus pencarian',
                onPressed: _clearSearch,
              ),
      ),
    );
  }

  Widget _buildResultSummary(bool isEnglish, int shown, Color mutedColor) {
    final total = _mosques.length;
    final radiusKm = _searchRadiusMeters ~/ 1000;
    final text = _query.trim().isEmpty
        ? (isEnglish
              ? '$total mosques within $radiusKm km · nearest first'
              : '$total masjid dalam $radiusKm km · terdekat dulu')
        : (isEnglish
              ? '$shown of $total mosques'
              : '$shown dari $total masjid');
    return Semantics(
      liveRegion: true,
      child: Text(
        text,
        style: TextStyle(
          color: mutedColor,
          fontSize: SolatifyType.caption,
          fontWeight: FontWeight.w700,
          fontFeatures: _tabularFigures,
        ),
      ),
    );
  }
}

class _AreaMapCard extends StatelessWidget {
  const _AreaMapCard({
    required this.latitude,
    required this.longitude,
    required this.mosques,
    required this.primary,
    required this.textColor,
    required this.mutedColor,
    required this.isEnglish,
  });

  final double? latitude;
  final double? longitude;
  final List<MosqueItem> mosques;
  final Color primary;
  final Color textColor;
  final Color mutedColor;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final visibleMosques = mosques.take(12).toList(growable: false);
    final waiting = latitude == null || longitude == null;

    return GlassContainer(
      borderRadius: SolatifyRadius.lg,
      padding: SolatifySpacing.compactCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, color: primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEnglish ? 'Area Map' : 'Peta Area',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: SolatifyType.cardTitle,
                  ),
                ),
              ),
              Text(
                isEnglish
                    ? '${visibleMosques.length} pins'
                    : '${visibleMosques.length} titik',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: SolatifyType.caption,
                  fontWeight: FontWeight.w600,
                  fontFeatures: _tabularFigures,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            image: true,
            label: waiting
                ? (isEnglish ? 'Waiting for location' : 'Menunggu lokasi')
                : (isEnglish
                      ? 'Area map with ${visibleMosques.length} nearby mosques around your location'
                      : 'Peta area dengan ${visibleMosques.length} masjid di sekitar lokasi Anda'),
            child: ExcludeSemantics(
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: SolatifyRadius.compactCard,
                  child: CustomPaint(
                    painter: _AreaMapPainter(
                      latitude: latitude,
                      longitude: longitude,
                      mosques: visibleMosques,
                      primary: primary,
                      muted: mutedColor,
                      userColor: SolatifyColors.accent(context),
                      ringColor: SolatifyColors.softSurface(context),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          waiting
                              ? (isEnglish
                                    ? 'Waiting for location...'
                                    : 'Menunggu lokasi...')
                              : (isEnglish
                                    ? 'Area around your location'
                                    : 'Radius sekitar lokasi Anda'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: SolatifyType.eyebrow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaMapPainter extends CustomPainter {
  const _AreaMapPainter({
    required this.latitude,
    required this.longitude,
    required this.mosques,
    required this.primary,
    required this.muted,
    required this.userColor,
    required this.ringColor,
  });

  final double? latitude;
  final double? longitude;
  final List<MosqueItem> mosques;
  final Color primary;
  final Color muted;
  final Color userColor;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = primary.withValues(alpha: 0.08);
    final gridPaint = Paint()
      ..color = muted.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    final radiusPaint = Paint()
      ..color = primary.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final markerPaint = Paint()..color = primary;
    final userPaint = Paint()..color = userColor;
    final ringPaint = Paint()..color = ringColor;

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      math.min(size.width, size.height) * 0.36,
      radiusPaint,
    );
    canvas.drawCircle(
      center,
      math.min(size.width, size.height) * 0.24,
      radiusPaint,
    );

    if (latitude == null || longitude == null) {
      _drawUserMarker(canvas, center, userPaint, ringPaint);
      return;
    }

    for (final mosque in mosques) {
      final point = _projectMosque(mosque, size);
      canvas.drawCircle(point, 5, ringPaint);
      canvas.drawCircle(point, 3.5, markerPaint);
    }

    _drawUserMarker(canvas, center, userPaint, ringPaint);
  }

  Offset _projectMosque(MosqueItem mosque, Size size) {
    const visibleMeters = 5000.0;
    final centerLatitude = latitude!;
    final centerLongitude = longitude!;
    final latMeters = (mosque.latitude - centerLatitude) * 111320;
    final lonMeters =
        (mosque.longitude - centerLongitude) *
        111320 *
        math.cos(centerLatitude * math.pi / 180);
    final x = (size.width / 2) + (lonMeters / visibleMeters) * (size.width / 2);
    final y =
        (size.height / 2) - (latMeters / visibleMeters) * (size.height / 2);

    return Offset(
      x.clamp(10, size.width - 10).toDouble(),
      y.clamp(10, size.height - 10).toDouble(),
    );
  }

  void _drawUserMarker(
    Canvas canvas,
    Offset center,
    Paint userPaint,
    Paint ringPaint,
  ) {
    canvas.drawCircle(center, 8, ringPaint);
    canvas.drawCircle(center, 5, userPaint);
  }

  @override
  bool shouldRepaint(_AreaMapPainter oldDelegate) {
    return latitude != oldDelegate.latitude ||
        longitude != oldDelegate.longitude ||
        mosques != oldDelegate.mosques ||
        primary != oldDelegate.primary ||
        muted != oldDelegate.muted ||
        userColor != oldDelegate.userColor ||
        ringColor != oldDelegate.ringColor;
  }
}

String _formatDistance(double meters) {
  final km = meters / 1000;
  return km < 1 ? '${meters.round()} m' : '${km.toStringAsFixed(1)} km';
}

class _MosqueCard extends StatelessWidget {
  const _MosqueCard({
    super.key,
    required this.mosque,
    required this.primary,
    required this.textColor,
    required this.mutedColor,
    required this.isEnglish,
    required this.onOpenMap,
    required this.onOpenRoute,
  });

  final MosqueItem mosque;
  final Color primary;
  final Color textColor;
  final Color mutedColor;
  final bool isEnglish;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final distanceLabel = _formatDistance(mosque.distanceInMeters);
    const buttonPadding = EdgeInsets.symmetric(horizontal: SolatifySpacing.sm);

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: ResponsiveLayout.itemGap),
      borderRadius: SolatifyRadius.lg,
      padding: SolatifySpacing.compactCard,
      onTap: onOpenRoute,
      semanticLabel: isEnglish
          ? '${mosque.name}, $distanceLabel away. Double tap for directions.'
          : '${mosque.name}, berjarak $distanceLabel. Ketuk dua kali untuk rute.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: SolatifyIconSize.cardBox,
                  height: SolatifyIconSize.cardBox,
                  decoration: BoxDecoration(
                    color: SolatifyColors.accentSoft(context),
                    borderRadius: SolatifyRadius.icon,
                  ),
                  child: Icon(
                    Icons.mosque_outlined,
                    color: primary,
                    size: SolatifyIconSize.cardIcon + 3,
                  ),
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text(
                        mosque.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: SolatifyType.cardTitle + 1,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mosque.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: SolatifyType.caption + 1,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SolatifySpacing.xs),
              ExcludeSemantics(
                child: _DistancePill(label: distanceLabel, color: primary),
              ),
            ],
          ),
          const SizedBox(height: SolatifySpacing.md),
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: isEnglish
                      ? 'Show ${mosque.name} in maps'
                      : 'Lihat ${mosque.name} di peta',
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, SolatifyTapTarget.min),
                      padding: buttonPadding,
                    ),
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.map_outlined, size: 17),
                    label: Text(
                      isEnglish ? 'View Map' : 'Lihat Peta',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SolatifySpacing.sm),
              Expanded(
                child: Tooltip(
                  message: isEnglish
                      ? 'Directions to ${mosque.name}'
                      : 'Rute ke ${mosque.name}',
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, SolatifyTapTarget.min),
                      padding: buttonPadding,
                    ),
                    onPressed: onOpenRoute,
                    icon: const Icon(Icons.navigation_rounded, size: 17),
                    label: Text(
                      isEnglish ? 'Directions' : 'Rute',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SolatifyColors.accentSoft(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_rounded, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: SolatifyType.body,
              fontWeight: FontWeight.w800,
              fontFeatures: _tabularFigures,
            ),
          ),
        ],
      ),
    );
  }
}

/// Static placeholder cards shown while the first search runs. Kept
/// non-animated so it is calm and never fights reduce-motion settings.
class _MosqueSkeletonList extends StatelessWidget {
  const _MosqueSkeletonList({required this.isEnglish});

  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final block = SolatifyColors.raisedSurface(context);

    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: block,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );

    return SliverToBoxAdapter(
      child: Semantics(
        liveRegion: true,
        label: isEnglish
            ? 'Searching for nearby mosques'
            : 'Mencari masjid terdekat',
        child: ExcludeSemantics(
          child: Column(
            children: List.generate(
              3,
              (_) => GlassContainer(
                margin: const EdgeInsets.only(bottom: ResponsiveLayout.itemGap),
                borderRadius: SolatifyRadius.lg,
                padding: SolatifySpacing.compactCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: SolatifyIconSize.cardBox,
                          height: SolatifyIconSize.cardBox,
                          decoration: BoxDecoration(
                            color: block,
                            borderRadius: SolatifyRadius.icon,
                          ),
                        ),
                        const SizedBox(width: SolatifySpacing.sm),
                        Expanded(
                          child: Column(
                            children: [
                              bar(0.7, 14),
                              const SizedBox(height: 8),
                              bar(0.9, 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SolatifySpacing.md),
                    Container(
                      height: SolatifyTapTarget.min,
                      decoration: BoxDecoration(
                        color: block,
                        borderRadius: BorderRadius.circular(SolatifyRadius.sm),
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
