import 'package:emp_ai_boilerplate_app/src/shell/auth/session/emp_ai_auth_session_reader.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_landing_auth_redirect.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_public_paths.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Optional first hop (maintenance, forced upgrade). Return `null` to fall
/// through to RBAC + auth redirect.
final boilerplateCustomRedirectProvider = Provider<GoRouterRedirect?>(
  (ref) => null,
);

final routeAccessRedirectConfigProvider =
    Provider<RouteAccessRedirectConfig>((ref) {
  final String login = ref.watch(authLoginPathProvider);
  final String unauthorized = ref.watch(authUnauthorizedPathProvider);
  return RouteAccessRedirectConfig(
    policy: ref.watch(routeAccessPolicyProvider),
    authReader: ref.watch(authSessionReaderProvider),
    loginPath: login,
    unauthorizedPath: unauthorized,
    publicPaths: ref.watch(boilerplatePublicPathsProvider),
  );
});

/// Composes [boilerplateCustomRedirectProvider] then route access / auth.
final boilerplateGoRouterRedirectProvider = Provider<GoRouterRedirect>(
  (ref) {
    final GoRouterRedirect? custom = ref.watch(boilerplateCustomRedirectProvider);
    final RouteAccessRedirectConfig accessConfig =
        ref.watch(routeAccessRedirectConfigProvider);
    final GoRouterRedirect access = createRouteAccessRedirect(accessConfig);
    return chainGoRouterRedirects(<GoRouterRedirect?>[
      ref.watch(boilerplateLandingAuthRedirectProvider),
      custom,
      access,
    ]);
  },
);
