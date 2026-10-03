import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:meteonow/core/errors/result.dart';
import 'package:meteonow/features/weather/data/open_meteo_api.dart';
import 'package:meteonow/features/weather/data/weather_local_data_source.dart';
import 'package:meteonow/features/weather/data/weather_repository_impl.dart';
import 'package:meteonow/features/weather/domain/current_weather.dart';
import 'package:meteonow/features/weather/domain/weather_snapshot.dart';

class MockOpenMeteoApi extends Mock implements OpenMeteoApi {}

class MockWeatherLocalDataSource extends Mock implements WeatherLocalDataSource {}

WeatherSnapshot _snapshot({bool isFromCache = false}) => WeatherSnapshot(
      current: CurrentWeather(
        temperature: 28.0,
        apparentTemperature: 30.0,
        humidity: 65,
        windSpeed: 14.0,
        pressure: 1012.0,
        visibility: 23000.0,
        weatherCode: 2,
        isFromCache: isFromCache,
      ),
      hourly: const [],
      daily: const [],
    );

void main() {
  late MockOpenMeteoApi api;
  late MockWeatherLocalDataSource local;
  late WeatherRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(WeatherSnapshot(
      current: CurrentWeather(
        temperature: 0.0,
        apparentTemperature: 0.0,
        humidity: 0,
        windSpeed: 0.0,
        pressure: 0.0,
        visibility: 0.0,
        weatherCode: 0,
      ),
      hourly: const [],
      daily: const [],
    ));
  });

  setUp(() {
    api = MockOpenMeteoApi();
    local = MockWeatherLocalDataSource();
    repository = WeatherRepositoryImpl(api, local);
  });

  test('getWeather caches a successful fetch and returns it live', () async {
    when(() => api.fetchForecast(latitude: any(named: 'latitude'), longitude: any(named: 'longitude')))
        .thenAnswer((_) async => _snapshot());
    when(() => local.cacheWeather(any(), any())).thenAnswer((_) async {});

    final result = await repository.getWeather(latitude: 12.37, longitude: -1.52);

    expect(result, isA<Ok<WeatherSnapshot>>());
    final snapshot = (result as Ok<WeatherSnapshot>).value;
    expect(snapshot.current.isFromCache, isFalse);
    verify(() => local.cacheWeather('12.37,-1.52', any())).called(1);
  });

  test('getWeather falls back to the cache and marks it isFromCache on a network error', () async {
    when(() => api.fetchForecast(latitude: any(named: 'latitude'), longitude: any(named: 'longitude')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '/forecast')));
    when(() => local.getCachedWeather(any())).thenReturn(_snapshot());

    final result = await repository.getWeather(latitude: 12.37, longitude: -1.52);

    expect(result, isA<Ok<WeatherSnapshot>>());
    final snapshot = (result as Ok<WeatherSnapshot>).value;
    expect(snapshot.current.isFromCache, isTrue);
  });

  test('getWeather returns a NetworkFailure when the network fails and there is no cache', () async {
    when(() => api.fetchForecast(latitude: any(named: 'latitude'), longitude: any(named: 'longitude')))
        .thenThrow(DioException(requestOptions: RequestOptions(path: '/forecast')));
    when(() => local.getCachedWeather(any())).thenReturn(null);

    final result = await repository.getWeather(latitude: 12.37, longitude: -1.52);

    expect(result, isA<Err<WeatherSnapshot>>());
  });
}
