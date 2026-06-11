import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';

class MosqueItem {
  const MosqueItem({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceInMeters;
}

class NearbyMosqueScreen extends ConsumerWidget {
  const NearbyMosqueScreen({super.key});

  static const _mockMosques = [
    _MosqueSeed('Masjid Raya Agung', 'Jl. Utama No. 12', 0.0045, -0.0032),
    _MosqueSeed('Masjid Al-Ikhlas', 'Gang Masjid No. 5', -0.0021, 0.0051),
    _MosqueSeed('Masjid Baiturrahman', 'Jl. Kemuning Raya No. 45', 0.0075, 0.0068),
    _MosqueSeed('Masjid Al-Barokah', 'Jl. Merdeka Barat No. 8', -0.0062, -0.0058),
  ];

  List<MosqueItem> _buildMosques(double userLat, double userLng) {
    final mosques = _mockMosques.map((seed) {
      final mosqueLat = userLat + seed.latOffset;
      final mosqueLng = userLng + seed.lngOffset;
      return MosqueItem(
        name: seed.name,
        address: seed.address,
        latitude: mosqueLat,
        longitude: mosqueLng,
        distanceInMeters: _distanceInMeters(userLat, userLng, mosqueLat, mosqueLng),
      );
    }).toList();
    mosques.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
    return mosques;
  }

  double _distanceInMeters(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  Future<void> _openMaps(BuildContext context, MosqueItem mosque) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}',
    );

    final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.secondary;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final mutedColor = isDark ? Colors.white60 : const Color(0xFF6E5B4B);
    final backgroundColor = isDark ? const Color(0xFF082E1D) : const Color(0xFFF3FBF6);
    final cardColor = isDark ? const Color(0xFF123B29) : Colors.white;
    final mosques = _buildMosques(location.latitude, location.longitude);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text('Masjid Terdekat', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ResponsiveCenter(
          child: ListView(
            padding: ResponsiveLayout.pagePadding(context).copyWith(bottom: 96),
            children: [
              _LocationHeader(
                city: location.city,
                country: location.country,
                isLoading: location.isLoading,
                textColor: textColor,
                mutedColor: mutedColor,
                primary: primary,
                cardColor: cardColor,
                onRefresh: () => ref.read(locationProvider.notifier).updateLocationWithGPS(),
              ),
              const SizedBox(height: 16),
              Text(
                'Rekomendasi Masjid',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              for (final mosque in mosques)
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
                  Text('Lokasi Saat Ini', style: TextStyle(color: mutedColor, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(
                    '$city, $country',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Perbarui GPS',
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                    )
                  : Icon(Icons.my_location, color: primary),
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
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(distanceLabel, style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(mosque.address, style: TextStyle(color: mutedColor, fontSize: 13)),
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

class _MosqueSeed {
  const _MosqueSeed(this.name, this.address, this.latOffset, this.lngOffset);

  final String name;
  final String address;
  final double latOffset;
  final double lngOffset;
}
