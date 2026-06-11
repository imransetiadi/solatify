import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class OfflineCity {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const OfflineCity({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
}

class LocationService {
  // Offline fallback cities covering all Indonesian provinces plus a few global references.
  static const List<OfflineCity> defaultCities = [
    OfflineCity(
      name: 'Banda Aceh',
      country: 'Aceh, Indonesia',
      latitude: 5.5483,
      longitude: 95.3238,
    ),
    OfflineCity(
      name: 'Langsa',
      country: 'Aceh, Indonesia',
      latitude: 4.4683,
      longitude: 97.9683,
    ),
    OfflineCity(
      name: 'Lhokseumawe',
      country: 'Aceh, Indonesia',
      latitude: 5.1801,
      longitude: 97.1507,
    ),
    OfflineCity(
      name: 'Medan',
      country: 'Sumatera Utara, Indonesia',
      latitude: 3.5952,
      longitude: 98.6722,
    ),
    OfflineCity(
      name: 'Binjai',
      country: 'Sumatera Utara, Indonesia',
      latitude: 3.6001,
      longitude: 98.4854,
    ),
    OfflineCity(
      name: 'Pematangsiantar',
      country: 'Sumatera Utara, Indonesia',
      latitude: 2.9595,
      longitude: 99.0687,
    ),
    OfflineCity(
      name: 'Padang',
      country: 'Sumatera Barat, Indonesia',
      latitude: -0.9471,
      longitude: 100.4172,
    ),
    OfflineCity(
      name: 'Bukittinggi',
      country: 'Sumatera Barat, Indonesia',
      latitude: -0.3056,
      longitude: 100.3692,
    ),
    OfflineCity(
      name: 'Pekanbaru',
      country: 'Riau, Indonesia',
      latitude: 0.5071,
      longitude: 101.4478,
    ),
    OfflineCity(
      name: 'Dumai',
      country: 'Riau, Indonesia',
      latitude: 1.6666,
      longitude: 101.4002,
    ),
    OfflineCity(
      name: 'Tanjung Pinang',
      country: 'Kepulauan Riau, Indonesia',
      latitude: 0.9186,
      longitude: 104.4665,
    ),
    OfflineCity(
      name: 'Batam',
      country: 'Kepulauan Riau, Indonesia',
      latitude: 1.1301,
      longitude: 104.0529,
    ),
    OfflineCity(
      name: 'Jambi',
      country: 'Jambi, Indonesia',
      latitude: -1.6101,
      longitude: 103.6131,
    ),
    OfflineCity(
      name: 'Palembang',
      country: 'Sumatera Selatan, Indonesia',
      latitude: -2.9761,
      longitude: 104.7754,
    ),
    OfflineCity(
      name: 'Lubuklinggau',
      country: 'Sumatera Selatan, Indonesia',
      latitude: -3.2967,
      longitude: 102.8610,
    ),
    OfflineCity(
      name: 'Bengkulu',
      country: 'Bengkulu, Indonesia',
      latitude: -3.7928,
      longitude: 102.2608,
    ),
    OfflineCity(
      name: 'Bandar Lampung',
      country: 'Lampung, Indonesia',
      latitude: -5.3971,
      longitude: 105.2668,
    ),
    OfflineCity(
      name: 'Metro',
      country: 'Lampung, Indonesia',
      latitude: -5.1131,
      longitude: 105.3067,
    ),
    OfflineCity(
      name: 'Pangkalpinang',
      country: 'Kepulauan Bangka Belitung, Indonesia',
      latitude: -2.1316,
      longitude: 106.1169,
    ),
    OfflineCity(
      name: 'Jakarta',
      country: 'DKI Jakarta, Indonesia',
      latitude: -6.2088,
      longitude: 106.8456,
    ),
    OfflineCity(
      name: 'Jakarta Selatan',
      country: 'DKI Jakarta, Indonesia',
      latitude: -6.2615,
      longitude: 106.8106,
    ),
    OfflineCity(
      name: 'Jakarta Barat',
      country: 'DKI Jakarta, Indonesia',
      latitude: -6.1683,
      longitude: 106.7588,
    ),
    OfflineCity(
      name: 'Bandung',
      country: 'Jawa Barat, Indonesia',
      latitude: -6.9175,
      longitude: 107.6191,
    ),
    OfflineCity(
      name: 'Bekasi',
      country: 'Jawa Barat, Indonesia',
      latitude: -6.2383,
      longitude: 106.9756,
    ),
    OfflineCity(
      name: 'Bogor',
      country: 'Jawa Barat, Indonesia',
      latitude: -6.5956,
      longitude: 106.7892,
    ),
    OfflineCity(
      name: 'Depok',
      country: 'Jawa Barat, Indonesia',
      latitude: -6.4025,
      longitude: 106.7942,
    ),
    OfflineCity(
      name: 'Cimahi',
      country: 'Jawa Barat, Indonesia',
      latitude: -6.8722,
      longitude: 107.5425,
    ),
    OfflineCity(
      name: 'Cirebon',
      country: 'Jawa Barat, Indonesia',
      latitude: -6.7320,
      longitude: 108.5523,
    ),
    OfflineCity(
      name: 'Tasikmalaya',
      country: 'Jawa Barat, Indonesia',
      latitude: -7.3506,
      longitude: 108.2172,
    ),
    OfflineCity(
      name: 'Serang',
      country: 'Banten, Indonesia',
      latitude: -6.1200,
      longitude: 106.1503,
    ),
    OfflineCity(
      name: 'Tangerang',
      country: 'Banten, Indonesia',
      latitude: -6.1783,
      longitude: 106.6300,
    ),
    OfflineCity(
      name: 'Tangerang Selatan',
      country: 'Banten, Indonesia',
      latitude: -6.2889,
      longitude: 106.7181,
    ),
    OfflineCity(
      name: 'Cilegon',
      country: 'Banten, Indonesia',
      latitude: -6.0025,
      longitude: 106.0111,
    ),
    OfflineCity(
      name: 'Semarang',
      country: 'Jawa Tengah, Indonesia',
      latitude: -7.0051,
      longitude: 110.4381,
    ),
    OfflineCity(
      name: 'Surakarta',
      country: 'Jawa Tengah, Indonesia',
      latitude: -7.5755,
      longitude: 110.8243,
    ),
    OfflineCity(
      name: 'Magelang',
      country: 'Jawa Tengah, Indonesia',
      latitude: -7.4797,
      longitude: 110.2177,
    ),
    OfflineCity(
      name: 'Purwokerto',
      country: 'Jawa Tengah, Indonesia',
      latitude: -7.4243,
      longitude: 109.2396,
    ),
    OfflineCity(
      name: 'Tegal',
      country: 'Jawa Tengah, Indonesia',
      latitude: -6.8797,
      longitude: 109.1256,
    ),
    OfflineCity(
      name: 'Yogyakarta',
      country: 'DI Yogyakarta, Indonesia',
      latitude: -7.7956,
      longitude: 110.3695,
    ),
    OfflineCity(
      name: 'Sleman',
      country: 'DI Yogyakarta, Indonesia',
      latitude: -7.7162,
      longitude: 110.3350,
    ),
    OfflineCity(
      name: 'Bantul',
      country: 'DI Yogyakarta, Indonesia',
      latitude: -7.8881,
      longitude: 110.3285,
    ),
    OfflineCity(
      name: 'Surabaya',
      country: 'Jawa Timur, Indonesia',
      latitude: -7.2575,
      longitude: 112.7521,
    ),
    OfflineCity(
      name: 'Malang',
      country: 'Jawa Timur, Indonesia',
      latitude: -7.9666,
      longitude: 112.6326,
    ),
    OfflineCity(
      name: 'Kediri',
      country: 'Jawa Timur, Indonesia',
      latitude: -7.8480,
      longitude: 112.0178,
    ),
    OfflineCity(
      name: 'Madiun',
      country: 'Jawa Timur, Indonesia',
      latitude: -7.6298,
      longitude: 111.5239,
    ),
    OfflineCity(
      name: 'Jember',
      country: 'Jawa Timur, Indonesia',
      latitude: -8.1737,
      longitude: 113.6973,
    ),
    OfflineCity(
      name: 'Banyuwangi',
      country: 'Jawa Timur, Indonesia',
      latitude: -8.2192,
      longitude: 114.3691,
    ),
    OfflineCity(
      name: 'Denpasar',
      country: 'Bali, Indonesia',
      latitude: -8.6705,
      longitude: 115.2126,
    ),
    OfflineCity(
      name: 'Singaraja',
      country: 'Bali, Indonesia',
      latitude: -8.1120,
      longitude: 115.0882,
    ),
    OfflineCity(
      name: 'Mataram',
      country: 'Nusa Tenggara Barat, Indonesia',
      latitude: -8.5833,
      longitude: 116.1167,
    ),
    OfflineCity(
      name: 'Bima',
      country: 'Nusa Tenggara Barat, Indonesia',
      latitude: -8.4606,
      longitude: 118.7270,
    ),
    OfflineCity(
      name: 'Kupang',
      country: 'Nusa Tenggara Timur, Indonesia',
      latitude: -10.1772,
      longitude: 123.6070,
    ),
    OfflineCity(
      name: 'Ende',
      country: 'Nusa Tenggara Timur, Indonesia',
      latitude: -8.8432,
      longitude: 121.6623,
    ),
    OfflineCity(
      name: 'Pontianak',
      country: 'Kalimantan Barat, Indonesia',
      latitude: -0.0263,
      longitude: 109.3425,
    ),
    OfflineCity(
      name: 'Singkawang',
      country: 'Kalimantan Barat, Indonesia',
      latitude: 0.9093,
      longitude: 108.9846,
    ),
    OfflineCity(
      name: 'Palangkaraya',
      country: 'Kalimantan Tengah, Indonesia',
      latitude: -2.2161,
      longitude: 113.9137,
    ),
    OfflineCity(
      name: 'Sampit',
      country: 'Kalimantan Tengah, Indonesia',
      latitude: -2.5329,
      longitude: 112.9500,
    ),
    OfflineCity(
      name: 'Banjarmasin',
      country: 'Kalimantan Selatan, Indonesia',
      latitude: -3.3186,
      longitude: 114.5944,
    ),
    OfflineCity(
      name: 'Banjarbaru',
      country: 'Kalimantan Selatan, Indonesia',
      latitude: -3.4420,
      longitude: 114.8322,
    ),
    OfflineCity(
      name: 'Samarinda',
      country: 'Kalimantan Timur, Indonesia',
      latitude: -0.5022,
      longitude: 117.1536,
    ),
    OfflineCity(
      name: 'Balikpapan',
      country: 'Kalimantan Timur, Indonesia',
      latitude: -1.2654,
      longitude: 116.8312,
    ),
    OfflineCity(
      name: 'Bontang',
      country: 'Kalimantan Timur, Indonesia',
      latitude: 0.1333,
      longitude: 117.5000,
    ),
    OfflineCity(
      name: 'Tanjung Selor',
      country: 'Kalimantan Utara, Indonesia',
      latitude: 2.8375,
      longitude: 117.3653,
    ),
    OfflineCity(
      name: 'Tarakan',
      country: 'Kalimantan Utara, Indonesia',
      latitude: 3.3000,
      longitude: 117.6333,
    ),
    OfflineCity(
      name: 'Manado',
      country: 'Sulawesi Utara, Indonesia',
      latitude: 1.4748,
      longitude: 124.8421,
    ),
    OfflineCity(
      name: 'Bitung',
      country: 'Sulawesi Utara, Indonesia',
      latitude: 1.4404,
      longitude: 125.1217,
    ),
    OfflineCity(
      name: 'Gorontalo',
      country: 'Gorontalo, Indonesia',
      latitude: 0.5435,
      longitude: 123.0568,
    ),
    OfflineCity(
      name: 'Palu',
      country: 'Sulawesi Tengah, Indonesia',
      latitude: -0.9003,
      longitude: 119.8780,
    ),
    OfflineCity(
      name: 'Luwuk',
      country: 'Sulawesi Tengah, Indonesia',
      latitude: -0.9516,
      longitude: 122.7875,
    ),
    OfflineCity(
      name: 'Mamuju',
      country: 'Sulawesi Barat, Indonesia',
      latitude: -2.6748,
      longitude: 118.8885,
    ),
    OfflineCity(
      name: 'Makassar',
      country: 'Sulawesi Selatan, Indonesia',
      latitude: -5.1477,
      longitude: 119.4327,
    ),
    OfflineCity(
      name: 'Parepare',
      country: 'Sulawesi Selatan, Indonesia',
      latitude: -4.0135,
      longitude: 119.6255,
    ),
    OfflineCity(
      name: 'Palopo',
      country: 'Sulawesi Selatan, Indonesia',
      latitude: -3.0000,
      longitude: 120.2000,
    ),
    OfflineCity(
      name: 'Kendari',
      country: 'Sulawesi Tenggara, Indonesia',
      latitude: -3.9985,
      longitude: 122.5120,
    ),
    OfflineCity(
      name: 'Baubau',
      country: 'Sulawesi Tenggara, Indonesia',
      latitude: -5.4635,
      longitude: 122.6163,
    ),
    OfflineCity(
      name: 'Ambon',
      country: 'Maluku, Indonesia',
      latitude: -3.6554,
      longitude: 128.1908,
    ),
    OfflineCity(
      name: 'Tual',
      country: 'Maluku, Indonesia',
      latitude: -5.6409,
      longitude: 132.7475,
    ),
    OfflineCity(
      name: 'Sofifi',
      country: 'Maluku Utara, Indonesia',
      latitude: 0.7373,
      longitude: 127.5588,
    ),
    OfflineCity(
      name: 'Ternate',
      country: 'Maluku Utara, Indonesia',
      latitude: 0.7893,
      longitude: 127.3630,
    ),
    OfflineCity(
      name: 'Manokwari',
      country: 'Papua Barat, Indonesia',
      latitude: -0.8615,
      longitude: 134.0620,
    ),
    OfflineCity(
      name: 'Sorong',
      country: 'Papua Barat Daya, Indonesia',
      latitude: -0.8762,
      longitude: 131.2568,
    ),
    OfflineCity(
      name: 'Jayapura',
      country: 'Papua, Indonesia',
      latitude: -2.5916,
      longitude: 140.6690,
    ),
    OfflineCity(
      name: 'Nabire',
      country: 'Papua Tengah, Indonesia',
      latitude: -3.3667,
      longitude: 135.4833,
    ),
    OfflineCity(
      name: 'Wamena',
      country: 'Papua Pegunungan, Indonesia',
      latitude: -4.0950,
      longitude: 138.9400,
    ),
    OfflineCity(
      name: 'Merauke',
      country: 'Papua Selatan, Indonesia',
      latitude: -8.4932,
      longitude: 140.4018,
    ),
    OfflineCity(
      name: 'Mecca',
      country: 'Saudi Arabia',
      latitude: 21.3891,
      longitude: 39.8579,
    ),
    OfflineCity(
      name: 'Medina',
      country: 'Saudi Arabia',
      latitude: 24.5247,
      longitude: 39.5692,
    ),
    OfflineCity(
      name: 'London',
      country: 'United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
    ),
    OfflineCity(
      name: 'New York',
      country: 'United States',
      latitude: 40.7128,
      longitude: -74.0060,
    ),
    OfflineCity(
      name: 'Singapore',
      country: 'Singapore',
      latitude: 1.3521,
      longitude: 103.8198,
    ),
  ];

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, String>> getCityCountry(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final city =
            placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea ??
            'Unknown City';
        final country = placemark.country ?? 'Unknown Country';
        return {'city': city, 'country': country};
      }
    } catch (_) {
      // Return fallback offline city if geocoding fails (e.g. no internet)
      return _getClosestOfflineCity(latitude, longitude);
    }
    return {'city': 'Unknown', 'country': 'Unknown'};
  }

  static Map<String, String> _getClosestOfflineCity(
    double latitude,
    double longitude,
  ) {
    double minDistance = double.infinity;
    OfflineCity closest = defaultCities.first;

    for (var city in defaultCities) {
      final dist = Geolocator.distanceBetween(
        latitude,
        longitude,
        city.latitude,
        city.longitude,
      );
      if (dist < minDistance) {
        minDistance = dist;
        closest = city;
      }
    }
    return {'city': closest.name, 'country': closest.country};
  }
}
