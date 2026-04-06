import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'redacting_log_interceptor.dart';

/// Creates a configured [Dio]. Add auth / logging interceptors from the app.
@immutable
class NetworkStackConfig {
  const NetworkStackConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout,
    this.interceptors = const <Interceptor>[],
    this.headers = const <String, dynamic>{},
    this.validateStatus,
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration? sendTimeout;
  final List<Interceptor> interceptors;
  final Map<String, dynamic> headers;
  final bool Function(int? status)? validateStatus;

  Dio build() {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: headers,
        validateStatus: validateStatus,
      ),
    );
    dio.interceptors.addAll(interceptors);
    if (kDebugMode) {
      dio.interceptors.add(
        RedactingLogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }
    return dio;
  }
}
