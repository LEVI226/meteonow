class CurrentWeather {
  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.weatherCode,
    this.isFromCache = false,
  });

  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final double pressure;
  final double visibility;
  final int weatherCode;
  final bool isFromCache;

  CurrentWeather withCacheFlag(bool value) => CurrentWeather(
        temperature: temperature,
        apparentTemperature: apparentTemperature,
        humidity: humidity,
        windSpeed: windSpeed,
        pressure: pressure,
        visibility: visibility,
        weatherCode: weatherCode,
        isFromCache: value,
      );
}
