import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_interceptor.dart';

Dio createSupabaseRestClient(SupabaseClient client, String baseUrl) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Prefer': 'return=representation', 'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(AuthInterceptor(client, dio));
  return dio;
}
