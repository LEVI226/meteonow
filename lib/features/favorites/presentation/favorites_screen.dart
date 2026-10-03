import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/result.dart';
import '../../../core/router/repository_scope.dart';
import '../../../shared/widgets/location_card.dart';
import '../../profile/domain/app_settings.dart';
import '../../profile/presentation/settings_controller.dart';
import '../../weather/domain/weather_snapshot.dart';
import '../domain/favorite_location.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, WeatherSnapshot> _weatherByFavoriteId = {};
  bool _isSyncing = false;
  bool _loadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedOnce) {
      _loadedOnce = true;
      // Defer to a microtask: load() calls notifyListeners() synchronously before its first
      // await, and notifying the shared FavoritesControllerScope ancestor while this widget is
      // still in its first build would hit "setState() or markNeedsBuild() called during build".
      Future.microtask(_refreshAll);
    }
  }

  Future<void> _refreshAll() async {
    await FavoritesControllerScope.of(context).load();
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    final favorites = FavoritesControllerScope.of(context).favorites;
    final weatherRepository = RepositoryScope.of(context).weatherRepository;
    final entries = await Future.wait(favorites.map((favorite) async {
      final result = await weatherRepository.getWeather(latitude: favorite.latitude, longitude: favorite.longitude);
      return MapEntry(favorite.id, result);
    }));
    if (!mounted) return;
    final map = <String, WeatherSnapshot>{};
    for (final entry in entries) {
      if (entry.value case Ok<WeatherSnapshot>(:final value)) {
        map[entry.key] = value;
      }
    }
    setState(() {
      _weatherByFavoriteId = map;
      _isSyncing = false;
    });
  }

  void _setAsHome(FavoriteLocation location) {
    SettingsScope.of(context).setHomeLocation(
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${location.name} set as home location')));
  }

  Future<void> _remove(FavoriteLocation location) async {
    final result = await FavoritesControllerScope.of(context).removeFavoriteById(location.id);
    if (!mounted) return;
    if (result case Err<void>(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = FavoritesControllerScope.of(context);
    final unit = SettingsScope.of(context).temperatureUnit;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite locations'),
        actions: [
          IconButton(onPressed: _isSyncing ? null : _loadWeather, icon: const Icon(Icons.sync)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed('search'),
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: favoritesController,
        builder: (context, _) {
          if (favoritesController.isLoading) return const Center(child: CircularProgressIndicator());
          final favorites = favoritesController.favorites;
          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorites yet. Search for a city and tap the bookmark icon to save it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final weather = _weatherByFavoriteId[favorite.id];
                return LocationCard(
                  name: favorite.name,
                  subtitle: [favorite.admin1, favorite.country].whereType<String>().join(', '),
                  temperature: weather == null ? null : unit.convert(weather.current.temperature),
                  weatherCode: weather?.current.weatherCode,
                  isFavorite: true,
                  onTap: () => _setAsHome(favorite),
                  onFavoriteToggle: () => _remove(favorite),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
