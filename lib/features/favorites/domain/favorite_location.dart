class FavoriteLocation {
  const FavoriteLocation({
    required this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      other is FavoriteLocation &&
      other.id == id &&
      other.name == name &&
      other.country == country &&
      other.admin1 == admin1 &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(id, name, country, admin1, latitude, longitude);
}
