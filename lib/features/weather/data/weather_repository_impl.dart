import '../../../core/errors/app_failure.dart';
import '../../../core/errors/result.dart';
import '../domain/geocoded_location.dart';
import '../domain/weather_repository.dart';
import '../domain/weather_snapshot.dart';
import 'open_meteo_api.dart';
import 'weather_local_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._api, this._local);

  final OpenMeteoApi _api;
  final WeatherLocalDataSource _local;

  String _keyFor(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  @override
  Future<Result<WeatherSnapshot>> getWeather({required double latitude, required double longitude}) async {
    final key = _keyFor(latitude, longitude);
    try {
      final snapshot = await _api.fetchForecast(latitude: latitude, longitude: longitude);
      await _local.cacheWeather(key, snapshot);
      return Ok(snapshot);
    } catch (_) {
      final cached = _local.getCachedWeather(key);
      if (cached == null) return const Err(NetworkFailure());
      return Ok(cached.asCached());
    }
  }

  @override
  Future<Result<List<GeocodedLocation>>> searchLocations(String query) async {
    try {
      final results = await _api.searchLocations(query);
      return Ok(results);
    } catch (_) {
      return const Err(NetworkFailure('Could not search locations. Check your connection.'));
    }
  }
}
