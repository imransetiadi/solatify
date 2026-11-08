import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:solatify/core/utils/timezone_database.dart';
import 'package:timezone/timezone.dart' as tz;

/// Resolves the IANA timezone used to display prayer times for a location.
///
/// `country` is the location label stored with the city, e.g.
/// `"Jawa Timur, Indonesia"` for built-in cities or `"East Java, Indonesia"`
/// from the device geocoder (whose names follow the device language).
class PrayerTimezoneService {
  /// The device's IANA timezone, loaded once at startup by
  /// [loadDeviceTimezone]. Null when unavailable (tests, desktop).
  @visibleForTesting
  static String? deviceTimezone;

  static Future<void> loadDeviceTimezone() async {
    try {
      // Bounded so a slow platform answer can never delay app start.
      deviceTimezone = (await FlutterTimezone.getLocalTimezone().timeout(
        const Duration(milliseconds: 300),
      )).identifier;
    } catch (e) {
      debugPrint('Device timezone unavailable: $e');
    }
  }

  static String inferTimezoneName({
    required double latitude,
    required double longitude,
    required String country,
  }) {
    final normalized = country.toLowerCase();

    if (normalized.contains('indonesia')) {
      return _indonesiaByRegion(normalized) ??
          _indonesiaByCoordinates(latitude, longitude);
    }

    // Country names follow the device language ("Deutschland", "Allemagne"),
    // so unknown ones are common. The device's own zone is right when the
    // phone is where the location is (GPS); a fixed offset has no DST.
    return _byCountry(normalized, latitude, longitude) ??
        _deviceZoneNear(longitude) ??
        _fixedOffsetByLongitude(longitude);
  }

