import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/core/widgets/glass_container.dart';
import 'package:solatify/core/widgets/islamic/islamic_decorations.dart';
import 'package:solatify/core/widgets/responsive_layout.dart';
import 'package:solatify/features/prayer_schedule/presentation/location_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueItem {
  const MosqueItem({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
    required this.sourceType,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceInMeters;
  final String sourceType;
}

class NearbyMosqueScreen extends ConsumerStatefulWidget {
  const NearbyMosqueScreen({super.key});

  @override
  ConsumerState<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

class _NearbyMosqueScreenState extends ConsumerState<NearbyMosqueScreen> {
  static const _searchRadiusMeters = 5000;
  static const _fallbackRadiusMeters = [5000, 2500];
  static const _requestTimeout = Duration(seconds: 12);
  static const _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];

  List<MosqueItem> _mosques = const [];
  bool _isLoading = false;
  String? _errorMessage;
  String _locationStatusMessage = 'Menyiapkan lokasi...';
  double? _gpsLatitude;
  double? _gpsLongitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyMosques());
  }

  Future<void> _loadNearbyMosques() async {
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

      final mosques = await _fetchMosquesFromOverpass(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      setState(() {
        _gpsLatitude = latitude;
        _gpsLongitude = longitude;
        _locationStatusMessage = locationStatusMessage;
        _mosques = mosques;
        _isLoading = false;
        _errorMessage = mosques.isEmpty
            ? 'Tidak ada masjid yang ditemukan di OpenStreetMap dalam radius ${_searchRadiusMeters ~/ 1000} km.'
            : null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mencari masjid terdekat: $error';
      });
    }
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
    final query =
        '''
[out:json][timeout:${_requestTimeout.inSeconds}];
(
  node["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center tags;
''';
    final response = await http
        .post(Uri.parse(endpoint), body: {'data': query})
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> elements = data['elements'] ?? [];
      final List<MosqueItem> results = [];

      for (final element in elements) {
        if (element is! Map<String, dynamic>) continue;

        final center = element['center'];
        final latitudeValue =
            element['lat'] ??
            (center is Map<String, dynamic> ? center['lat'] : null);
        final longitudeValue =
            element['lon'] ??
            (center is Map<String, dynamic> ? center['lon'] : null);

        if (latitudeValue is! num || longitudeValue is! num) continue;

        final lat = latitudeValue.toDouble();
        final lon = longitudeValue.toDouble();
        final tags = element['tags'];
        final String name = tags is Map<String, dynamic>
            ? tags['name'] ?? 'Masjid Tanpa Nama'
            : 'Masjid Tanpa Nama';
        final String address = tags is Map<String, dynamic>
            ? tags['addr:full'] ??
                  tags['addr:street'] ??
                  tags['addr:place'] ??
                  'Alamat tidak diketahui'
            : 'Alamat tidak diketahui';

        final distance = _calculateDistance(latitude, longitude, lat, lon);

        results.add(
          MosqueItem(
            id: element['id'].toString(),
            name: name,
            address: address,
            latitude: lat,
            longitude: lon,
            distanceInMeters: distance,
            sourceType: element['type']?.toString().toUpperCase() ?? 'NODE',
          ),
        );
      }

      // Sort by distance (closest first)
      results.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
      return results;
    } else {
      throw Exception('Gagal memuat data masjid dari $endpoint');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // Earth radius in meters
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final deltaPhi = (lat2 - lat1) * math.pi / 180;
    final deltaLambda = (lon2 - lon1) * math.pi / 180;

    final a =
        math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return r * c;
  }

  void _openInMap(MosqueItem mosque) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openRoute(MosqueItem mosque) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? const Color(0xFFC78A4C)
        : const Color(0xFF0E4D31);
    final textColor = isDark
        ? const Color(0xFFF3FBF6)
        : const Color(0xFF241A12);
    final mutedColor = isDark
        ? const Color(0xFFC8B8A8)
        : const Color(0xFFAFA19A);
    final cardBg = isDark ? const Color(0xFF241A14) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Masjid Terdekat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: IslamicBackground(
        child: ResponsiveCenter(
          child: Padding(
            padding: ResponsiveLayout.pagePadding(context).copyWith(
              top: kToolbarHeight + MediaQuery.paddingOf(context).top + 8,
            ),
            child: Column(
              children: [
                // Top header controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Temukan Masjid terdekat di sekitar Anda',
                            style: TextStyle(color: mutedColor, fontSize: 13),
                          ),
                          if (_gpsLatitude != null &&
                              _gpsLongitude != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'GPS: ${_gpsLatitude!.toStringAsFixed(4)}, ${_gpsLongitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _locationStatusMessage,
                              style: TextStyle(
                                color: mutedColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location),
                      color: primaryColor,
                      tooltip: 'Gunakan Lokasi GPS Saat Ini',
                      onPressed: _loadNearbyMosques,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AreaMapCard(
                  latitude: _gpsLatitude,
                  longitude: _gpsLongitude,
                  mosques: _mosques,
                  primary: primaryColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                ),
                const SizedBox(height: 16),

                // Main Mosque List
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF0E4D31),
                            ),
                          ),
                        )
                      : _errorMessage != null
                      ? Center(
                          child: SingleChildScrollView(
                            child: _StatusCard(
                              message: _errorMessage!,
                              primary: primaryColor,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              cardColor: cardBg,
                              onRetry: _loadNearbyMosques,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _mosques.length,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 96),
                          itemBuilder: (context, index) {
                            final mosque = _mosques[index];
                            return _MosqueCard(
                              mosque: mosque,
                              primary: primaryColor,
                              textColor: textColor,
                              mutedColor: mutedColor,
                              cardColor: cardBg,
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
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.message,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.primary,
    required this.onRetry,
  });

  final String message;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final Color primary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 18,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pencarian belum berhasil',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: mutedColor, fontSize: 13)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text('Coba Lagi'),
            ),
          ],
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
  });

  final double? latitude;
  final double? longitude;
  final List<MosqueItem> mosques;
  final Color primary;
  final Color textColor;
  final Color mutedColor;

  @override
  Widget build(BuildContext context) {
    final visibleMosques = mosques.take(12).toList(growable: false);

    return GlassContainer(
      borderRadius: 18,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map_outlined, color: primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Peta Area',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  '${visibleMosques.length} titik',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  painter: _AreaMapPainter(
                    latitude: latitude,
                    longitude: longitude,
                    mosques: visibleMosques,
                    primary: primary,
                    muted: mutedColor,
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        latitude == null || longitude == null
                            ? 'Menunggu lokasi...'
                            : 'Radius sekitar lokasi Anda',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
  });

  final double? latitude;
  final double? longitude;
  final List<MosqueItem> mosques;
  final Color primary;
  final Color muted;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = primary.withValues(alpha: 0.08);
    final gridPaint = Paint()
      ..color = muted.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    final radiusPaint = Paint()
      ..color = primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final markerPaint = Paint()..color = primary;
    final userPaint = Paint()..color = Colors.redAccent;

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
      _drawUserMarker(canvas, center, userPaint);
      return;
    }

    for (final mosque in mosques) {
      final point = _projectMosque(mosque, size);
      canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      canvas.drawCircle(point, 3.5, markerPaint);
    }

    _drawUserMarker(canvas, center, userPaint);
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

  void _drawUserMarker(Canvas canvas, Offset center, Paint userPaint) {
    canvas.drawCircle(center, 8, Paint()..color = Colors.white);
    canvas.drawCircle(center, 5, userPaint);
  }

  @override
  bool shouldRepaint(_AreaMapPainter oldDelegate) {
    return latitude != oldDelegate.latitude ||
        longitude != oldDelegate.longitude ||
        mosques != oldDelegate.mosques ||
        primary != oldDelegate.primary ||
        muted != oldDelegate.muted;
  }
}

class _MosqueCard extends StatelessWidget {
  const _MosqueCard({
    required this.mosque,
    required this.primary,
    required this.textColor,
    required this.mutedColor,
    required this.cardColor,
    required this.onOpenMap,
    required this.onOpenRoute,
  });

  final MosqueItem mosque;
  final Color primary;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final distanceKm = mosque.distanceInMeters / 1000;
    final distanceLabel = distanceKm < 1
        ? '${mosque.distanceInMeters.round()} m'
        : '${distanceKm.toStringAsFixed(1)} km';

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      borderRadius: 18,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mosque_outlined, color: primary, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mosque.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  distanceLabel,
                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mosque.address,
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
            const SizedBox(height: 10),
            _InfoChip(
              icon: Icons.public,
              label: 'OSM ${mosque.sourceType}',
              color: primary,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenMap,
                    icon: const Icon(Icons.map_outlined, size: 17),
                    label: const Text('Lihat Peta'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenRoute,
                    icon: const Icon(Icons.navigation, size: 17),
                    label: const Text('Rute'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
