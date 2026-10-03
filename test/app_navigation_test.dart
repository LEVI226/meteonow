import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meteonow/core/router/app_router.dart';
import 'package:meteonow/core/router/repository_scope.dart';
import 'package:meteonow/core/theme/app_theme.dart';
import 'package:meteonow/features/auth/domain/app_user.dart';
import 'package:meteonow/features/auth/domain/auth_repository.dart';
import 'package:meteonow/features/favorites/domain/favorite_location.dart';
import 'package:meteonow/features/favorites/domain/favorites_repository.dart';
import 'package:meteonow/features/weather/domain/geocoded_location.dart';
import 'package:meteonow/features/weather/domain/weather_repository.dart';
import 'package:meteonow/features/weather/domain/weather_snapshot.dart';
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
  Future<Result<WeatherSnapshot>> getWeather({required double latitude, required double longitude}) =>
      throw UnimplementedError();

  @override
  Future<Result<List<GeocodedLocation>>> searchLocations(String query) => throw UnimplementedError();
}

class _FakeFavoritesRepository implements FavoritesRepository {
  @override
  Future<Result<List<FavoriteLocation>>> getFavorites() => throw UnimplementedError();

  @override
  Future<Result<void>> addFavorite(FavoriteLocation location) => throw UnimplementedError();

  @override
  Future<Result<void>> removeFavorite(String id) => throw UnimplementedError();
}

void main() {
  testWidgets('unauthenticated users are redirected to login; authenticated users see the shell', (tester) async {
    final auth = _FakeAuthRepository();
    final router = buildRouter(authRepository: auth);

    await tester.pumpWidget(
      RepositoryScope(
        authRepository: auth,
        weatherRepository: _FakeWeatherRepository(),
        favoritesRepository: _FakeFavoritesRepository(),
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('login-screen-stub'), findsOneWidget);

    auth.emit(const AppUser(id: 'user-1', email: 'yannick@example.com'));
    await tester.pumpAndSettle();

    expect(find.text('home-screen-stub'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Search'));
    await tester.pumpAndSettle();
    expect(find.text('search-screen-stub'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('favorites-screen-stub'), findsOneWidget);
  });
}
