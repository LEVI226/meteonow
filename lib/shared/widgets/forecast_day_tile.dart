import 'package:flutter/material.dart';

import '../../features/profile/domain/app_settings.dart';
import '../weather_code_mapper.dart';

class ForecastDayTile extends StatelessWidget {
  const ForecastDayTile({
    super.key,
    required this.label,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.unit,
  });

  final String label;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final TemperatureUnit unit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: textTheme.labelLarge)),
          Icon(weatherIcon(weatherCode), color: colorScheme.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(child: Text(weatherLabel(weatherCode), style: textTheme.bodySmall)),
          Text('${unit.convert(maxTemperature).round()}°', style: textTheme.labelLarge),
          const SizedBox(width: 12),
          Text(
            '${unit.convert(minTemperature).round()}°',
            style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
