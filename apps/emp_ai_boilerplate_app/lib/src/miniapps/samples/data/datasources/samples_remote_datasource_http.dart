import 'package:dio/dio.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/data/datasources/samples_remote_datasource.dart';

/// Real HTTP GET using the host [Dio] (same interceptors as production APIs).
///
/// Default URL is [jsonPlaceholderPost1]; pass a different path when testing
/// your own backend (still uses [Dio] base URL if you pass a relative path).
final class SamplesRemoteDataSourceHttp implements SamplesRemoteDataSource {
  const SamplesRemoteDataSourceHttp(
    this._dio, {
    this.absoluteUrl = jsonPlaceholderPost1,
  });

  final Dio _dio;

  /// Public read-only JSON API for demos (no auth).
  static const String jsonPlaceholderPost1 =
      'https://jsonplaceholder.typicode.com/posts/1';

  /// Full URL or path (relative to [Dio.options.baseUrl] if not absolute).
  final String absoluteUrl;

  @override
  Future<String> fetchWelcomeMessage() async {
    final Response<dynamic> response = await _dio.get<dynamic>(absoluteUrl);
    final Object? data = response.data;
    if (data is Map<String, dynamic>) {
      final String? title = data['title'] as String?;
      if (title != null && title.isNotEmpty) {
        return 'Remote title: $title';
      }
    }
    return 'Remote response (unexpected shape): ${response.data}';
  }
}
