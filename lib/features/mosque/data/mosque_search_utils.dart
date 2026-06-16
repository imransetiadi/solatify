import 'dart:math' as math;

class MosqueItem {
  const MosqueItem({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceInMeters,
    required this.sourceType,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceInMeters;
  final String sourceType;
}

enum MosqueMapPlatform { android, ios }

String buildMosqueOverpassQuery({
  required int radiusMeters,
  required double latitude,
  required double longitude,
}) {
  return '''
[out:json][timeout:12];
(
  node["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="mosque"](around:$radiusMeters,$latitude,$longitude);
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  relation["amenity"="place_of_worship"]["religion"="muslim"](around:$radiusMeters,$latitude,$longitude);
  node["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
  way["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
  relation["building"="mosque"](around:$radiusMeters,$latitude,$longitude);
);
out body center;
''';
}

List<MosqueItem> parseMosqueOverpassElements({
  required Map<String, dynamic> data,
  required double originLatitude,
  required double originLongitude,
}) {
  final elements = data['elements'];
  if (elements is! List) return const [];

  final results = <MosqueItem>[];
  final seenKeys = <String>{};

  for (final element in elements) {
    if (element is! Map<String, dynamic>) continue;

    final type = element['type']?.toString();
    final rawId = element['id']?.toString();
    if (rawId == null) continue;

    final stableKey = '${type ?? 'node'}:$rawId';
    if (!seenKeys.add(stableKey)) continue;

    final center = element['center'];
    final latitudeValue =
        element['lat'] ??
        (center is Map<String, dynamic> ? center['lat'] : null);
    final longitudeValue =
        element['lon'] ??
        (center is Map<String, dynamic> ? center['lon'] : null);

    if (latitudeValue is! num || longitudeValue is! num) continue;

    final latitude = latitudeValue.toDouble();
    final longitude = longitudeValue.toDouble();
    final tags = element['tags'];
    final name = tags is Map<String, dynamic>
        ? tags['name'] ?? tags['name:id'] ?? 'Masjid Tanpa Nama'
        : 'Masjid Tanpa Nama';
    final address = tags is Map<String, dynamic>
        ? tags['addr:full'] ??
              tags['addr:street'] ??
              tags['addr:place'] ??
              tags['addr:city'] ??
              'Alamat tidak diketahui'
        : 'Alamat tidak diketahui';

    results.add(
      MosqueItem(
        id: stableKey,
        name: name.toString(),
        address: address.toString(),
        latitude: latitude,
        longitude: longitude,
        distanceInMeters: calculateMosqueDistance(
          originLatitude,
          originLongitude,
          latitude,
          longitude,
        ),
        sourceType: type?.toUpperCase() ?? 'NODE',
      ),
    );
  }

  results.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
  return results;
}

double calculateMosqueDistance(
  double lat1,
  double lon1,
  double lat2,
  double lon2,
) {
  const earthRadiusMeters = 6371000.0;
  final phi1 = lat1 * math.pi / 180;
  final phi2 = lat2 * math.pi / 180;
  final deltaPhi = (lat2 - lat1) * math.pi / 180;
  final deltaLambda = (lon2 - lon1) * math.pi / 180;

  final a =
      math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
      math.cos(phi1) *
          math.cos(phi2) *
          math.sin(deltaLambda / 2) *
          math.sin(deltaLambda / 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusMeters * c;
}

String buildMosqueCacheKey({
  required double latitude,
  required double longitude,
  required int radiusMeters,
}) {
  return '${latitude.toStringAsFixed(4)}:${longitude.toStringAsFixed(4)}:$radiusMeters';
}

Uri buildMosqueMapUri({
  required double latitude,
  required double longitude,
  required MosqueMapPlatform platform,
}) {
  final query = '$latitude,$longitude';
  if (platform == MosqueMapPlatform.ios) {
    return Uri.https('maps.apple.com', '/', {'q': query});
  }

  return Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
}

Uri buildMosqueRouteUri({
  required double latitude,
  required double longitude,
  required MosqueMapPlatform platform,
}) {
  final destination = '$latitude,$longitude';
  if (platform == MosqueMapPlatform.ios) {
    return Uri.https('maps.apple.com', '/', {'daddr': destination});
  }

  return Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': destination,
  });
}
