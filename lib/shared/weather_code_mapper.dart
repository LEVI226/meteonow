import 'package:flutter/material.dart';

/// Maps Open-Meteo's WMO weather codes (https://open-meteo.com/en/docs, "WMO Weather interpretation codes").
IconData weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code == 1 || code == 2) return Icons.wb_cloudy;
  if (code == 3) return Icons.cloud;
  if (code >= 45 && code <= 48) return Icons.blur_on;
  if (code >= 51 && code <= 67) return Icons.grain;
  if (code >= 71 && code <= 77) return Icons.ac_unit;
  if (code >= 80 && code <= 82) return Icons.grain;
  if (code >= 85 && code <= 86) return Icons.ac_unit;
  if (code >= 95) return Icons.bolt;
  return Icons.cloud;
}

String weatherLabel(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code >= 45 && code <= 48) return 'Fog';
  if (code >= 51 && code <= 57) return 'Drizzle';
  if (code >= 61 && code <= 67) return 'Rain';
  if (code >= 71 && code <= 77) return 'Snow';
  if (code >= 80 && code <= 82) return 'Rain showers';
  if (code >= 85 && code <= 86) return 'Snow showers';
  if (code >= 95) return 'Thunderstorm';
  return 'Unknown';
}
