import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';

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
    });

    try {
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

      final mosques = await _fetchMosquesFromOverpass(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      setState(() {
        _gpsLatitude = latitude;
        _gpsLongitude = longitude;
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
      future.then((value) {
        if (!completer.isCompleted) completer.complete(value);
      }).catchError((Object error) {
        lastError = error;
        remaining--;
        if (remaining == 0 && !completer.isCompleted) {
          completer.completeError(lastError ?? 'Semua permintaan gagal.');
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
[out:json][timeout:10];
(
  nwr["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  nwr["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out center tags;
''';

    final response = await http
        .post(
          Uri.parse(endpoint),
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'Solatify/1.0 (OpenStreetMap mosque search)',
          },
          body: {'data': query},
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      final bodyPreview = response.body.replaceAll(RegExp(r'\s+'), ' ').trim();
      final message = bodyPreview.length > 140
          ? '${bodyPreview.substring(0, 140)}...'
          : bodyPreview;
      throw 'Overpass API HTTP ${response.statusCode} (${Uri.parse(endpoint).host}, radius ${radiusMeters}m)${message.isEmpty ? '' : ': $message'}';
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = body['elements'];
    if (elements is! List) return const [];

    final seen = <String>{};
    final mosques = <MosqueItem>[];

    for (final element in elements.whereType<Map<String, dynamic>>()) {
      final mosque = _parseOverpassMosque(element, latitude, longitude);
      if (mosque == null || !seen.add(mosque.id)) continue;
      mosques.add(mosque);
    }

    mosques.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
    return mosques;
  }

  MosqueItem? _parseOverpassMosque(
    Map<String, dynamic> element,
    double userLatitude,
    double userLongitude,
  ) {
    final type = element['type']?.toString() ?? 'osm';
    final rawId = element['id']?.toString();
    if (rawId == null) return null;

    final center = element['center'];
    final latitude =
        (element['lat'] as num?)?.toDouble() ??
        (center is Map ? (center['lat'] as num?)?.toDouble() : null);
    final longitude =
        (element['lon'] as num?)?.toDouble() ??
        (center is Map ? (center['lon'] as num?)?.toDouble() : null);
    if (latitude == null || longitude == null) return null;

    final tags = element['tags'] is Map
        ? Map<String, dynamic>.from(element['tags'] as Map)
        : const <String, dynamic>{};
    final name =
        _firstTag(tags, const ['name', 'name:id', 'official_name']) ??
        'Masjid tanpa nama';
    final address = _formatAddress(tags);

    return MosqueItem(
      id: '$type/$rawId',
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceInMeters: _distanceInMeters(
        userLatitude,
        userLongitude,
        latitude,
        longitude,
      ),
      sourceType: type,
    );
  }

  String? _firstTag(Map<String, dynamic> tags, List<String> keys) {
    for (final key in keys) {
      final value = tags[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  String _formatAddress(Map<String, dynamic> tags) {
    final fullAddress = _firstTag(tags, const ['addr:full']);
    if (fullAddress != null) return fullAddress;

    final parts = [
      _firstTag(tags, const ['addr:street']),
      _firstTag(tags, const ['addr:suburb', 'addr:village']),
      _firstTag(tags, const ['addr:city', 'addr:district']),
    ].whereType<String>().toList();

    if (parts.isNotEmpty) return parts.join(', ');
    return 'Alamat belum tersedia di OpenStreetMap';
  }

  double _distanceInMeters(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  Future<void> _openOpenStreetMap(
    BuildContext context,
    MosqueItem mosque,
  ) async {
    final url = Uri.parse(
      'https://www.openstreetmap.org/?mlat=${mosque.latitude}&mlon=${mosque.longitude}#map=18/${mosque.latitude}/${mosque.longitude}',
    );

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka OpenStreetMap.')),
      );
    }
  }

  Future<void> _openRoute(BuildContext context, MosqueItem mosque) async {
    final userLat = _gpsLatitude;
    final userLng = _gpsLongitude;
    final url = userLat == null || userLng == null
        ? Uri.parse(
            'https://www.openstreetmap.org/?mlat=${mosque.latitude}&mlon=${mosque.longitude}#map=18/${mosque.latitude}/${mosque.longitude}',
          )
        : Uri.parse(
            'https://www.openstreetmap.org/directions?engine=fossgis_osrm_car&route=$userLat%2C$userLng%3B${mosque.latitude}%2C${mosque.longitude}',
          );

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka rute OpenStreetMap.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.secondary;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final mutedColor = isDark ? const Color(0xFFB8A898) : const Color(0xFF5D4E47);
    final backgroundColor = isDark
        ? const Color(0xFF082E1D)
        : const Color(0xFFF3FBF6);
    final cardColor = isDark ? const Color(0xFF123B29) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Masjid Terdekat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: RefreshIndicator(
            onRefresh: _loadNearbyMosques,
            child: ListView(
              padding: ResponsiveLayout.pagePadding(
                context,
              ).copyWith(bottom: 96),
              children: [
                _LocationHeader(
                  city: location.city,
                  country: location.country,
                  isLoading: _isLoading || location.isLoading,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primary: primary,
                  cardColor: cardColor,
                  onRefresh: _loadNearbyMosques,
                ),
                const SizedBox(height: 16),
                _OsmInfoPanel(
                  cardColor: cardColor,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primary: primary,
                  mosqueCount: _mosques.length,
                  radiusKm: _searchRadiusMeters ~/ 1000,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Masjid dari OpenStreetMap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (_isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Radius ${_searchRadiusMeters ~/ 1000} km dari GPS aktif. Data bersumber dari Overpass API.',
                  style: TextStyle(color: mutedColor, fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (_errorMessage != null)
                  _StatusCard(
                    message: _errorMessage!,
                    cardColor: cardColor,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    primary: primary,
                    onRetry: _loadNearbyMosques,
                  ),
                for (final mosque in _mosques)
                  _MosqueCard(
                    mosque: mosque,
                    primary: primary,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    cardColor: cardColor,
                    onOpenMap: () => _openOpenStreetMap(context, mosque),
                    onOpenRoute: () => _openRoute(context, mosque),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader({
    required this.city,
    required this.country,
    required this.isLoading,
    required this.textColor,
    required this.mutedColor,
    required this.primary,
    required this.cardColor,
    required this.onRefresh,
  });

  final String city;
  final String country;
  final bool isLoading;
  final Color textColor;
  final Color mutedColor;
  final Color primary;
  final Color cardColor;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Icon(Icons.location_on_outlined, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lokasi GPS Aktif',
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$city, $country',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Cari ulang dari GPS',
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primary,
                      ),
                    )
                  : Icon(Icons.my_location, color: primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _OsmInfoPanel extends StatelessWidget {
  const _OsmInfoPanel({
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.primary,
    required this.mosqueCount,
    required this.radiusKm,
  });

  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color primary;
  final int mosqueCount;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.map_outlined, color: primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OpenStreetMap + Overpass',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$mosqueCount masjid ditemukan dalam radius $radiusKm km.',
                    style: TextStyle(color: mutedColor, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.message,
    required this.cardColor,
    required this.textColor,
    required this.mutedColor,
    required this.primary,
    required this.onRetry,
  });

  final String message;
  final Color cardColor;
  final Color textColor;
  final Color mutedColor;
  final Color primary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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

    return Card(
      elevation: 0,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
