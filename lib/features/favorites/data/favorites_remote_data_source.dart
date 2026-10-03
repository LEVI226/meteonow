import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/favorite_location.dart';

class FavoritesRemoteDataSource {
  FavoritesRemoteDataSource(this._dio, this._client);

  final Dio _dio;
  final SupabaseClient _client;

  FavoriteLocation _fromRow(Map<String, dynamic> row) => FavoriteLocation(
        id: row['id'] as String,
        name: row['name'] as String,
        country: row['country'] as String,
        admin1: row['admin1'] as String?,
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble(),
      );

  Future<List<FavoriteLocation>> fetchFavorites() async {
    final userId = _client.auth.currentUser!.id;
    final response = await _dio.get<List<dynamic>>(
      '/rest/v1/favorites',
      queryParameters: {'user_id': 'eq.$userId', 'select': '*'},
    );
    return (response.data ?? const []).map((row) => _fromRow(row as Map<String, dynamic>)).toList();
  }

  Future<FavoriteLocation> insertFavorite(FavoriteLocation location) async {
    final userId = _client.auth.currentUser!.id;
    final response = await _dio.post<List<dynamic>>(
      '/rest/v1/favorites',
      data: {
        'user_id': userId,
        'name': location.name,
        'country': location.country,
        'admin1': location.admin1,
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    );
    return _fromRow(response.data!.first as Map<String, dynamic>);
  }

  Future<void> deleteFavorite(String id) async {
    await _dio.delete<void>('/rest/v1/favorites', queryParameters: {'id': 'eq.$id'});
  }
}