  /// The device timezone when its current UTC offset is within 90 minutes
  /// of the offset expected at [longitude], i.e. the phone is plausibly at
  /// the location.
  static String? _deviceZoneNear(double longitude) {
    final zone = deviceTimezone;
    if (zone == null || zone.isEmpty) return null;
    try {
      TimezoneDatabase.ensureInitialized();
      final offset = tz.TZDateTime.now(tz.getLocation(zone)).timeZoneOffset;
      final expectedMinutes = longitude / 15 * 60;
      return (offset.inMinutes - expectedMinutes).abs() <= 90 ? zone : null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Indonesia: WIB (UTC+7), WITA (UTC+8), WIT (UTC+9) follow province borders,
  // not a single meridian. East Java (incl. Surabaya at 112.75°E) is WIB.
  // ---------------------------------------------------------------------------

  static const _witRegions = ['papua', 'maluku', 'moluccas'];

  static const _witaRegions = [
    'bali',
    'nusa tenggara',
    'sulawesi',
    'gorontalo',
    'kalimantan timur',
    'kalimantan selatan',
    'kalimantan utara',
    'east kalimantan',
    'south kalimantan',
    'north kalimantan',
  ];

  static const _wibRegions = [
    'jawa',
    'java',
    'jakarta',
    'banten',
    'yogyakarta',
    'sumatera',
    'sumatra',
    'aceh',
    'riau',
    'jambi',
    'bengkulu',
    'lampung',
    'bangka',
    'belitung',
    'kalimantan barat',
    'kalimantan tengah',
    'west kalimantan',
    'central kalimantan',
  ];

  static String? _indonesiaByRegion(String normalized) {
    bool matches(List<String> regions) => regions.any(normalized.contains);

    if (matches(_witRegions)) return 'Asia/Jayapura';
    if (matches(_witaRegions)) return 'Asia/Makassar';
    if (matches(_wibRegions)) return 'Asia/Jakarta';
    return null;
  }

  /// Used when only "Indonesia" is known (no province). Approximates the
  /// province borders that define the three zones.
  static String _indonesiaByCoordinates(double latitude, double longitude) {
    // WIT: Papua and Maluku, including Sula (~124.3°E) and Buru/Wetar.
    if (longitude >= 127.0 ||
        (latitude < 0 && latitude >= -3.0 && longitude >= 124.2) ||
        (latitude < 0 && longitude >= 125.5)) {
      return 'Asia/Jayapura';
    }

    // Java (WIB) vs Bali and Nusa Tenggara (WITA), split at the Bali Strait.
    if (latitude < -5.5) {
      return longitude >= 114.5 ? 'Asia/Makassar' : 'Asia/Jakarta';
    }

    // Sulawesi and the eastern Kalimantan coast.
    if (longitude >= 118.5) return 'Asia/Makassar';

    // Kalimantan: West/Central are WIB; South/East/North are WITA.
    if (longitude >= 108.5) {
      final isWita =
          longitude >= 115.5 ||
          (latitude < -2.2 && longitude >= 114.4) ||
          (latitude > 0.6 && longitude >= 114.2);
      return isWita ? 'Asia/Makassar' : 'Asia/Jakarta';
    }

    // Sumatra, Bangka Belitung, Riau Islands.
    return 'Asia/Jakarta';
  }

  // ---------------------------------------------------------------------------
  // Other countries. Names are matched in English and Indonesian because the
  // geocoder localises country names to the device language.
  // ---------------------------------------------------------------------------

  static const Map<String, String> _singleZoneCountries = {
    'singapore': 'Asia/Singapore',
    'singapura': 'Asia/Singapore',
    'malaysia': 'Asia/Kuala_Lumpur',
    'brunei': 'Asia/Brunei',
    'timor-leste': 'Asia/Dili',
    'timor leste': 'Asia/Dili',
    'saudi': 'Asia/Riyadh',
    'united arab emirates': 'Asia/Dubai',
    'uni emirat arab': 'Asia/Dubai',
    'qatar': 'Asia/Qatar',
    'kuwait': 'Asia/Kuwait',
    'bahrain': 'Asia/Bahrain',
    'oman': 'Asia/Muscat',
    'yemen': 'Asia/Aden',
    'jordan': 'Asia/Amman',
    'yordania': 'Asia/Amman',
    'palestine': 'Asia/Hebron',
    'palestina': 'Asia/Hebron',
    'lebanon': 'Asia/Beirut',
    'syria': 'Asia/Damascus',
    'suriah': 'Asia/Damascus',
    'iraq': 'Asia/Baghdad',
    'irak': 'Asia/Baghdad',
    'iran': 'Asia/Tehran',
    'turkey': 'Europe/Istanbul',
    'turki': 'Europe/Istanbul',
    'türkiye': 'Europe/Istanbul',
    'egypt': 'Africa/Cairo',
    'mesir': 'Africa/Cairo',
    'morocco': 'Africa/Casablanca',
    'maroko': 'Africa/Casablanca',
    'algeria': 'Africa/Algiers',
    'aljazair': 'Africa/Algiers',
    'tunisia': 'Africa/Tunis',
    'libya': 'Africa/Tripoli',
    'sudan': 'Africa/Khartoum',
    'nigeria': 'Africa/Lagos',
    'pakistan': 'Asia/Karachi',
    'india': 'Asia/Kolkata',
    'bangladesh': 'Asia/Dhaka',
    'afghanistan': 'Asia/Kabul',
    'uzbekistan': 'Asia/Tashkent',
    'maldives': 'Indian/Maldives',
    'maladewa': 'Indian/Maldives',
    'sri lanka': 'Asia/Colombo',
    'thailand': 'Asia/Bangkok',
    'vietnam': 'Asia/Ho_Chi_Minh',
    'philippines': 'Asia/Manila',
    'filipina': 'Asia/Manila',
    'japan': 'Asia/Tokyo',
    'jepang': 'Asia/Tokyo',
    'korea': 'Asia/Seoul',
    'china': 'Asia/Shanghai',
    'tiongkok': 'Asia/Shanghai',
    'hong kong': 'Asia/Hong_Kong',
    'taiwan': 'Asia/Taipei',
    'united kingdom': 'Europe/London',
    'britania raya': 'Europe/London',
    'inggris': 'Europe/London',
    'ireland': 'Europe/Dublin',
    'netherlands': 'Europe/Amsterdam',
    'belanda': 'Europe/Amsterdam',
    'germany': 'Europe/Berlin',
    'jerman': 'Europe/Berlin',
    'france': 'Europe/Paris',
    'prancis': 'Europe/Paris',
    'belgium': 'Europe/Brussels',
    'belgia': 'Europe/Brussels',
    'spain': 'Europe/Madrid',
    'spanyol': 'Europe/Madrid',
    'italy': 'Europe/Rome',
    'italia': 'Europe/Rome',
    'switzerland': 'Europe/Zurich',
    'swiss': 'Europe/Zurich',
    'austria': 'Europe/Vienna',
    'sweden': 'Europe/Stockholm',
    'swedia': 'Europe/Stockholm',
    'norway': 'Europe/Oslo',
    'norwegia': 'Europe/Oslo',
    'denmark': 'Europe/Copenhagen',
    'bosnia': 'Europe/Sarajevo',
    'new zealand': 'Pacific/Auckland',
    'selandia baru': 'Pacific/Auckland',
    'south africa': 'Africa/Johannesburg',
    'afrika selatan': 'Africa/Johannesburg',
  };

  static String? _byCountry(
    String normalized,
    double latitude,
    double longitude,
  ) {
    if (normalized.contains('united states') ||
        normalized.contains('amerika serikat') ||
        normalized == 'usa') {
      return _unitedStates(latitude, longitude);
    }
    if (normalized.contains('canada') || normalized.contains('kanada')) {
      return _canada(longitude);
    }
    if (normalized.contains('australia')) {
      return _australia(latitude, longitude);
    }

    for (final entry in _singleZoneCountries.entries) {
      // Whole-word match, so e.g. "romania" does not match "oman".
      final pattern = RegExp(
        '(^|[^a-z])${RegExp.escape(entry.key)}(\$|[^a-z])',
      );
      if (pattern.hasMatch(normalized)) return entry.value;
    }
    return null;
  }

  static String _unitedStates(double latitude, double longitude) {
    if (longitude < -150 && latitude < 30) return 'Pacific/Honolulu';
    if (longitude < -130) return 'America/Anchorage';
    if (longitude < -114.5) return 'America/Los_Angeles';
    if (longitude < -101) return 'America/Denver';
    if (longitude < -87.5) return 'America/Chicago';
    return 'America/New_York';
  }

  static String _canada(double longitude) {
    if (longitude < -120) return 'America/Vancouver';
    if (longitude < -102) return 'America/Edmonton';
    if (longitude < -90) return 'America/Winnipeg';
    if (longitude < -68) return 'America/Toronto';
    return 'America/Halifax';
  }

  static String _australia(double latitude, double longitude) {
    if (longitude < 129) return 'Australia/Perth';
    if (longitude < 138) {
      return latitude > -26 ? 'Australia/Darwin' : 'Australia/Adelaide';
    }
    if (latitude > -28.2) return 'Australia/Brisbane';
    return 'Australia/Sydney';
  }

  /// Last resort for unknown countries: a fixed offset from longitude. It has
  /// no DST, but is far closer than assuming Jakarta time everywhere.
  /// Note the inverted sign in IANA `Etc/GMT` names: UTC+7 is `Etc/GMT-7`.
  static String _fixedOffsetByLongitude(double longitude) {
    final offset = (longitude / 15).round().clamp(-12, 14);
    if (offset == 0) return 'Etc/GMT';
    return offset > 0 ? 'Etc/GMT-$offset' : 'Etc/GMT+${-offset}';
  }
}
