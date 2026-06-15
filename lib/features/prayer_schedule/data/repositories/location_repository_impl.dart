import 'package:flutter/foundation.dart';
import 'package:solatify/core/utils/location_service.dart';

import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({required this.localDataSource});

  final LocationLocalDataSource localDataSource;

  @override
  Future<LocationEntity> getCachedLocation() async {
    try {
      final cached = await localDataSource.getCachedLocation();
      if (cached != null && cached.isNotEmpty) {
        return LocationEntity(
          latitude: (cached['latitude'] as num?)?.toDouble() ?? -6.2088,
          longitude: (cached['longitude'] as num?)?.toDouble() ?? 106.8456,
          city: cached['city']?.toString() ?? 'Jakarta',
          country: cached['country']?.toString() ?? 'Indonesia',
        );
      }
    } catch (e) {
      debugPrint('Error accessing cached location: $e');
    }
    return const LocationEntity(
      latitude: -6.2088,
      longitude: 106.8456,
      city: 'Jakarta',
      country: 'Indonesia',
    );
  }

  @override
  Future<void> cacheLocation(LocationEntity location) async {
    await localDataSource.cacheLocation({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'city': location.city,
      'country': location.country,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<LocationEntity?> getCurrentLocation() async {
    final pos = await LocationService.getCurrentPosition().timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw 'GPS Timeout: Lokasi gagal dideteksi dalam 15 detik.',
    );

    if (pos != null) {
      final details = await LocationService.getCityCountry(
        pos.latitude,
        pos.longitude,
      );
      return LocationEntity(
        latitude: pos.latitude,
        longitude: pos.longitude,
        city: details['city'] ?? 'Unknown City',
        country: details['country'] ?? 'Unknown Country',
      );
    }
    return null;
  }
}
