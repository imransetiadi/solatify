import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:solatify/core/database/hive_constants.dart';
import 'package:solatify/features/mosque/data/mosque_search_utils.dart';

/// Persists the last successful nearby-mosque search so results remain
/// available when public map servers are slow or unreachable.
class MosqueLocalDataSource {
  const MosqueLocalDataSource();

  static const _lastResultKey = 'last_result';

  /// Cached results are only reused when the user is still close to where
  /// they were fetched; otherwise the list would describe another area.
  static const maxReuseDistanceMeters = 3000.0;

  Future<void> saveLastResult({
    required double latitude,
    required double longitude,
    required List<MosqueItem> mosques,
  }) async {
    try {
      final box = await Hive.openBox<dynamic>(HiveConstants.mosqueCacheBox);
      await box.put(_lastResultKey, {
        'latitude': latitude,
        'longitude': longitude,
        'savedAt': DateTime.now().toIso8601String(),
        'mosques': mosques.map((mosque) => mosque.toJson()).toList(),
      });
    } catch (error) {
      // Caching is best-effort; a failed write must not break the search.
      debugPrint('Failed to persist mosque cache: $error');
    }
  }

  /// Returns cached mosques with distances recomputed from the given origin,
  /// or null when nothing usable is cached near that location.
  Future<List<MosqueItem>?> loadLastResultNear({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final box = await Hive.openBox<dynamic>(HiveConstants.mosqueCacheBox);
      final data = box.get(_lastResultKey);
      if (data is! Map) return null;

      final cachedLatitude = data['latitude'];
      final cachedLongitude = data['longitude'];
      final rawMosques = data['mosques'];
      if (cachedLatitude is! num ||
          cachedLongitude is! num ||
          rawMosques is! List) {
        return null;
      }

      final distanceFromCache = calculateMosqueDistance(
        latitude,
        longitude,
        cachedLatitude.toDouble(),
        cachedLongitude.toDouble(),
      );
      if (distanceFromCache > maxReuseDistanceMeters) return null;

      final mosques =
          rawMosques
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (json) => MosqueItem.fromJson(
                  json,
                  originLatitude: latitude,
                  originLongitude: longitude,
                ),
              )
              .whereType<MosqueItem>()
              .toList()
            ..sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
      return mosques.isEmpty ? null : mosques;
    } catch (error) {
      // A corrupt cache is treated as a cache miss; the network is the source
      // of truth.
      debugPrint('Failed to read mosque cache: $error');
      return null;
    }
  }
}
