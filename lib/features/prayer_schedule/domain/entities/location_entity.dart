class LocationEntity {
  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.isLoading = false,
    this.errorMessage,
  });

  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final bool isLoading;
  final String? errorMessage;

  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
