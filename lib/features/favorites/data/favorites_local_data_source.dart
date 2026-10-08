import 'package:hive/hive.dart';

import '../domain/favorite_location.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._box);

  final Box<Map> _box;

  FavoriteLocation _fromMap(Map<String, dynamic> map) => FavoriteLocation(
        id: map['id'] as String,
        name: map['name'] as String,
        country: map['country'] as String,
        admin1: map['admin1'] as String?,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
      );

  Map<String, dynamic> _toMap(FavoriteLocation location) => {
        'id': location.id,
        'name': location.name,
        'country': location.country,
        'admin1': location.admin1,
        'latitude': location.latitude,
        'longitude': location.longitude,
      };

  List<FavoriteLocation> getAll() => _box.values.map((raw) => _fromMap(Map<String, dynamic>.from(raw))).toList();

  Future<void> saveAll(List<FavoriteLocation> locations) async {
    await _box.clear();
    for (final location in locations) {
      await _box.put(location.id, _toMap(location));
    }
  }

  Future<void> save(FavoriteLocation location) => _box.put(location.id, _toMap(location));

  Future<void> remove(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();
}
