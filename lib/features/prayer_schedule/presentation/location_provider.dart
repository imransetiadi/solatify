import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/utils/location_service.dart';

class LocationState {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final bool isLoading;
  final String? errorMessage;

  LocationState({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(_initialState());

  static LocationState _initialState() {
    final cached = HiveService.getCachedLocation();
    if (cached != null) {
      return LocationState(
        latitude: cached['latitude'] as double,
        longitude: cached['longitude'] as double,
        city: cached['city'] as String,
        country: cached['country'] as String,
      );
    }
    // Default to Jakarta
    return LocationState(
      latitude: -6.2088,
      longitude: 106.8456,
      city: 'Jakarta',
      country: 'Indonesia',
    );
  }

  Future<bool> updateLocationWithGPS() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pos = await LocationService.getCurrentPosition();
      if (pos != null) {
        final details = await LocationService.getCityCountry(
          pos.latitude,
          pos.longitude,
        );
        final newState = LocationState(
          latitude: pos.latitude,
          longitude: pos.longitude,
          city: details['city'] ?? 'Unknown City',
          country: details['country'] ?? 'Unknown Country',
          isLoading: false,
        );
        await _saveCache(newState);
        state = newState;
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal mendeteksi lokasi. Pastikan izin GPS aktif.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan saat mendeteksi lokasi: $e',
      );
      return false;
    }
  }

  Future<void> setManualCity(OfflineCity city) async {
    final newState = LocationState(
      latitude: city.latitude,
      longitude: city.longitude,
      city: city.name,
      country: city.country,
      isLoading: false,
    );
    await _saveCache(newState);
    state = newState;
  }

  Future<void> _saveCache(LocationState s) async {
    await HiveService.cacheLocation({
      'latitude': s.latitude,
      'longitude': s.longitude,
      'city': s.city,
      'country': s.country,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);
