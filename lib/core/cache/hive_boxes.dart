import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  HiveBoxes._();

  static const weather = 'weather_cache';
  static const favorites = 'favorites_cache';
  static const settings = 'settings';

  static Future<void> openAll() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(weather);
    await Hive.openBox<Map>(favorites);
    await Hive.openBox(settings);
  }
}
