import 'package:solatify/core/database/hive_service.dart';

abstract class LocationLocalDataSource {
  Future<Map<String, dynamic>?> getCachedLocation();
  Future<void> cacheLocation(Map<String, dynamic> locationData);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  const LocationLocalDataSourceImpl();

  @override
  Future<Map<String, dynamic>?> getCachedLocation() async {
    return HiveService.getCachedLocation();
  }

  @override
  Future<void> cacheLocation(Map<String, dynamic> locationData) async {
    await HiveService.cacheLocation(locationData);
  }
}
