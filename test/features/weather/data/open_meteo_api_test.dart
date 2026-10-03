import 'package:flutter_test/flutter_test.dart';
import 'package:meteonow/features/weather/data/open_meteo_api.dart';
import 'package:meteonow/features/weather/domain/weather_snapshot.dart';

void main() {
  group('WeatherSnapshot.fromOpenMeteoJson', () {
    final fixture = {
      'current': {
        'time': '2026-10-03T14:00',
        'temperature_2m': 28.4,
        'relative_humidity_2m': 65,
        'apparent_temperature': 30.1,
        'weather_code': 2,
        'wind_speed_10m': 14.2,
        'surface_pressure': 1012.0,
      },
      'hourly': {
        'time': ['2026-10-03T13:00', '2026-10-03T14:00', '2026-10-03T15:00'],
        'temperature_2m': [27.0, 28.4, 29.0],
        'weather_code': [1, 2, 2],
        'visibility': [24000.0, 23500.0, 23000.0],
      },
      'daily': {
        'time': ['2026-10-03', '2026-10-04'],
        'weather_code': [2, 1],
        'temperature_2m_max': [31.0, 32.0],
        'temperature_2m_min': [24.0, 23.5],
      },
    };

    test('parses current conditions and picks visibility from the matching hourly index', () {
      final snapshot = WeatherSnapshot.fromOpenMeteoJson(fixture);

      expect(snapshot.current.temperature, 28.4);
      expect(snapshot.current.apparentTemperature, 30.1);
      expect(snapshot.current.humidity, 65);
      expect(snapshot.current.windSpeed, 14.2);
      expect(snapshot.current.pressure, 1012.0);
      expect(snapshot.current.weatherCode, 2);
      expect(snapshot.current.visibility, 23500.0);
      expect(snapshot.current.isFromCache, isFalse);
    });

    test('parses the full hourly and daily series', () {
      final snapshot = WeatherSnapshot.fromOpenMeteoJson(fixture);

      expect(snapshot.hourly, hasLength(3));
      expect(snapshot.hourly[1].temperature, 28.4);
      expect(snapshot.daily, hasLength(2));
      expect(snapshot.daily[0].maxTemperature, 31.0);
      expect(snapshot.daily[1].minTemperature, 23.5);
    });

    test('asCached returns a copy with isFromCache true, same data', () {
      final snapshot = WeatherSnapshot.fromOpenMeteoJson(fixture).asCached();

      expect(snapshot.current.isFromCache, isTrue);
      expect(snapshot.current.temperature, 28.4);
    });
  });

  group('OpenMeteoApi.searchLocations parsing', () {
    test('parses the geocoding results array, admin1 optional', () {
      final json = {
        'results': [
          {'name': 'Paris', 'latitude': 48.85, 'longitude': 2.35, 'country': 'France', 'admin1': 'Ile-de-France'},
          {'name': 'Ouagadougou', 'latitude': 12.37, 'longitude': -1.52, 'country': 'Burkina Faso'},
        ],
      };

      final results = parseGeocodingResults(json);

      expect(results, hasLength(2));
      expect(results[0].name, 'Paris');
      expect(results[0].admin1, 'Ile-de-France');
      expect(results[1].admin1, isNull);
    });
  });
}
