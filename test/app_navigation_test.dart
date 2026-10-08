import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:meteonow/core/router/app_router.dart';
import 'package:meteonow/core/router/repository_scope.dart';
import 'package:meteonow/core/theme/app_theme.dart';
import 'package:meteonow/features/auth/domain/app_user.dart';
import 'package:meteonow/features/auth/domain/auth_repository.dart';
import 'package:meteonow/features/favorites/domain/favorite_location.dart';
import 'package:meteonow/features/favorites/domain/favorites_repository.dart';
import 'package:meteonow/features/favorites/presentation/favorites_controller.dart';
import 'package:meteonow/features/profile/data/settings_local_data_source.dart';
import 'package:meteonow/features/profile/domain/app_settings.dart';
import 'package:meteonow/features/profile/presentation/settings_controller.dart';
import 'package:meteonow/features/weather/domain/geocoded_location.dart';
import 'package:meteonow/features/weather/domain/weather_repository.dart';
import 'package:meteonow/features/weather/domain/weather_snapshot.dart';
import 'package:meteonow/core/errors/app_failure.dart';
import 'package:meteonow/core/errors/result.dart';

class _FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  void emit(AppUser? user) {
    _currentUser = user;
    _controller.add(user);
  }

  @override
  Future<Result<AppUser>> signIn({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<Result<AppUser>> signUp({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<Result<void>> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> signOut() async {}
}

class _FakeWeatherRepository implements WeatherRepository {
  @override
  Future<Result<WeatherSnapshot>> getWeather({required double latitude, required double longitude}) async =>
      const Err(NetworkFailure());

  @override
  Future<Result<List<GeocodedLocation>>> searchLocations(String query) => throw UnimplementedError();
}

class _MockSettingsLocalDataSource extends Mock implements SettingsLocalDataSource {}

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Result<List<FavoriteLocation>>> getFavorites() async => const Ok(<FavoriteLocation>[]);

  @override
  Future<Result<void>> addFavorite(FavoriteLocation location) => throw UnimplementedError();

  @override
  Future<Result<void>> removeFavorite(String id) => throw UnimplementedError();

  @override
  Future<void> clearLocalCache() => throw UnimplementedError();
}

void main() {
  testWidgets('unauthenticated users are redirected to login; authenticated users see the shell', (tester) async {
    final auth = _FakeAuthRepository();
    final router = buildRouter(authRepository: auth);

    final settingsLocal = _MockSettingsLocalDataSource();
    when(() => settingsLocal.getThemeMode()).thenReturn(ThemeMode.system);
    when(() => settingsLocal.getTemperatureUnit()).thenReturn(TemperatureUnit.celsius);
    when(() => settingsLocal.getHomeLocation()).thenReturn(null);
    final settingsController = SettingsController(settingsLocal);
    final favoritesController = FavoritesController(_FakeFavoritesRepository());

    await tester.pumpWidget(
      RepositoryScope(
        authRepository: auth,
        weatherRepository: _FakeWeatherRepository(),
        favoritesRepository: _FakeFavoritesRepository(),
        child: FavoritesControllerScope(
          controller: favoritesController,
          child: SettingsScope(
            controller: settingsController,
            child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);

    auth.emit(const AppUser(id: 'user-1', email: 'yannick@example.com'));
    await tester.pumpAndSettle();

    expect(find.text('Ouagadougou'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search for a city to see its current weather.'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Favorites'));
    await tester.pumpAndSettle();
    expect(
      find.text('No favorites yet. Search for a city and tap the bookmark icon to save it here.'),
      findsOneWidget,
    );
  });
}
