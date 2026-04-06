import 'package:dio/dio.dart';
import 'package:emp_ai_auth/core/shared/utils/token_refresh/token_refresh_adapter.dart';

/// Attaches `Authorization: Bearer` from [TokenRefreshAdapter.fetchStoredCredentials].
///
/// Place **before** [TokenRefreshInterceptor] so outbound calls are authenticated
/// and 401s can trigger refresh + retry.
final class BoilerplateAuthHeaderInterceptor extends Interceptor {
  BoilerplateAuthHeaderInterceptor(this._adapter);

  final TokenRefreshAdapter _adapter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final TokenData? stored = await _adapter.fetchStoredCredentials();
    final String? token = stored?.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
