import 'package:hive/hive.dart';

import '../domain/current_weather.dart';
import '../domain/daily_forecast.dart';
import '../domain/hourly_forecast.dart';
import '../domain/weather_snapshot.dart';

class WeatherLocalDataSource {
  WeatherLocalDataSource(this._box);

  final Box<Map> _box;

  Future<void> cacheWeather(String key, WeatherSnapshot snapshot) async {
    await _box.put(key, {
      'current': {
        'temperature': snapshot.current.temperature,
        'apparentTemperature': snapshot.current.apparentTemperature,
        'humidity': snapshot.current.humidity,
        'windSpeed': snapshot.current.windSpeed,
        'pressure': snapshot.current.pressure,
        'visibility': snapshot.current.visibility,
        'weatherCode': snapshot.current.weatherCode,
      },
      'hourly': [
        for (final h in snapshot.hourly)
          {'time': h.time.toIso8601String(), 'temperature': h.temperature, 'weatherCode': h.weatherCode},
      ],
      'daily': [
        for (final d in snapshot.daily)
          {
            'date': d.date.toIso8601String(),
            'weatherCode': d.weatherCode,
            'maxTemperature': d.maxTemperature,
            'minTemperature': d.minTemperature,
          },
      ],
    });
  }

  WeatherSnapshot? getCachedWeather(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw);
    final current = Map<String, dynamic>.from(map['current'] as Map);
    final hourly = (map['hourly'] as List).cast<Map>();
    final daily = (map['daily'] as List).cast<Map>();

    return WeatherSnapshot(
      current: CurrentWeather(
        temperature: (current['temperature'] as num).toDouble(),
        apparentTemperature: (current['apparentTemperature'] as num).toDouble(),
        humidity: current['humidity'] as int,
        windSpeed: (current['windSpeed'] as num).toDouble(),
        pressure: (current['pressure'] as num).toDouble(),
        visibility: (current['visibility'] as num).toDouble(),
        weatherCode: current['weatherCode'] as int,
      ),
      hourly: [
        for (final h in hourly)
          HourlyForecast(
            time: DateTime.parse(h['time'] as String),
            temperature: (h['temperature'] as num).toDouble(),
            weatherCode: h['weatherCode'] as int,
          ),
      ],
      daily: [
        for (final d in daily)
          DailyForecast(
            date: DateTime.parse(d['date'] as String),
            weatherCode: d['weatherCode'] as int,
            maxTemperature: (d['maxTemperature'] as num).toDouble(),
            minTemperature: (d['minTemperature'] as num).toDouble(),
          ),
      ],
    );
  }
}
