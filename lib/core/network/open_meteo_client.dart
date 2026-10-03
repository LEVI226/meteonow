import 'package:dio/dio.dart';

Dio createOpenMeteoClient() {
  return Dio(BaseOptions(connectTimeout: const Duration(seconds: 10), receiveTimeout: const Duration(seconds: 10)));
}
