import 'package:flutter/material.dart';

class WeatherMetricChip extends StatelessWidget {
  const WeatherMetricChip({super.key, required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(value, style: textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
