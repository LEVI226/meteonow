import 'package:flutter/widgets.dart';

import '../../features/auth/domain/auth_repository.dart';
import '../../features/favorites/domain/favorites_repository.dart';
import '../../features/weather/domain/weather_repository.dart';

class RepositoryScope extends InheritedWidget {
  const RepositoryScope({
    super.key,
    required this.authRepository,
    required this.weatherRepository,
    required this.favoritesRepository,
    required super.child,
  });

  final AuthRepository authRepository;
  final WeatherRepository weatherRepository;
  final FavoritesRepository favoritesRepository;

  static RepositoryScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RepositoryScope>();
    assert(scope != null, 'No RepositoryScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(RepositoryScope oldWidget) => false;
}
