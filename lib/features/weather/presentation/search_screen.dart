import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/errors/result.dart';
import '../../../core/router/repository_scope.dart';
import '../../../shared/widgets/location_card.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../profile/domain/app_settings.dart';
import '../../profile/presentation/settings_controller.dart';
import '../domain/geocoded_location.dart';
import '../domain/weather_snapshot.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<GeocodedLocation> _results = [];
  Map<String, WeatherSnapshot> _weatherByKey = {};
  bool _isSearching = false;
  String? _error;
  bool _favoritesLoadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Guard against re-entry: FavoritesControllerScope.of(context) subscribes this widget as a
    // dependent of the scope, and load() notifies that same scope, so an unguarded call here
    // would re-trigger didChangeDependencies indefinitely (mirrors the `if (_result == null)`
    // guard HomeScreen uses for the same reason).
    if (!_favoritesLoadRequested) {
      _favoritesLoadRequested = true;
      final favoritesController = FavoritesControllerScope.of(context);
      // Defer to a microtask: load() calls notifyListeners() synchronously before its first
      // await, and notifying the shared FavoritesControllerScope ancestor while this widget is
      // still in its first build would hit "setState() or markNeedsBuild() called during build".
      Future.microtask(favoritesController.load);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _keyFor(GeocodedLocation location) => '${location.latitude},${location.longitude}';

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _weatherByKey = {};
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _error = null;
    });
    final weatherRepository = RepositoryScope.of(context).weatherRepository;
    final result = await weatherRepository.searchLocations(query);
    if (!mounted) return;
    switch (result) {
      case Ok<List<GeocodedLocation>>(:final value):
        setState(() {
          _isSearching = false;
          _results = value;
        });
        final entries = await Future.wait(value.map((location) async {
          final weather = await weatherRepository.getWeather(
            latitude: location.latitude,
            longitude: location.longitude,
          );
          return MapEntry(_keyFor(location), weather);
        }));
        if (!mounted) return;
        final map = <String, WeatherSnapshot>{};
        for (final entry in entries) {
          if (entry.value case Ok<WeatherSnapshot>(:final value)) {
            map[entry.key] = value;
          }
        }
        setState(() => _weatherByKey = map);
      case Err<List<GeocodedLocation>>(:final failure):
        setState(() {
          _isSearching = false;
          _results = [];
          _error = failure.message;
        });
    }
  }

  Future<void> _toggleFavorite(GeocodedLocation location) async {
    final favoritesController = FavoritesControllerScope.of(context);
    final result = await favoritesController.toggle(location);
    if (!mounted) return;
    if (result case Err<void>(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  void _setAsHome(GeocodedLocation location) {
    SettingsScope.of(context).setHomeLocation(
      name: location.name,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${location.name} set as home location')));
  }

  @override
  Widget build(BuildContext context) {
    final favoritesController = FavoritesControllerScope.of(context);
    final unit = SettingsScope.of(context).temperatureUnit;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _onChanged,
          decoration: const InputDecoration(
            hintText: 'Search for a city...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: favoritesController,
        builder: (context, _) {
          if (_isSearching) return const Center(child: CircularProgressIndicator());
          if (_error != null) return Center(child: Text(_error!));
          if (_results.isEmpty) {
            return const Center(child: Text('Search for a city to see its current weather.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final location = _results[index];
              final weather = _weatherByKey[_keyFor(location)];
              return LocationCard(
                name: location.name,
                subtitle: [location.admin1, location.country].whereType<String>().join(', '),
                temperature: weather == null ? null : unit.convert(weather.current.temperature),
                weatherCode: weather?.current.weatherCode,
                isFavorite: favoritesController.isFavorite(location.latitude, location.longitude),
                onTap: () => _setAsHome(location),
                onFavoriteToggle: () => _toggleFavorite(location),
              );
            },
          );
        },
      ),
    );
  }
}
