import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/mosque/data/mosque_search_utils.dart';

void main() {
  test(
    'buildMosqueOverpassQuery uses valid output syntax and broad mosque tags',
    () {
      final query = buildMosqueOverpassQuery(
        radiusMeters: 5000,
        latitude: -6.2088,
        longitude: 106.8456,
      );

      expect(query, contains('out body center;'));
      expect(query, isNot(contains('out center tags')));
      expect(query, contains('["amenity"="mosque"]'));
      expect(
        query,
        contains('["amenity"="place_of_worship"]["religion"="muslim"]'),
      );
      expect(query, contains('["building"="mosque"]'));
    },
  );

  test('parseMosqueOverpassElements accepts way center coordinates', () {
    final decoded =
        jsonDecode('''
{
  "elements": [
    {
      "type": "way",
      "id": 123,
      "center": {"lat": -6.2, "lon": 106.8},
      "tags": {
        "name": "Masjid Test",
        "addr:place": "Jakarta"
      }
    }
  ]
}
''')
            as Map<String, dynamic>;

    final mosques = parseMosqueOverpassElements(
      data: decoded,
      originLatitude: -6.2088,
      originLongitude: 106.8456,
    );

    expect(mosques, hasLength(1));
    expect(mosques.single.name, 'Masjid Test');
    expect(mosques.single.address, 'Jakarta');
    expect(mosques.single.sourceType, 'WAY');
  });

  test('parseMosqueOverpassElements deduplicates and sorts by distance', () {
    final decoded =
        jsonDecode('''
{
  "elements": [
    {
      "type": "node",
      "id": 1,
      "lat": -6.20,
      "lon": 106.80,
      "tags": {"name": "Far Mosque"}
    },
    {
      "type": "node",
      "id": 2,
      "lat": -6.2087,
      "lon": 106.8455,
      "tags": {"name": "Near Mosque"}
    },
    {
      "type": "node",
      "id": 2,
      "lat": -6.2087,
      "lon": 106.8455,
      "tags": {"name": "Duplicate Mosque"}
    }
  ]
}
''')
            as Map<String, dynamic>;

    final mosques = parseMosqueOverpassElements(
      data: decoded,
      originLatitude: -6.2088,
      originLongitude: 106.8456,
    );

    expect(mosques, hasLength(2));
    expect(mosques.first.name, 'Near Mosque');
    expect(mosques.last.name, 'Far Mosque');
  });

  test('buildMosqueCacheKey rounds coordinates to stable precision', () {
    expect(
      buildMosqueCacheKey(
        latitude: -6.2088123,
        longitude: 106.8456123,
        radiusMeters: 5000,
      ),
      buildMosqueCacheKey(
        latitude: -6.2088499,
        longitude: 106.8456499,
        radiusMeters: 5000,
      ),
    );
  });

  test('buildMosqueMapUri uses Google Maps for iOS', () {
    final uri = buildMosqueMapUri(
      latitude: -6.2,
      longitude: 106.8,
      platform: MosqueMapPlatform.ios,
    );

    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/search/');
    expect(uri.queryParameters['query'], '-6.2,106.8');
  });

  test('buildMosqueRouteUri uses Google Maps for iOS', () {
    final uri = buildMosqueRouteUri(
      latitude: -6.2,
      longitude: 106.8,
      platform: MosqueMapPlatform.ios,
    );

    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['destination'], '-6.2,106.8');
  });

  test('buildMosqueRouteUri uses Google Maps destination for Android', () {
    final uri = buildMosqueRouteUri(
      latitude: -6.2,
      longitude: 106.8,
      platform: MosqueMapPlatform.android,
    );

    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['destination'], '-6.2,106.8');
  });
}
