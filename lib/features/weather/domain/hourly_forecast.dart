class HourlyForecast {
  const HourlyForecast({required this.time, required this.temperature, required this.weatherCode});

  final DateTime time;
  final double temperature;
  final int weatherCode;
}
