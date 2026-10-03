import 'package:flutter/material.dart';

import '../data/settings_local_data_source.dart';
import '../domain/app_settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._local)
      : themeMode = _local.getThemeMode(),
        temperatureUnit = _local.getTemperatureUnit(),
        homeLocationName = _local.getHomeLocation()?['name'] as String? ?? 'Ouagadougou',
        homeLatitude = (_local.getHomeLocation()?['latitude'] as num?)?.toDouble() ?? 12.3714,
        homeLongitude = (_local.getHomeLocation()?['longitude'] as num?)?.toDouble() ?? -1.5197;

  final SettingsLocalDataSource _local;
  ThemeMode themeMode;
  TemperatureUnit temperatureUnit;
  String homeLocationName;
  double homeLatitude;
  double homeLongitude;

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

  Future<void> setHomeLocation({required String name, required double latitude, required double longitude}) async {
    homeLocationName = name;
    homeLatitude = latitude;
    homeLongitude = longitude;
    await _local.setHomeLocation(name: name, latitude: latitude, longitude: longitude);
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
