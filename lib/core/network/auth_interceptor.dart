import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._client, this._dio);

  final SupabaseClient _client;
  final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['apikey'] = AppConfig.supabaseAnonKey;
    final token = _client.auth.currentSession?.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final alreadyRetried = err.requestOptions.extra['retried'] == true;
    if (err.response?.statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }
    try {
      final refreshed = await _client.auth.refreshSession();
      if (refreshed.session == null) {
        handler.next(err);
        return;
      }
      final retryOptions = err.requestOptions..extra['retried'] = true;
      final retryResponse = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      handler.next(err);
    }
  }
}
