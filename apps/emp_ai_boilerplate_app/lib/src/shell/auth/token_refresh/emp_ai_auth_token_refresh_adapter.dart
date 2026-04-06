import 'package:dartz/dartz.dart' show Either, Left, Right, Unit;
import 'package:emp_ai_auth/core/shared/exceptions/http_exception.dart';
import 'package:emp_ai_auth/core/shared/utils/token_refresh/token_refresh_adapter.dart';
import 'package:emp_ai_auth/emp_ai_auth.dart';
import 'package:emp_ai_auth/features/auth/shared/auth_providers.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/auth_navigation_refresh.dart';
import 'package:emp_ai_boilerplate_app/src/platform/analytics/boilerplate_analytics_backends_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oauth2/oauth2.dart' as oauth2;

/// Host adapter for Keycloak / OAuth via `emp_ai_auth` (production-shaped).
///
/// Analytics go through [boilerplateAnalyticsSinkProvider] so Mixpanel + Firebase
/// stay consistent without hard-coding one vendor here.
final class EmpAiAuthTokenRefreshAdapter implements TokenRefreshAdapter {
  EmpAiAuthTokenRefreshAdapter(this._ref);

  final Ref _ref;

  @override
  Future<TokenData?> fetchStoredCredentials() async {
    final credentials =
        await _ref.read(authNotifierProvider.notifier).fetchStoredCredentials();
    if (credentials == null) {
      return null;
    }
    return TokenData(
      accessToken: credentials.accessToken,
      refreshToken: credentials.refreshToken,
      expiration: credentials.expiration,
    );
  }

  @override
  Future<TokenRefreshResult> performRefresh({
    required bool forceRefresh,
  }) async {
    TokenRefreshError? capturedError;
    try {
      final credentials =
          await _ref.read(authNotifierProvider.notifier).getSignedInCredentials(
                forceRefresh: forceRefresh,
                onError: (AppException e) async {
                  capturedError = TokenRefreshError(
                    message: e.message?.toString() ?? 'Unknown error',
                    statusCode: e.statusCode,
                    identifier: e.identifier ?? 'Unknown identifier',
                  );
                },
                onSuccess: (oauth2.Credentials creds) {
                  debugPrint('[EmpAiAuthTokenRefresh] succeeded');
                },
              );

      if (capturedError != null) {
        return TokenRefreshResult.error(capturedError!);
      }
      if (credentials == null) {
        return const TokenRefreshResult.error(
          TokenRefreshError(
            message: 'No credentials returned',
            statusCode: null,
            identifier: 'No credentials',
          ),
        );
      }
      return TokenRefreshResult.success(
        TokenData(
          accessToken: credentials.accessToken,
          refreshToken: credentials.refreshToken,
          expiration: credentials.expiration,
        ),
      );
    } catch (e) {
      debugPrint('[EmpAiAuthTokenRefresh] exception during refresh: $e');
      return TokenRefreshResult.error(
        TokenRefreshError(
          message: e.toString(),
          statusCode: null,
          identifier: 'Exception: ${e.runtimeType}',
        ),
      );
    }
  }

  @override
  void trackError({
    required String errorMessage,
    required int? statusCode,
    required String? identifier,
    required String? profileId,
  }) {
    _ref.read(boilerplateAnalyticsSinkProvider).track(
          'query_credentials_error',
          <String, Object?>{
            'error': errorMessage,
            'identifier': identifier,
            'status_code': statusCode,
            'profile_id': profileId,
            'backend': 'emp_ai_auth',
          },
        );
  }

  @override
  void handleLogout() {
    EmpAuth().logout(_ref);
    _ref.read(authNavigationRefreshListenableProvider).notifyAuthChanged();
  }

  @override
  Future<void> handleClearToken() async {
    await _ref.read(authNotifierProvider.notifier).clearToken();
  }

  @override
  void handleSuccess(TokenData token) {
    _ref.read(boilerplateAnalyticsSinkProvider).track(
          'token_refresh_successful',
          <String, Object?>{
            'expiration': token.expiration?.toUtc().toIso8601String(),
            'profile_id': getProfileId(),
            'backend': 'emp_ai_auth',
          },
        );
  }

  @override
  String? getProfileId() {
    final String? username =
        _ref.read(authNotifierProvider.notifier).identity?.preferredUsername;
    if (username != null && username.isNotEmpty) {
      return username;
    }
    return null;
  }

  @override
  Future<Either<AppException, TokenData>> performSilentLogin() async {
    debugPrint('[EmpAiAuthTokenRefresh] silentLogin (shouldRedirect: false)');
    final Either<AppException, Unit> silentLoginResult =
        await _ref.read(authNotifierProvider.notifier).silentLogin(
              shouldRedirect: false,
            );

    return silentLoginResult.fold<Future<Either<AppException, TokenData>>>(
      (AppException e) async => Left<AppException, TokenData>(e),
      (_) async {
        AppException? capturedError;
        final oauth2.Credentials? refreshedCredentials =
            await _ref.read(authNotifierProvider.notifier).getSignedInCredentials(
                  forceRefresh: false,
                  onError: (AppException e) async {
                    capturedError = e;
                  },
                  onSuccess: (_) {},
                );

        if (capturedError != null) {
          return Left<AppException, TokenData>(capturedError!);
        }
        if (refreshedCredentials == null) {
          return Left<AppException, TokenData>(
            AppException(
              message: 'No credentials returned after silent login',
              statusCode: null,
              identifier: 'No credentials after silent login',
            ),
          );
        }
        return Right<AppException, TokenData>(
          TokenData(
            accessToken: refreshedCredentials.accessToken,
            refreshToken: refreshedCredentials.refreshToken,
            expiration: refreshedCredentials.expiration,
          ),
        );
      },
    );
  }
}
