import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Host-defined RBAC — adjust prefixes and claims per app or white-label.
///
/// Longest matching [RouteAccessRule.pathPrefix] wins (see [RouteAccessPolicy]).
final routeAccessPolicyProvider = Provider<RouteAccessPolicy>((ref) {
  return const RouteAccessPolicy(
    unmatched: RouteAccessUnmatched.requireAuthentication,
    rules: <RouteAccessRule>[
      RouteAccessRule(
        pathPrefix: '/main',
        requirement: RouteAccessRequirement.authenticated(),
      ),
      RouteAccessRule(
        pathPrefix: '/hub',
        requirement: RouteAccessRequirement.authenticated(),
      ),
      RouteAccessRule(
        pathPrefix: '/announcements',
        requirement: RouteAccessRequirement.authenticated(),
      ),
      RouteAccessRule(
        pathPrefix: '/resources',
        requirement: RouteAccessRequirement.authenticated(),
      ),
      RouteAccessRule(
        pathPrefix: '/samples',
        requirement: RouteAccessRequirement(),
      ),
    ],
  );
});

/// Login location depends on [AppHostMode] so embedded hosts keep auth under
/// the same path prefix as the mini-app shell.
final authLoginPathProvider = Provider<String>((ref) {
  switch (kBoilerplateHostMode) {
    case AppHostMode.embeddedMiniApp:
      return '/$kEmbeddedPathPrefix/login';
    case AppHostMode.superApp:
    case AppHostMode.standaloneMiniApp:
      return '/login';
  }
});

final authUnauthorizedPathProvider = Provider<String>((ref) {
  switch (kBoilerplateHostMode) {
    case AppHostMode.embeddedMiniApp:
      return '/$kEmbeddedPathPrefix/unauthorized';
    case AppHostMode.superApp:
    case AppHostMode.standaloneMiniApp:
      return '/unauthorized';
  }
});

/// Legacy path for “marketing” entry; super-app unauthenticated redirects now
/// use [authLoginPathProvider] with `?redirect=`. Kept for embedded prefix `/`.
final authLandingPathProvider = Provider<String>((ref) {
  switch (kBoilerplateHostMode) {
    case AppHostMode.embeddedMiniApp:
      return '/$kEmbeddedPathPrefix';
    case AppHostMode.superApp:
    case AppHostMode.standaloneMiniApp:
      return '/';
  }
});

/// Post-login default when `redirect` query is absent.
final authDefaultHomePathProvider = Provider<String>((ref) {
  switch (kBoilerplateHostMode) {
    case AppHostMode.embeddedMiniApp:
      return '/$kEmbeddedPathPrefix/home';
    case AppHostMode.superApp:
      return '/main/home';
    case AppHostMode.standaloneMiniApp:
      return '/home';
  }
});
