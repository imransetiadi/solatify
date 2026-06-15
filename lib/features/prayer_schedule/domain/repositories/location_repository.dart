import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<LocationEntity> getCachedLocation();
  Future<void> cacheLocation(LocationEntity location);
  Future<LocationEntity?> getCurrentLocation();
}
