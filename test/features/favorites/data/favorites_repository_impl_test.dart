import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteonow/core/errors/result.dart';
import 'package:meteonow/features/favorites/data/favorites_local_data_source.dart';
import 'package:meteonow/features/favorites/data/favorites_remote_data_source.dart';
import 'package:meteonow/features/favorites/data/favorites_repository_impl.dart';
import 'package:meteonow/features/favorites/domain/favorite_location.dart';

class MockFavoritesRemoteDataSource extends Mock implements FavoritesRemoteDataSource {}

class MockFavoritesLocalDataSource extends Mock implements FavoritesLocalDataSource {}

const _paris = FavoriteLocation(
  id: 'fav-1',
  name: 'Paris',
  country: 'France',
  admin1: 'Ile-de-France',
  latitude: 48.85,
  longitude: 2.35,
);

void main() {
  late MockFavoritesRemoteDataSource remote;
  late MockFavoritesLocalDataSource local;
  late FavoritesRepositoryImpl repository;

  setUp(() {
    remote = MockFavoritesRemoteDataSource();
    local = MockFavoritesLocalDataSource();
    repository = FavoritesRepositoryImpl(remote, local);
  });

  test('getFavorites fetches remotely and mirrors the result locally', () async {
    when(() => remote.fetchFavorites()).thenAnswer((_) async => [_paris]);
    when(() => local.saveAll(any())).thenAnswer((_) async {});

    final result = await repository.getFavorites();

    expect(result, isA<Ok<List<FavoriteLocation>>>());
    expect((result as Ok<List<FavoriteLocation>>).value, [_paris]);
    verify(() => local.saveAll([_paris])).called(1);
  });

  test('getFavorites falls back to the local mirror when the remote call fails', () async {
    when(() => remote.fetchFavorites()).thenThrow(Exception('network down'));
    when(() => local.getAll()).thenReturn([_paris]);

    final result = await repository.getFavorites();

    expect(result, isA<Ok<List<FavoriteLocation>>>());
    expect((result as Ok<List<FavoriteLocation>>).value, [_paris]);
  });

  test('getFavorites returns a CacheFailure when remote fails and there is no local mirror', () async {
    when(() => remote.fetchFavorites()).thenThrow(Exception('network down'));
    when(() => local.getAll()).thenReturn([]);

    final result = await repository.getFavorites();

    expect(result, isA<Err<List<FavoriteLocation>>>());
  });

  test('addFavorite writes through remote then mirrors the saved row locally', () async {
    when(() => remote.insertFavorite(_paris)).thenAnswer((_) async => _paris);
    when(() => local.save(_paris)).thenAnswer((_) async {});

    final result = await repository.addFavorite(_paris);

    expect(result, isA<Ok<void>>());
    verify(() => remote.insertFavorite(_paris)).called(1);
    verify(() => local.save(_paris)).called(1);
  });
}
