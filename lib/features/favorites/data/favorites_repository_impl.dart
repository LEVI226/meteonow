import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/favorite_location.dart';
import '../domain/favorites_repository.dart';
import 'favorites_local_data_source.dart';
import 'favorites_remote_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._remote, this._local);

  final FavoritesRemoteDataSource _remote;
  final FavoritesLocalDataSource _local;

  @override
  Future<Result<List<FavoriteLocation>>> getFavorites() async {
    try {
      final favorites = await _remote.fetchFavorites();
      await _local.saveAll(favorites);
      return Ok(favorites);
    } catch (_) {
      final cached = _local.getAll();
      if (cached.isEmpty) return const Err(CacheFailure());
      return Ok(cached);
    }
  }

  @override
  Future<Result<void>> addFavorite(FavoriteLocation location) async {
    try {
      final saved = await _remote.insertFavorite(location);
      await _local.save(saved);
      return const Ok(null);
    } catch (_) {
      return const Err(NetworkFailure('Could not save favorite. Check your connection.'));
    }
  }

  @override
  Future<Result<void>> removeFavorite(String id) async {
    try {
      await _remote.deleteFavorite(id);
      await _local.remove(id);
      return const Ok(null);
    } catch (_) {
      return const Err(NetworkFailure('Could not remove favorite. Check your connection.'));
    }
  }

  @override
  Future<void> clearLocalCache() => _local.clear();
}
