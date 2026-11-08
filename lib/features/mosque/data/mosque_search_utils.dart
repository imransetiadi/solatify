import 'dart:math' as math;

/// Stored when OpenStreetMap has no name/address (also in cached results);
/// translated when shown, see [displayMosqueName].
const unnamedMosqueLabel = 'Masjid Tanpa Nama';
const unknownMosqueAddressLabel = 'Alamat tidak diketahui';

String displayMosqueName(String name, {required bool isEnglish}) =>
    isEnglish && name == unnamedMosqueLabel ? 'Unnamed mosque' : name;

String displayMosqueAddress(String address, {required bool isEnglish}) =>
    isEnglish && address == unknownMosqueAddressLabel
    ? 'Address unknown'
    : address;

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

  /// Returns a copy with the distance recomputed from a new origin.
  MosqueItem withDistanceFrom(double originLatitude, double originLongitude) {
    return MosqueItem(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      distanceInMeters: calculateMosqueDistance(
        originLatitude,
        originLongitude,
        latitude,
        longitude,
      ),
      sourceType: sourceType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'sourceType': sourceType,
  };

  /// Returns null when the stored map is malformed.
  static MosqueItem? fromJson(
    Map<dynamic, dynamic> json, {
    required double originLatitude,
    required double originLongitude,
  }) {
    final id = json['id'];
    final name = json['name'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    if (id is! String || name is! String) return null;
    if (latitude is! num || longitude is! num) return null;

    return MosqueItem(
      id: id,
      name: name,
      address: json['address']?.toString() ?? unknownMosqueAddressLabel,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      distanceInMeters: calculateMosqueDistance(
        originLatitude,
        originLongitude,
        latitude.toDouble(),
        longitude.toDouble(),
      ),
      sourceType: json['sourceType']?.toString() ?? 'NODE',
    );
  }
}

enum MosqueMapPlatform { android, ios }

String buildMosqueOverpassQuery({
  required int radiusMeters,
  required double latitude,
  required double longitude,
}) {
  // Public Overpass servers are often slow under load; give the server enough
  // time to answer instead of aborting the query early.
  return '''
[out:json][timeout:25];
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
        ? tags['name'] ?? tags['name:id'] ?? unnamedMosqueLabel
        : unnamedMosqueLabel;
    final address = tags is Map<String, dynamic>
        ? tags['addr:full'] ??
              tags['addr:street'] ??
              tags['addr:place'] ??
              tags['addr:city'] ??
              unknownMosqueAddressLabel
        : unknownMosqueAddressLabel;

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

/// Photon (komoot) public geocoder: answers in about a second, whereas the
/// public Overpass servers regularly need 30s+ or time out.
const photonHost = 'photon.komoot.io';

/// Photon caps every request at 50 results.
const photonResultLimit = 50;

/// Free-text searches that run next to the nearest-places-of-worship lookup.
/// That lookup alone returns only the 50 nearest places of worship of any
/// religion, which in mixed areas (Bali, Manado, Kuala Lumpur, Singapore)
/// leaves just a handful of mosques. Kept to two so a search stays at three
/// requests, under Photon's fair-use throttling.
const photonMosqueTextQueries = ['masjid', 'mosque'];

/// Requests that together cover the mosques around a point.
List<Uri> buildPhotonMosqueUris({
  required double latitude,
  required double longitude,
  required int radiusMeters,
}) {
  const osmTag = 'amenity:place_of_worship';
  final latDelta = radiusMeters / 111320;
  final lonDelta =
      radiusMeters /
      (111320 * math.max(math.cos(latitude * math.pi / 180).abs(), 0.01));
  final bbox = [
    longitude - lonDelta,
    latitude - latDelta,
    longitude + lonDelta,
    latitude + latDelta,
  ].map((value) => value.toStringAsFixed(6)).join(',');

  return [
    Uri.https(photonHost, '/reverse', {
      'lat': '$latitude',
      'lon': '$longitude',
      'radius': '${radiusMeters / 1000}',
      'limit': '$photonResultLimit',
      'osm_tag': osmTag,
    }),
    for (final query in photonMosqueTextQueries)
      Uri.https(photonHost, '/api/', {
        'q': query,
        'lat': '$latitude',
        'lon': '$longitude',
        'bbox': bbox,
        'limit': '$photonResultLimit',
        'osm_tag': osmTag,
      }),
  ];
}

final _mosqueNamePattern = RegExp(
  r'masjid|masjed|masjib|mesjid|mesigit|mosque|mosquée|moschee|camii|'
  r'mush?oll?ah?|mush?all?a|mus[oa]ll?a|surau|langgar|meunasah|jami|'
  r'islamic|مسجد|جامع|مصلى|'
  r"^(al|an|ar|as|asy|at|ad|az|ash|baitul|baitur|baiturr|nurul|darul|darus)[\s\-']",
  caseSensitive: false,
);

final _otherWorshipPattern = RegExp(
  r'gereja|church|chapel|kapel|cathedral|katedral|vihara|wihara|klenteng|'
  r'kelenteng|kuil|temple|tokong|kovil|alayam|gurdwara|synagogue|sinagoga|'
  r'\bpura\b|\bhkbp\b|\bgki\b|\bgpib\b|\bgbi\b|\bgmim\b|\bgkj\b',
  caseSensitive: false,
);

/// Photon has no religion tag, so mosques are told apart from other places
/// of worship by name. Unnamed places are dropped: they cannot be checked.
bool isLikelyMosqueName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return false;
  if (_otherWorshipPattern.hasMatch(trimmed)) return false;
  return _mosqueNamePattern.hasMatch(trimmed);
}

String _photonOsmType(Object? type) {
  switch (type?.toString().toUpperCase()) {
    case 'W':
      return 'way';
    case 'R':
      return 'relation';
    default:
      return 'node';
  }
}

/// Merges Photon GeoJSON responses into mosques within [radiusMeters],
/// nearest first. IDs use the Overpass `type:id` format so cached results
/// from either source line up.
List<MosqueItem> parsePhotonMosqueFeatures({
  required List<Map<String, dynamic>> responses,
  required double originLatitude,
  required double originLongitude,
  required int radiusMeters,
}) {
  final results = <MosqueItem>[];
  final seenKeys = <String>{};

  for (final response in responses) {
    final features = response['features'];
    if (features is! List) continue;

    for (final feature in features) {
      if (feature is! Map<String, dynamic>) continue;
      final properties = feature['properties'];
      final geometry = feature['geometry'];
      if (properties is! Map<String, dynamic>) continue;
      if (geometry is! Map<String, dynamic>) continue;

      final rawId = properties['osm_id']?.toString();
      final name = properties['name']?.toString() ?? '';
      if (rawId == null || !isLikelyMosqueName(name)) continue;

      final coordinates = geometry['coordinates'];
      if (coordinates is! List || coordinates.length < 2) continue;
      final longitudeValue = coordinates[0];
      final latitudeValue = coordinates[1];
      if (latitudeValue is! num || longitudeValue is! num) continue;

      final type = _photonOsmType(properties['osm_type']);
      final stableKey = '$type:$rawId';
      if (!seenKeys.add(stableKey)) continue;

      final latitude = latitudeValue.toDouble();
      final longitude = longitudeValue.toDouble();
      final distance = calculateMosqueDistance(
        originLatitude,
        originLongitude,
        latitude,
        longitude,
      );
      if (distance > radiusMeters) continue;

      results.add(
        MosqueItem(
          id: stableKey,
          name: name.trim(),
          address: _photonAddress(properties),
          latitude: latitude,
          longitude: longitude,
          distanceInMeters: distance,
          sourceType: type.toUpperCase(),
        ),
      );
    }
  }

  results.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));
  return results;
}

String _photonAddress(Map<String, dynamic> properties) {
  String? field(String key) {
    final value = properties[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  final street = field('street');
  final houseNumber = field('housenumber');
  final parts = <String>[
    if (street != null) houseNumber != null ? '$street $houseNumber' : street,
    ?field('district'),
    ?field('city'),
  ];
  // Drop repeats such as district == city.
  final unique = <String>[];
  for (final part in parts) {
    if (!unique.contains(part)) unique.add(part);
  }
  return unique.isEmpty ? unknownMosqueAddressLabel : unique.join(', ');
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
  switch (platform) {
    case MosqueMapPlatform.android:
    case MosqueMapPlatform.ios:
      return Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': query,
      });
  }
}

Uri buildMosqueRouteUri({
  required double latitude,
  required double longitude,
  required MosqueMapPlatform platform,
}) {
  final destination = '$latitude,$longitude';
  switch (platform) {
    case MosqueMapPlatform.android:
    case MosqueMapPlatform.ios:
      return Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': destination,
      });
  }
}
