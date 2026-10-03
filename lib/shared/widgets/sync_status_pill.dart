import 'package:flutter/material.dart';

enum SyncStatus { live, cached, offline }

class SyncStatusPill extends StatelessWidget {
  const SyncStatusPill({super.key, required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (label, color, icon) = switch (status) {
      SyncStatus.live => ('Live', colorScheme.tertiary, Icons.circle),
      SyncStatus.cached => ('Cached', Colors.amber.shade800, Icons.schedule),
      SyncStatus.offline => ('Offline', colorScheme.error, Icons.wifi_off),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
