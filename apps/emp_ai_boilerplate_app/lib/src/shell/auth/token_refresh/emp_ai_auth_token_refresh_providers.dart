import 'package:dio/dio.dart';
import 'package:emp_ai_auth/core/shared/interceptors/token_refresh_interceptor.dart';
import 'package:emp_ai_auth/core/shared/utils/token_refresh/core_token_refresh_service.dart';
import 'package:emp_ai_auth/core/shared/utils/token_refresh/token_refresh_adapter.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/emp_ai_auth_token_refresh_adapter.dart';
import 'package:emp_ai_boilerplate_app/src/config/application_host_profile_provider.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Host [TokenRefreshAdapter] for `emp_ai_auth`.
final empAiAuthTokenRefreshAdapterProvider = Provider<TokenRefreshAdapter>(
  (Ref ref) => EmpAiAuthTokenRefreshAdapter(ref),
);

/// Single [CoreTokenRefreshService] for the process — share across Dio and callers.
final coreTokenRefreshServiceProvider = Provider<CoreTokenRefreshService>(
  (Ref ref) {
    return CoreTokenRefreshService(
      ref.watch(empAiAuthTokenRefreshAdapterProvider),
    );
  },
);

/// 401 fallback: [TokenRefreshInterceptor] on [boilerplateDioProvider].
final empAiAuthTokenRefreshInterceptorProvider =
    Provider<TokenRefreshInterceptor>(
  (Ref ref) {
    final String base = ref.watch(applicationHostProfileProvider).apiBaseUrl ??
        'https://api.example.com';
    final String normalized = HostNetwork.normalizeBaseUrl(base);
    return TokenRefreshInterceptor(
      ref.watch(coreTokenRefreshServiceProvider),
      retryClientBaseOptions: BaseOptions(
        baseUrl: normalized.isEmpty ? 'https://invalid.local' : normalized,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  },
);
