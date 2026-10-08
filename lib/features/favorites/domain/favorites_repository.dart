import '../../../core/errors/result.dart';
import 'favorite_location.dart';

abstract class FavoritesRepository {
  Future<Result<List<FavoriteLocation>>> getFavorites();

  Future<Result<void>> addFavorite(FavoriteLocation location);

  Future<Result<void>> removeFavorite(String id);

  Future<void> clearLocalCache();
}
