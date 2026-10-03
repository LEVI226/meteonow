import 'package:flutter/material.dart';

import '../../../core/errors/result.dart';
import '../../../core/router/repository_scope.dart';
import '../../../shared/weather_code_mapper.dart';
import '../../../shared/widgets/forecast_day_tile.dart';
import '../../../shared/widgets/sync_status_pill.dart';
import '../../../shared/widgets/weather_metric_chip.dart';
import '../../profile/domain/app_settings.dart';
import '../../profile/presentation/settings_controller.dart';
import '../domain/hourly_forecast.dart';
import '../domain/weather_snapshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Result<WeatherSnapshot>? _result;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_result == null) _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final settings = SettingsScope.of(context);
    final weatherRepository = RepositoryScope.of(context).weatherRepository;
    final result = await weatherRepository.getWeather(
      latitude: settings.homeLatitude,
      longitude: settings.homeLongitude,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  List<HourlyForecast> _upcomingHours(List<HourlyForecast> hourly) {
    final now = DateTime.now();
    final startIndex = hourly.indexWhere((h) => h.time.isAfter(now));
    return hourly.skip(startIndex == -1 ? 0 : startIndex).take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(settings.homeLocationName),
        actions: [
          IconButton(onPressed: _isLoading ? null : _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading || _result == null
          ? const Center(child: CircularProgressIndicator())
          : switch (_result!) {
              Ok<WeatherSnapshot>(:final value) => RefreshIndicator(
                  onRefresh: _load,
                  child: _HomeContent(snapshot: value, unit: settings.temperatureUnit, upcoming: _upcomingHours(value.hourly)),
                ),
              Err<WeatherSnapshot>(:final failure) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off, size: 40),
                        const SizedBox(height: 12),
                        Text(failure.message, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: _load, child: const Text('Try again')),
                      ],
                    ),
                  ),
                ),
            },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.snapshot, required this.unit, required this.upcoming});

  final WeatherSnapshot snapshot;
  final TemperatureUnit unit;
  final List<HourlyForecast> upcoming;

  @override
  Widget build(BuildContext context) {
    final current = snapshot.current;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SyncStatusPill(status: current.isFromCache ? SyncStatus.cached : SyncStatus.live),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${unit.convert(current.temperature).round()}', style: textTheme.displayMedium),
                            Text('°', style: textTheme.displayMedium?.copyWith(color: colorScheme.primary)),
                          ],
                        ),
                        Text(weatherLabel(current.weatherCode), style: textTheme.titleMedium),
                        Text(
                          'Feels like ${unit.convert(current.apparentTemperature).round()}°',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    Icon(weatherIcon(current.weatherCode), size: 64, color: colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.6,
                  children: [
                    WeatherMetricChip(icon: Icons.water_drop_outlined, label: 'Humidity', value: '${current.humidity}%'),
                    WeatherMetricChip(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${current.windSpeed.round()} km/h',
                    ),
                    WeatherMetricChip(icon: Icons.speed, label: 'Pressure', value: '${current.pressure.round()} hPa'),
                    WeatherMetricChip(
                      icon: Icons.visibility_outlined,
                      label: 'Visibility',
                      value: '${(current.visibility / 1000).toStringAsFixed(1)} km',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text("Today's forecast", style: textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: upcoming.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final hour = upcoming[index];
              return Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: colorScheme.surface, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${hour.time.hour.toString().padLeft(2, '0')}:00', style: textTheme.labelSmall),
                    Icon(weatherIcon(hour.weatherCode), color: colorScheme.primary),
                    Text('${unit.convert(hour.temperature).round()}°', style: textTheme.titleSmall),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text('5-day forecast', style: textTheme.titleMedium),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                for (final day in snapshot.daily)
                  ForecastDayTile(
                    label: _dayLabel(day.date),
                    weatherCode: day.weatherCode,
                    maxTemperature: day.maxTemperature,
                    minTemperature: day.minTemperature,
                    unit: unit,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }
}
