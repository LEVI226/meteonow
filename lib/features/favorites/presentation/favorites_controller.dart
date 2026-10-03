import 'package:flutter/material.dart';

import '../../../core/errors/result.dart';
import '../../weather/domain/geocoded_location.dart';
import '../domain/favorite_location.dart';
import '../domain/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repository);

  final FavoritesRepository _repository;
  List<FavoriteLocation> _favorites = [];
  bool isLoading = false;

  List<FavoriteLocation> get favorites => List.unmodifiable(_favorites);

  bool _closeEnough(double a, double b) => (a - b).abs() < 0.01;

  FavoriteLocation? _findExisting(double latitude, double longitude) {
    for (final favorite in _favorites) {
      if (_closeEnough(favorite.latitude, latitude) && _closeEnough(favorite.longitude, longitude)) return favorite;
    }
    return null;
  }

  bool isFavorite(double latitude, double longitude) => _findExisting(latitude, longitude) != null;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    final result = await _repository.getFavorites();
    if (result case Ok<List<FavoriteLocation>>(:final value)) {
      _favorites = value;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<Result<void>> toggle(GeocodedLocation location) async {
    final existing = _findExisting(location.latitude, location.longitude);
    if (existing != null) {
      final result = await _repository.removeFavorite(existing.id);
      if (result case Ok<void>()) {
        _favorites.removeWhere((f) => f.id == existing.id);
        notifyListeners();
      }
      return result;
    }
    final draft = FavoriteLocation(
      id: 'pending-${DateTime.now().millisecondsSinceEpoch}',
      name: location.name,
      country: location.country,
      admin1: location.admin1,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    final result = await _repository.addFavorite(draft);
    if (result case Ok<void>()) {
      await load(); // refetch so the server-assigned id replaces the temporary draft id
    }
    return result;
  }
}

class FavoritesControllerScope extends InheritedNotifier<FavoritesController> {
  const FavoritesControllerScope({super.key, required FavoritesController controller, required super.child})
      : super(notifier: controller);

  static FavoritesController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesControllerScope>();
    assert(scope != null, 'No FavoritesControllerScope found in context');
    return scope!.notifier!;
  }
}
