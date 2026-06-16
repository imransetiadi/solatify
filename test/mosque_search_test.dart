import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:solatify/features/mosque/presentation/screens/nearby_mosque_screen.dart';

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
}
