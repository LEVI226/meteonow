import 'package:flutter/material.dart';

import '../../../core/router/repository_scope.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../domain/app_settings.dart';
import 'settings_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _formatLastSync(DateTime? time) {
    if (time == null) return 'Never';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours} h ago';
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = RepositoryScope.of(context).authRepository;
    final settings = SettingsScope.of(context);
    final favoritesController = FavoritesControllerScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AnimatedBuilder(
        animation: Listenable.merge([settings, favoritesController]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Icon(Icons.person, color: colorScheme.onSecondaryContainer),
                  ),
                  title: Text(authRepository.currentUser?.email ?? 'Unknown'),
                  subtitle: const Text('Signed in with Supabase'),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatTile(label: 'Favorites', value: '${favoritesController.favorites.length}'),
                      _StatTile(label: 'Last sync', value: _formatLastSync(favoritesController.lastSyncedAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temperature unit', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      SegmentedButton<TemperatureUnit>(
                        segments: const [
                          ButtonSegment(value: TemperatureUnit.celsius, label: Text('°C')),
                          ButtonSegment(value: TemperatureUnit.fahrenheit, label: Text('°F')),
                        ],
                        selected: {settings.temperatureUnit},
                        onSelectionChanged: (selection) => settings.setTemperatureUnit(selection.first),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark theme'),
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => settings.toggleTheme(),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: authRepository.signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(foregroundColor: colorScheme.error, minimumSize: const Size.fromHeight(48)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
