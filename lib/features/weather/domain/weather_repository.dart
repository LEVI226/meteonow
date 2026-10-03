import '../../../core/errors/result.dart';
import 'geocoded_location.dart';
import 'weather_snapshot.dart';

abstract class WeatherRepository {
  Future<Result<WeatherSnapshot>> getWeather({required double latitude, required double longitude});

  Future<Result<List<GeocodedLocation>>> searchLocations(String query);
}
