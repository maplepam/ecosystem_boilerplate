import 'package:dio/dio.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/emp_ai_auth_token_refresh_providers.dart';
import 'package:emp_ai_boilerplate_app/src/config/application_host_profile_provider.dart';
import 'package:emp_ai_boilerplate_app/src/network/boilerplate_auth_header_interceptor.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Official host [Dio] from [HostNetwork]. Base URL prefers
/// [ApplicationHostProfile.apiBaseUrl] (`--dart-define=API_BASE_URL`).
///
/// Interceptors: bearer from storage (no refresh before send), then
/// [TokenRefreshInterceptor] on **401** to refresh via [CoreTokenRefreshService]
/// and retry. Skipping a proactive pre-request refresh keeps **navigation and
/// route transitions** from waiting on the token endpoint; the first API call
/// may get **401** then refresh + retry.
final boilerplateDioProvider = Provider<Dio>(
  (ref) {
    final String base = ref.watch(applicationHostProfileProvider).apiBaseUrl ??
        'https://api.example.com';
    return HostNetwork.createDio(
      baseUrl: base,
      interceptors: <Interceptor>[
        BoilerplateAuthHeaderInterceptor(
          ref.watch(empAiAuthTokenRefreshAdapterProvider),
        ),
        ref.watch(empAiAuthTokenRefreshInterceptorProvider),
      ],
    );
  },
);
