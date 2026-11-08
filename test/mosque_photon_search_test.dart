import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solatify/features/mosque/data/mosque_remote_data_source.dart';
import 'package:solatify/features/mosque/data/mosque_search_utils.dart';

const _originLat = -6.2088;
const _originLon = 106.8456;

Map<String, dynamic> _feature({
  required int id,
  required String name,
  required double lat,
  required double lon,
  String osmType = 'N',
  Map<String, dynamic> extra = const {},
}) => {
  'type': 'Feature',
  'properties': {
    'osm_type': osmType,
    'osm_id': id,
    'osm_key': 'amenity',
    'osm_value': 'place_of_worship',
    'name': name,
    ...extra,
  },
  'geometry': {
    'type': 'Point',
    'coordinates': [lon, lat],
  },
};

Map<String, dynamic> _collection(List<Map<String, dynamic>> features) => {
  'type': 'FeatureCollection',
  'features': features,
};

void main() {
  group('isLikelyMosqueName', () {
    test('accepts common mosque and prayer-room names', () {
      for (final name in [
        'Masjid Istiqlal',
        'Musholla Al-Ikhlas',
        'Mushola Nurul Huda',
        'Mushala Khusnul Khatimah',
        'Musala Polsek',
        'Surau Al-Hidayah',
        'Langgar Kidul',
        'Meunasah Gampong',
        'East London Mosque',
        "Jami' Al-Ismai'liyyah",
        'Al-Ikhlas',
        'Baitul Makmur',
        'مسجد النور',
      ]) {
        expect(isLikelyMosqueName(name), isTrue, reason: name);
      }
    });

    test('rejects other places of worship and empty names', () {
      for (final name in [
        '',
        '   ',
        'Gereja Katolik Santo Yusuf',
        'Gereja Isa Almasih',
        'Kuil Hoseiji',
        'Pura Dalem',
        'Vihara Bodhicitta Maitreya',
        'Klenteng Fuk Ling Miau',
        'Sri Krishna Temple',
        'GKI Ngupasan',
        'HKBP Yogyakarta',
        'Zion Cathedral',
      ]) {
        expect(isLikelyMosqueName(name), isFalse, reason: name);
      }
    });
  });

  test('buildPhotonMosqueUris builds a reverse lookup plus text searches', () {
    final uris = buildPhotonMosqueUris(
      latitude: _originLat,
      longitude: _originLon,
      radiusMeters: 5000,
    );

    expect(uris, hasLength(1 + photonMosqueTextQueries.length));
    expect(uris.every((uri) => uri.host == photonHost), isTrue);

    final reverse = uris.first;
    expect(reverse.path, '/reverse');
    expect(reverse.queryParameters['radius'], '5.0');
    expect(reverse.queryParameters['osm_tag'], 'amenity:place_of_worship');

    final text = uris.skip(1).toList();
    expect(
      text.map((uri) => uri.queryParameters['q']),
      photonMosqueTextQueries,
    );
    for (final uri in text) {
      final bbox = uri.queryParameters['bbox']!.split(',').map(double.parse);
      final [minLon, minLat, maxLon, maxLat] = bbox.toList();
      expect(minLon, lessThan(_originLon));
      expect(maxLon, greaterThan(_originLon));
      expect(minLat, lessThan(_originLat));
      expect(maxLat, greaterThan(_originLat));
    }
  });

  test('parsePhotonMosqueFeatures merges, filters, dedupes and sorts', () {
    final mosques = parsePhotonMosqueFeatures(
      responses: [
        _collection([
          _feature(
            id: 2,
            osmType: 'W',
            name: 'Masjid Far',
            lat: -6.22,
            lon: 106.85,
          ),
          _feature(id: 3, name: 'Gereja Near', lat: -6.2089, lon: 106.8457),
          _feature(
            id: 1,
            name: 'Masjid Near',
            lat: -6.2089,
            lon: 106.8457,
            extra: {
              'street': 'Jalan Menteng',
              'housenumber': '5',
              'district': 'Setiabudi',
              'city': 'DKI Jakarta',
            },
          ),
        ]),
        _collection([
          // Same mosque from the text search: kept once.
          _feature(
            id: 2,
            osmType: 'W',
            name: 'Masjid Far',
            lat: -6.22,
            lon: 106.85,
          ),
          // Inside the bbox corner but beyond the radius.
          _feature(id: 4, name: 'Masjid Corner', lat: -6.25, lon: 106.89),
        ]),
      ],
      originLatitude: _originLat,
      originLongitude: _originLon,
      radiusMeters: 5000,
    );

    expect(mosques.map((m) => m.name), ['Masjid Near', 'Masjid Far']);
    expect(mosques.first.id, 'node:1');
    expect(mosques.first.address, 'Jalan Menteng 5, Setiabudi, DKI Jakarta');
    expect(mosques.last.id, 'way:2');
    expect(mosques.last.sourceType, 'WAY');
    expect(mosques.last.address, unknownMosqueAddressLabel);
  });

  group('MosqueRemoteDataSource', () {
    test('returns Photon results without touching Overpass', () async {
      var overpassCalls = 0;
      final client = MockClient((request) async {
        if (request.url.host == photonHost) {
          return http.Response(
            jsonEncode(
              _collection([
                _feature(id: 1, name: 'Masjid A', lat: -6.209, lon: 106.846),
              ]),
            ),
            200,
          );
        }
        overpassCalls++;
        return http.Response('{"elements": []}', 200);
      });

      final mosques = await MosqueRemoteDataSource(
        client: client,
      ).searchNearby(latitude: _originLat, longitude: _originLon);

      expect(mosques.single.name, 'Masjid A');
      expect(overpassCalls, 0);
    });

    test('keeps partial Photon results when one request fails', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/reverse') {
          return http.Response('busy', 503);
        }
        return http.Response(
          jsonEncode(
            _collection([
              _feature(id: 1, name: 'Masjid A', lat: -6.209, lon: 106.846),
            ]),
          ),
          200,
        );
      });

      final mosques = await MosqueRemoteDataSource(
        client: client,
      ).searchNearby(latitude: _originLat, longitude: _originLon);

      expect(mosques.single.id, 'node:1');
    });

    test('falls back to Overpass when Photon is down', () async {
      final client = MockClient((request) async {
        if (request.url.host == photonHost) {
          return http.Response('down', 503);
        }
        return http.Response(
          jsonEncode({
            'elements': [
              {
                'type': 'node',
                'id': 9,
                'lat': -6.209,
                'lon': 106.846,
                'tags': {'name': 'Masjid Overpass'},
              },
            ],
          }),
          200,
        );
      });

      final mosques = await MosqueRemoteDataSource(
        client: client,
      ).searchNearby(latitude: _originLat, longitude: _originLon);

      expect(mosques.single.name, 'Masjid Overpass');
    });

    test('throws when every source fails', () async {
      final client = MockClient((_) async => http.Response('down', 503));

      await expectLater(
        MosqueRemoteDataSource(
          client: client,
        ).searchNearby(latitude: _originLat, longitude: _originLon),
        throwsA(anything),
      );
    });
  });
}
