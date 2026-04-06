import 'package:dio/dio.dart';
import 'network_stack_config.dart';
import 'package:flutter/foundation.dart';

/// Thin helpers on top of [NetworkStackConfig] — one place for host wiring.
@immutable
abstract final class HostNetwork {
  const HostNetwork._();

  /// Normalized base URL (trailing `/` stripped).
  static String normalizeBaseUrl(String baseUrl) {
    final String t = baseUrl.trim();
    if (t.isEmpty) {
      return '';
    }
    return t.endsWith('/') ? t.substring(0, t.length - 1) : t;
  }

  /// Opinionated [Dio] for REST JSON APIs: timeouts, optional interceptors,
  /// debug logging in [kDebugMode] (via [NetworkStackConfig]).
  static Dio createDio({
    required String baseUrl,
    List<Interceptor> interceptors = const <Interceptor>[],
    Map<String, dynamic> headers = const <String, dynamic>{},
  }) {
    final String base = normalizeBaseUrl(baseUrl);
    return NetworkStackConfig(
      baseUrl: base.isEmpty ? 'https://invalid.local' : base,
      interceptors: interceptors,
      headers: headers,
    ).build();
  }
}
