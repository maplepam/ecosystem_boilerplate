import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_access_policy.dart';
import 'route_access_requirement.dart';

@immutable
class RouteAccessRedirectConfig {
  const RouteAccessRedirectConfig({
    required this.policy,
    required this.authReader,
    required this.loginPath,
    this.unauthorizedPath = '/unauthorized',
    this.publicPaths = const <String>['/login', '/unauthorized'],
  });

  final RouteAccessPolicy policy;
  final AuthSessionReader authReader;
  final String loginPath;
  final String unauthorizedPath;

  /// Paths that skip access checks entirely (normalized prefixes).
  final List<String> publicPaths;
}

/// [GoRouter] redirect: enforce [RouteAccessPolicy] using [AuthSessionReader].
GoRouterRedirect createRouteAccessRedirect(
  RouteAccessRedirectConfig config,
) {
  return (BuildContext context, GoRouterState state) async {
    final String path = RouteAccessPolicy.normalizePath(state.uri.path);

    if (_isPublic(config, path)) {
      return null;
    }

    final RouteAccessRequirement? req = config.policy.requirementFor(path);
    if (req == null) {
      return null;
    }

    if (req.denyAll) {
      return config.unauthorizedPath;
    }

    final AuthSnapshot snap = await config.authReader.readSession();

    if (req.requiresAuthentication && !snap.isAuthenticated) {
      return _loginWithReturn(config.loginPath, state.uri);
    }

    if (!req.satisfiedBy(
      isAuthenticated: snap.isAuthenticated,
      roles: snap.roles,
      permissions: snap.permissions,
    )) {
      if (!snap.isAuthenticated) {
        return _loginWithReturn(config.loginPath, state.uri);
      }
      return config.unauthorizedPath;
    }

    return null;
  };
}

bool _isPublic(RouteAccessRedirectConfig config, String normalizedPath) {
  for (final String raw in config.publicPaths) {
    final String p = RouteAccessPolicy.normalizePath(raw);
    if (normalizedPath == p || normalizedPath.startsWith('$p/')) {
      return true;
    }
  }
  return false;
}

String _loginWithReturn(String loginPath, Uri from) {
  final String base = loginPath.startsWith('/') ? loginPath : '/$loginPath';
  // Path + query only (not scheme/host). Full URI strings break post-login go()
  // when static hosting injects a repo basename into the browser path.
  final StringBuffer returnLoc = StringBuffer(from.path);
  if (from.hasQuery) {
    returnLoc.write('?${from.query}');
  }
  return '$base?redirect=${Uri.encodeComponent(returnLoc.toString())}';
}
