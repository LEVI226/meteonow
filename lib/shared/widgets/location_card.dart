import 'package:flutter/material.dart';

import '../weather_code_mapper.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.temperature,
    this.weatherCode,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final String name;
  final String subtitle;
  final double? temperature;
  final int? weatherCode;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  weatherCode != null ? weatherIcon(weatherCode!) : Icons.location_on,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: textTheme.titleMedium),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (temperature != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${temperature!.round()}°',
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w300),
                  ),
                ),
              IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? colorScheme.primary : colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
