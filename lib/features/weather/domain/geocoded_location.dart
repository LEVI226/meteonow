class GeocodedLocation {
  const GeocodedLocation({
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;
}
