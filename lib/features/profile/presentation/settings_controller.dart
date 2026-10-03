import 'package:flutter/material.dart';

import '../data/settings_local_data_source.dart';
import '../domain/app_settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._local)
      : themeMode = _local.getThemeMode(),
        temperatureUnit = _local.getTemperatureUnit();

  final SettingsLocalDataSource _local;
  ThemeMode themeMode;
  TemperatureUnit temperatureUnit;

  Future<void> toggleTheme() async {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _local.setThemeMode(themeMode);
    notifyListeners();
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    temperatureUnit = unit;
    await _local.setTemperatureUnit(unit);
    notifyListeners();
  }
}

class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({super.key, required SettingsController controller, required super.child})
      : super(notifier: controller);

  static SettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'No SettingsScope found in context');
    return scope!.notifier!;
  }
}
