import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../domain/app_settings.dart';

class SettingsLocalDataSource {
  SettingsLocalDataSource(this._box);

  final Box _box;

  ThemeMode getThemeMode() {
    final value = _box.get('themeMode') as String?;
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) => _box.put('themeMode', mode.name);

  TemperatureUnit getTemperatureUnit() {
    final value = _box.get('temperatureUnit') as String?;
    return value == 'fahrenheit' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) => _box.put('temperatureUnit', unit.name);

  Map<String, dynamic>? getHomeLocation() {
    final raw = _box.get('homeLocation');
    return raw == null ? null : Map<String, dynamic>.from(raw as Map);
  }

  Future<void> setHomeLocation({required String name, required double latitude, required double longitude}) =>
      _box.put('homeLocation', {'name': name, 'latitude': latitude, 'longitude': longitude});
}
