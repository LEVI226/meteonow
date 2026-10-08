import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/cache/hive_boxes.dart';
import 'core/config/app_config.dart';
import 'core/network/open_meteo_client.dart';
import 'core/network/supabase_rest_client.dart';
import 'core/router/app_router.dart';
import 'core/router/repository_scope.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository_impl.dart';
import 'features/auth/domain/app_user.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/favorites/data/favorites_local_data_source.dart';
import 'features/favorites/data/favorites_remote_data_source.dart';
import 'features/favorites/data/favorites_repository_impl.dart';
import 'features/favorites/domain/favorites_repository.dart';
import 'features/favorites/presentation/favorites_controller.dart';
import 'features/profile/data/settings_local_data_source.dart';
import 'features/profile/presentation/settings_controller.dart';
import 'features/weather/data/open_meteo_api.dart';
import 'features/weather/data/weather_local_data_source.dart';
import 'features/weather/data/weather_repository_impl.dart';
import 'features/weather/domain/weather_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.openAll();

  if (!AppConfig.isConfigured) {
    runApp(const _MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: AppConfig.supabaseUrl, publishableKey: AppConfig.supabaseAnonKey);
  final client = Supabase.instance.client;

  final authRepository = AuthRepositoryImpl(client);
  final weatherRepository = WeatherRepositoryImpl(
    OpenMeteoApi(createOpenMeteoClient()),
    WeatherLocalDataSource(Hive.box<Map>(HiveBoxes.weather)),
  );
  final favoritesRepository = FavoritesRepositoryImpl(
    FavoritesRemoteDataSource(createSupabaseRestClient(client, AppConfig.supabaseUrl), client),
    FavoritesLocalDataSource(Hive.box<Map>(HiveBoxes.favorites)),
  );
  final settingsController = SettingsController(SettingsLocalDataSource(Hive.box(HiveBoxes.settings)));

  runApp(MeteoNowApp(
    authRepository: authRepository,
    weatherRepository: weatherRepository,
    favoritesRepository: favoritesRepository,
    settingsController: settingsController,
  ));
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Missing Supabase configuration.\n\n'
              'Copy env.json.example to env.json, fill in your Supabase URL and anon key, '
              'and run with --dart-define-from-file=env.json.\n\nSee README.md for setup steps.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MeteoNowApp extends StatefulWidget {
  const MeteoNowApp({
    super.key,
    required this.authRepository,
    required this.weatherRepository,
    required this.favoritesRepository,
    required this.settingsController,
  });

  final AuthRepository authRepository;
  final WeatherRepository weatherRepository;
  final FavoritesRepository favoritesRepository;
  final SettingsController settingsController;

  @override
  State<MeteoNowApp> createState() => _MeteoNowAppState();
}

class _MeteoNowAppState extends State<MeteoNowApp> {
  late final _router = buildRouter(authRepository: widget.authRepository);
  late final _favoritesController = FavoritesController(widget.favoritesRepository);
  StreamSubscription<AppUser?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = widget.authRepository.authStateChanges().listen((user) {
      if (user == null) _favoritesController.clear();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryScope(
      authRepository: widget.authRepository,
      weatherRepository: widget.weatherRepository,
      favoritesRepository: widget.favoritesRepository,
      child: FavoritesControllerScope(
        controller: _favoritesController,
        child: SettingsScope(
          controller: widget.settingsController,
          child: AnimatedBuilder(
            animation: widget.settingsController,
            builder: (context, _) => MaterialApp.router(
              title: 'MétéoNow',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: widget.settingsController.themeMode,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}
