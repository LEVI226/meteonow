import 'package:dio/dio.dart';

import '../domain/geocoded_location.dart';
import '../domain/weather_snapshot.dart';

const _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
const _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

List<GeocodedLocation> parseGeocodingResults(Map<String, dynamic> json) {
  final results = (json['results'] as List?) ?? const [];
  return results.map((raw) {
    final row = raw as Map<String, dynamic>;
    return GeocodedLocation(
      name: row['name'] as String,
      country: row['country'] as String,
      admin1: row['admin1'] as String?,
      latitude: (row['latitude'] as num).toDouble(),
      longitude: (row['longitude'] as num).toDouble(),
    );
  }).toList();
}

class OpenMeteoApi {
  OpenMeteoApi(this._dio);

  final Dio _dio;

  Future<WeatherSnapshot> fetchForecast({required double latitude, required double longitude}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _forecastBaseUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,surface_pressure',
        'hourly': 'temperature_2m,weather_code,visibility',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': 5,
      },
    );
    return WeatherSnapshot.fromOpenMeteoJson(response.data!);
  }

  Future<List<GeocodedLocation>> searchLocations(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _geocodingBaseUrl,
      queryParameters: {'name': query, 'count': 10, 'language': 'en', 'format': 'json'},
    );
    return parseGeocodingResults(response.data!);
  }
}
