class PrayerTimezoneService {
  static String inferTimezoneName({
    required double latitude,
    required double longitude,
    required String country,
  }) {
    final normalizedCountry = country.toLowerCase();

    if (normalizedCountry.contains('indonesia')) {
      return _inferIndonesiaTimezone(country, longitude);
    }

    return _inferByLongitude(longitude);
  }

  static String _inferIndonesiaTimezone(String country, double longitude) {
    final normalized = country.toLowerCase();

    if (normalized.contains('papua') || normalized.contains('maluku')) {
      return 'Asia/Jayapura';
    }

    if (normalized.contains('bali') ||
        normalized.contains('nusa tenggara') ||
        normalized.contains('sulawesi') ||
        normalized.contains('gorontalo') ||
        normalized.contains('kalimantan timur') ||
        normalized.contains('kalimantan selatan') ||
        normalized.contains('kalimantan utara')) {
      return 'Asia/Makassar';
    }

    if (longitude >= 132.0) return 'Asia/Jayapura';
    if (longitude >= 112.0) return 'Asia/Makassar';
    return 'Asia/Jakarta';
  }

  static String _inferByLongitude(double longitude) {
    final offset = (longitude / 15).round().clamp(-12, 14);
    if (offset == 7) return 'Asia/Jakarta';
    if (offset == 8) return 'Asia/Makassar';
    if (offset == 9) return 'Asia/Jayapura';
    if (offset == 3) return 'Asia/Riyadh';
    return 'Asia/Jakarta';
  }
}
