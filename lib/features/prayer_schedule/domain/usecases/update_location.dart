import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class UpdateLocation {
  const UpdateLocation(this.repository);

  final LocationRepository repository;

  Future<LocationEntity> executeWithGPS() async {
    final location = await repository.getCurrentLocation();
    if (location != null) {
      await repository.cacheLocation(location);
      return location;
    }
    throw Exception('Gagal mendeteksi lokasi. Pastikan izin GPS aktif.');
  }

  Future<LocationEntity> executeWithManual(
    double lat,
    double lng,
    String city,
    String country,
  ) async {
    final location = LocationEntity(
      latitude: lat,
      longitude: lng,
      city: city,
      country: country,
    );
    await repository.cacheLocation(location);
    return location;
  }
}
