import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';

const _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

class MosqueItem {
  const MosqueItem({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
    required this.rating,
    required this.userRatingsTotal,
    required this.isOpenNow,
  });

  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceInMeters;
  final double? rating;
  final int? userRatingsTotal;
  final bool? isOpenNow;
}

class NearbyMosqueScreen extends ConsumerStatefulWidget {
  const NearbyMosqueScreen({super.key});

  @override
  ConsumerState<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

class _NearbyMosqueScreenState extends ConsumerState<NearbyMosqueScreen> {
  static const _searchRadiusMeters = 5000;

  List<MosqueItem> _mosques = const [];
  bool _isLoading = false;
  String? _errorMessage;
  LatLng? _gpsPosition;
  GoogleMapController? _mapController;

  bool get _hasApiKey => _googleMapsApiKey.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearbyMosques());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyMosques() async {
    if (!_hasApiKey) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Google Maps API key belum disetel. Jalankan app dengan --dart-define=GOOGLE_MAPS_API_KEY=API_KEY_ANDA.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentPosition().timeout(
        const Duration(seconds: 15),
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

      final mosques = await _fetchMosquesFromGooglePlaces(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      setState(() {
        _gpsPosition = LatLng(latitude, longitude);
        _mosques = mosques;
        _isLoading = false;
        _errorMessage = mosques.isEmpty
            ? 'Tidak ada masjid operasional yang ditemukan dalam radius ${_searchRadiusMeters ~/ 1000} km.'
            : null;
      });

      await _moveCameraToUser(latitude, longitude);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mencari masjid terdekat: $error';
      });
    }
  }

  Future<List<MosqueItem>> _fetchMosquesFromGooglePlaces({
    required double latitude,
    required double longitude,
  }) async {
    final uri =
        Uri.https('maps.googleapis.com', '/maps/api/place/nearbysearch/json', {
          'location': '$latitude,$longitude',
          'radius': _searchRadiusMeters.toString(),
          'type': 'mosque',
          'keyword': 'masjid mosque',
          'key': _googleMapsApiKey,
        });

    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw 'HTTP ${response.statusCode} dari Google Places.';
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status']?.toString() ?? 'UNKNOWN_ERROR';

    if (status != 'OK' && status != 'ZERO_RESULTS') {
      final message = body['error_message']?.toString();
      throw message == null
          ? 'Google Places status: $status.'
          : '$status: $message';
    }

    final rawResults = body['results'];
    if (rawResults is! List) return const [];

    final mosques =
        rawResults
            .whereType<Map<String, dynamic>>()
            .where(_isOperationalMosque)
            .map((json) => _parseMosque(json, latitude, longitude))
            .whereType<MosqueItem>()
            .toList()
          ..sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

    return mosques;
  }

  bool _isOperationalMosque(Map<String, dynamic> json) {
    final businessStatus = json['business_status']?.toString();
    final types =
        (json['types'] as List?)?.map((item) => item.toString()).toSet() ??
        const <String>{};

    return businessStatus == 'OPERATIONAL' && types.contains('mosque');
  }

  MosqueItem? _parseMosque(
    Map<String, dynamic> json,
    double userLatitude,
    double userLongitude,
  ) {
    final geometry = json['geometry'];
    final location = geometry is Map ? geometry['location'] : null;
    if (location is! Map) return null;

    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;

    final openingHours = json['opening_hours'];

    return MosqueItem(
      placeId: json['place_id']?.toString() ?? '$latitude,$longitude',
      name: json['name']?.toString() ?? 'Masjid',
      address:
          json['vicinity']?.toString() ??
          json['formatted_address']?.toString() ??
          'Alamat tidak tersedia',
      latitude: latitude,
      longitude: longitude,
      distanceInMeters: _distanceInMeters(
        userLatitude,
        userLongitude,
        latitude,
        longitude,
      ),
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: (json['user_ratings_total'] as num?)?.toInt(),
      isOpenNow: openingHours is Map ? openingHours['open_now'] as bool? : null,
    );
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

  Set<Marker> _buildMarkers() {
    final user = _gpsPosition;
    return {
      if (user != null)
        Marker(
          markerId: const MarkerId('current-location'),
          position: user,
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      for (final mosque in _mosques)
        Marker(
          markerId: MarkerId(mosque.placeId),
          position: LatLng(mosque.latitude, mosque.longitude),
          infoWindow: InfoWindow(title: mosque.name, snippet: mosque.address),
        ),
    };
  }

  Future<void> _moveCameraToUser(double latitude, double longitude) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latitude, longitude), zoom: 14),
      ),
    );
  }

  Future<void> _openMaps(BuildContext context, MosqueItem mosque) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mosque.name)}&query_place_id=${mosque.placeId}',
    );

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.secondary;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final mutedColor = isDark ? Colors.white60 : const Color(0xFF6E5B4B);
    final backgroundColor = isDark
        ? const Color(0xFF082E1D)
        : const Color(0xFFF3FBF6);
    final cardColor = isDark ? const Color(0xFF123B29) : Colors.white;
    final mapCenter =
        _gpsPosition ?? LatLng(location.latitude, location.longitude);

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
                _MapPreview(
                  hasApiKey: _hasApiKey,
                  center: mapCenter,
                  markers: _buildMarkers(),
                  cardColor: cardColor,
                  mutedColor: mutedColor,
                  primary: primary,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Masjid Valid dari Google Maps',
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
                  'Radius ${_searchRadiusMeters ~/ 1000} km dari GPS aktif.',
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
                    onOpenMaps: () => _openMaps(context, mosque),
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

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.hasApiKey,
    required this.center,
    required this.markers,
    required this.cardColor,
    required this.mutedColor,
    required this.primary,
    required this.onMapCreated,
  });

  final bool hasApiKey;
  final LatLng center;
  final Set<Marker> markers;
  final Color cardColor;
  final Color mutedColor;
  final Color primary;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 220,
        child: hasApiKey
            ? GoogleMap(
                initialCameraPosition: CameraPosition(target: center, zoom: 14),
                markers: markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: onMapCreated,
              )
            : ColoredBox(
                color: cardColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, color: primary, size: 34),
                        const SizedBox(height: 10),
                        Text(
                          'Google Maps API key belum tersedia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: mutedColor,
                            fontWeight: FontWeight.w600,
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
                    'Pencarian belum tersedia',
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
    required this.onOpenMaps,
  });

  final MosqueItem mosque;
  final Color primary;
  final Color textColor;
  final Color mutedColor;
  final Color cardColor;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final distanceKm = mosque.distanceInMeters / 1000;
    final distanceLabel = distanceKm < 1
        ? '${mosque.distanceInMeters.round()} m'
        : '${distanceKm.toStringAsFixed(1)} km';
    final ratingLabel = mosque.rating == null
        ? null
        : '${mosque.rating!.toStringAsFixed(1)} (${mosque.userRatingsTotal ?? 0})';
    final openLabel = mosque.isOpenNow == null
        ? null
        : mosque.isOpenNow!
        ? 'Buka sekarang'
        : 'Tutup';

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
            if (ratingLabel != null || openLabel != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (ratingLabel != null)
                    _InfoChip(
                      icon: Icons.star,
                      label: ratingLabel,
                      color: primary,
                    ),
                  if (openLabel != null)
                    _InfoChip(
                      icon: mosque.isOpenNow!
                          ? Icons.check_circle
                          : Icons.cancel,
                      label: openLabel,
                      color: mosque.isOpenNow! ? primary : Colors.redAccent,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenMaps,
                icon: const Icon(Icons.navigation, size: 17),
                label: const Text('Buka Rute di Google Maps'),
              ),
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
