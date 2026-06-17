import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solatify/core/utils/location_service.dart';
import 'package:solatify/features/prayer_schedule/data/datasources/location_local_data_source.dart';
import 'package:solatify/features/prayer_schedule/data/repositories/location_repository_impl.dart';
import 'package:solatify/features/prayer_schedule/domain/entities/location_entity.dart';
import 'package:solatify/features/prayer_schedule/domain/repositories/location_repository.dart';
import 'package:solatify/features/prayer_schedule/domain/usecases/update_location.dart';

final locationLocalDataSourceProvider = Provider<LocationLocalDataSource>((
  ref,
) {
  return const LocationLocalDataSourceImpl();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final localDataSource = ref.watch(locationLocalDataSourceProvider);
  return LocationRepositoryImpl(localDataSource: localDataSource);
});

final updateLocationUseCaseProvider = Provider<UpdateLocation>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return UpdateLocation(repository);
});

class LocationNotifier extends StateNotifier<LocationEntity> {
  LocationNotifier(this._repository, this._updateLocation)
    : super(
        const LocationEntity(
          latitude: -6.2088,
          longitude: 106.8456,
          city: 'Jakarta',
          country: 'Indonesia',
          isLoading: true,
        ),
      ) {
    _init();
  }

  final LocationRepository _repository;
  final UpdateLocation _updateLocation;

  Future<void> _init() async {
    final cached = await _repository.getCachedLocation();
    state = cached;
  }

  Future<bool> updateLocationWithGPS() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newLocation = await _updateLocation.executeWithGPS();
      state = newLocation.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> setManualCity(OfflineCity city) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newLocation = await _updateLocation.executeWithManual(
        city.latitude,
        city.longitude,
        city.name,
        city.country,
      );
      state = newLocation.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal menyimpan lokasi manual.',
      );
    }
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationEntity>((ref) {
      final repository = ref.watch(locationRepositoryProvider);
      final updateLocation = ref.watch(updateLocationUseCaseProvider);
      return LocationNotifier(repository, updateLocation);
    });
