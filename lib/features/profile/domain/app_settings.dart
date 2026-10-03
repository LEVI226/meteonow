enum TemperatureUnit { celsius, fahrenheit }

extension TemperatureUnitX on TemperatureUnit {
  double convert(double celsiusValue) => switch (this) {
        TemperatureUnit.celsius => celsiusValue,
        TemperatureUnit.fahrenheit => (celsiusValue * 9 / 5) + 32,
      };

  String get symbol => switch (this) {
        TemperatureUnit.celsius => '°C',
        TemperatureUnit.fahrenheit => '°F',
      };
}
