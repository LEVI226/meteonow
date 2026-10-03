import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meteonow/core/config/app_config.dart';
import 'package:meteonow/core/network/auth_interceptor.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late Dio dio;
  late AuthInterceptor interceptor;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    dio = Dio(BaseOptions(baseUrl: 'https://example.supabase.co'));
    interceptor = AuthInterceptor(client, dio);
  });

  test('onRequest attaches the current access token and apikey header', () {
    final session = MockSession();
    when(() => session.accessToken).thenReturn('token-abc');
    when(() => auth.currentSession).thenReturn(session);

    final options = RequestOptions(path: '/rest/v1/favorites');
    final handler = MockRequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.headers['Authorization'], 'Bearer token-abc');
    expect(options.headers['apikey'], AppConfig.supabaseAnonKey);
    verify(() => handler.next(options)).called(1);
  });

  test('onRequest omits the Authorization header when there is no session', () {
    when(() => auth.currentSession).thenReturn(null);

    final options = RequestOptions(path: '/rest/v1/favorites');
    final handler = MockRequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.headers.containsKey('Authorization'), isFalse);
    verify(() => handler.next(options)).called(1);
  });

  test('onError passes non-401 errors straight through', () {
    final err = DioException(
      requestOptions: RequestOptions(path: '/rest/v1/favorites'),
      response: Response(requestOptions: RequestOptions(path: '/rest/v1/favorites'), statusCode: 500),
    );
    final handler = MockErrorInterceptorHandler();

    interceptor.onError(err, handler);

    verify(() => handler.next(err)).called(1);
    verifyNever(() => auth.refreshSession());
  });

  test('onError on a 401 with a failed refresh falls through to handler.next', () async {
    when(() => auth.refreshSession()).thenThrow(const AuthException('refresh failed'));
    final err = DioException(
      requestOptions: RequestOptions(path: '/rest/v1/favorites'),
      response: Response(requestOptions: RequestOptions(path: '/rest/v1/favorites'), statusCode: 401),
    );
    final handler = MockErrorInterceptorHandler();

    interceptor.onError(err, handler);
    await untilCalled(() => handler.next(err));

    verify(() => handler.next(err)).called(1);
  });
}
