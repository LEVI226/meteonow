import 'current_weather.dart';
import 'daily_forecast.dart';
import 'hourly_forecast.dart';

class WeatherSnapshot {
  const WeatherSnapshot({required this.current, required this.hourly, required this.daily});

  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  WeatherSnapshot asCached() => WeatherSnapshot(
        current: current.withCacheFlag(true),
        hourly: hourly,
        daily: daily,
      );

  factory WeatherSnapshot.fromOpenMeteoJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final hourlyTimes = (hourly['time'] as List).cast<String>();
    final hourlyVisibility = (hourly['visibility'] as List).cast<num>();
    final hourIndex = hourlyTimes.indexOf(current['time'] as String);
    final visibility = hourIndex >= 0 ? hourlyVisibility[hourIndex].toDouble() : 10000.0;

    final hourlyTemps = (hourly['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourly['weather_code'] as List).cast<num>();

    final dailyTimes = (daily['time'] as List).cast<String>();
    final dailyCodes = (daily['weather_code'] as List).cast<num>();
    final dailyMax = (daily['temperature_2m_max'] as List).cast<num>();
    final dailyMin = (daily['temperature_2m_min'] as List).cast<num>();

    return WeatherSnapshot(
      current: CurrentWeather(
        temperature: (current['temperature_2m'] as num).toDouble(),
        apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).round(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        pressure: (current['surface_pressure'] as num).toDouble(),
        visibility: visibility,
        weatherCode: (current['weather_code'] as num).round(),
      ),
      hourly: [
        for (var i = 0; i < hourlyTimes.length; i++)
          HourlyForecast(
            time: DateTime.parse(hourlyTimes[i]),
            temperature: hourlyTemps[i].toDouble(),
            weatherCode: hourlyCodes[i].round(),
          ),
      ],
      daily: [
        for (var i = 0; i < dailyTimes.length; i++)
          DailyForecast(
            date: DateTime.parse(dailyTimes[i]),
            weatherCode: dailyCodes[i].round(),
            maxTemperature: dailyMax[i].toDouble(),
            minTemperature: dailyMin[i].toDouble(),
          ),
      ],
    );
  }
}
