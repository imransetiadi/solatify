import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../prayer_schedule/presentation/location_provider.dart';

class MosqueItem {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceInMeters;

  MosqueItem({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
  });
}

class NearbyMosqueScreen extends ConsumerStatefulWidget {
  const NearbyMosqueScreen({super.key});

  @override
  ConsumerState<NearbyMosqueScreen> createState() => _NearbyMosqueScreenState();
}

class _NearbyMosqueScreenState extends ConsumerState<NearbyMosqueScreen> {
  // Generate realistic mock mosques nearby based on user coordinates
  List<MosqueItem> _getNearbyMosques(double userLat, double userLng) {
    final List<Map<String, dynamic>> mockData = [
      {
        'name': 'Masjid Raya Agung',
        'address': 'Jl. Utama No. 12',
        'latOffset': 0.0045,
        'lngOffset': -0.0032,
      },
      {
        'name': 'Masjid Al-Ikhlas',
        'address': 'Gang Masjid No. 5',
        'latOffset': -0.0021,
        'lngOffset': 0.0051,
      },
      {
        'name': 'Masjid Baiturrahman',
        'address': 'Jl. Kemuning Raya No. 45',
        'latOffset': 0.0075,
        'lngOffset': 0.0068,
      },
      {
        'name': 'Masjid Al-Barokah',
        'address': 'Jl. Merdeka Barat No. 8',
        'latOffset': -0.0062,
        'lngOffset': -0.0058,
      },
    ];

    return mockData.map((data) {
        final mosqueLat = userLat + (data['latOffset'] as double);
        final mosqueLng = userLng + (data['lngOffset'] as double);

        final distance = Geolocator.distanceBetween(
          userLat,
          userLng,
          mosqueLat,
          mosqueLng,
        );

        return MosqueItem(
          name: data['name'] as String,
          address: data['address'] as String,
          latitude: mosqueLat,
          longitude: mosqueLng,
          distanceInMeters: distance,
        );
      }).toList()
      ..sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
  }

  Future<void> _navigateToMosque(MosqueItem mosque) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka peta: $e'),
            backgroundColor: const Color(0xFF241A12),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);
    final userPosition = LatLng(location.latitude, location.longitude);
    final mosques = _getNearbyMosques(location.latitude, location.longitude);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF241A12);
    final textSecondary = isDark ? Colors.white60 : const Color(0xFF7A6A5D);

    // Create markers for Google Maps
    final Set<Marker> markers = {
      // User Location Marker
      Marker(
        markerId: const MarkerId('user_location'),
        position: userPosition,
        infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ),
      // Mosque Markers
      ...mosques.map((mosque) {
        return Marker(
          markerId: MarkerId(mosque.name),
          position: LatLng(mosque.latitude, mosque.longitude),
          infoWindow: InfoWindow(
            title: mosque.name,
            snippet:
                '${(mosque.distanceInMeters / 1000).toStringAsFixed(1)} km',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        );
      }),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Masjid Terdekat')),
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              // Google Map Section (Half Screen)
              Expanded(
                flex: 4,
                child: Container(
                  margin: ResponsiveLayout.pagePadding(
                    context,
                  ).copyWith(top: 8, bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: kIsWeb
                        ? _buildWebMockMap(userPosition, mosques)
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: userPosition,
                              zoom: 14.5,
                            ),
                            markers: markers,
                            myLocationEnabled:
                                false, // We supply custom marker to prevent prompt overlaps
                            zoomControlsEnabled: false,
                            mapType: MapType.normal,
                            onMapCreated: (controller) {
                              // Apply dark theme style to map if desired
                            },
                          ),
                  ),
                ),
              ),

              // Mosque List Section
              Expanded(
                flex: 5,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        ResponsiveLayout.pagePadding(context).horizontal / 2,
                  ),
                  itemCount: mosques.length,
                  itemBuilder: (context, index) {
                    final mosque = mosques[index];
                    final distanceKm = mosque.distanceInMeters / 1000;
                    final distanceLabel = distanceKm < 1.0
                        ? '${mosque.distanceInMeters.round()} m'
                        : '${distanceKm.toStringAsFixed(1)} km';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        blur: 10,
                        opacity: isDark ? 0.02 : 0.01,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mosque.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mosque.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_walk,
                                        size: 12,
                                        color: Color(0xFF0E4D31),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        distanceLabel,
                                        style: const TextStyle(
                                          color: Color(0xFF0E4D31),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Nav Button
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF241A12,
                                ), // Black
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.navigation, size: 14),
                              label: const Text(
                                'Rute',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () => _navigateToMosque(mosque),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildWebMockMap(LatLng userPosition, List<MosqueItem> mosques) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;

        return Container(
          color: isDark ? const Color(0xFF180F0A) : const Color(0xFFF3E8DC),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Concentric radar circles
              ...List.generate(3, (index) {
                final radius = (index + 1) * 60.0;
                return Positioned(
                  left: centerX - radius,
                  top: centerY - radius,
                  child: IgnorePointer(
                    child: Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF0E4D31).withValues(alpha: 0.1),
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Grid lines
              Positioned(
                left: 0,
                right: 0,
                top: centerY,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    color: Color(0xFF0E4D31).withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                left: centerX,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    width: 1,
                    color: Color(0xFF0E4D31).withValues(alpha: 0.08),
                  ),
                ),
              ),

              // User marker in center
              Positioned(
                left: centerX - 40,
                top: centerY - 35,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFF0E4D31).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFF0E4D31), width: 2),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Color(0xFF0E4D31).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'Anda',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Mosque pins
              ...mosques.map((mosque) {
                final latOffset = mosque.latitude - userPosition.latitude;
                final lngOffset = mosque.longitude - userPosition.longitude;

                // Scale factor for offsets to fit in the container (e.g. 18000 scale)
                final dx = lngOffset * 18000;
                final dy = -latOffset * 18000; // y-axis is inverted

                return Positioned(
                  left: centerX + dx - 35,
                  top: centerY + dy - 30,
                  child: Tooltip(
                    message:
                        '${mosque.name}\n${(mosque.distanceInMeters / 1000).toStringAsFixed(1)} km',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place,
                          color: Color(0xFF241A12), // Black
                          size: 20,
                        ),
                        const SizedBox(height: 1),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Color(0xFF241A12).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            mosque.name.replaceAll('Masjid ', ''), // Short name
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Web overlay notification banner
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFF241A12).withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF241A12),
                          size: 12,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Web Map Preview (Gunakan Android/iOS untuk Google Maps)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
