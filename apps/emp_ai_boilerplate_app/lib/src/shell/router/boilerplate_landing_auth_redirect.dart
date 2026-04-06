import 'package:emp_ai_boilerplate_app/src/shell/auth/session/emp_ai_auth_session_reader.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart'
    show kBoilerplateHostMode;
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_public_paths.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sends unauthenticated users to [authLoginPathProvider] with `?redirect=`
/// (encoded target URI). Authenticated users hitting `/` or `/login` go to
/// the post-login home.
///
/// **Super-app only** — embedded / standalone hosts keep their existing entry.
final boilerplateLandingAuthRedirectProvider = Provider<GoRouterRedirect>((ref) {
  if (kBoilerplateHostMode != AppHostMode.superApp) {
    return (_, __) async => null;
  }
  return (context, state) async {
    final String path = RouteAccessPolicy.normalizePath(state.uri.path);
    final List<String> publicPaths = ref.read(boilerplatePublicPathsProvider);
    final String loginPath =
        RouteAccessPolicy.normalizePath(ref.read(authLoginPathProvider));
    final authReader = ref.read(authSessionReaderProvider);
    final session = await authReader.readSession();

    if (session.isAuthenticated) {
      if (path == '/') {
        return ref.read(authDefaultHomePathProvider);
      }
      if (path == loginPath) {
        return ref.read(authDefaultHomePathProvider);
      }
      return null;
    }

    if (_isUnderPublicPrefix(publicPaths, path)) {
      return null;
    }

    final StringBuffer target = StringBuffer(state.uri.path);
    if (state.uri.hasQuery) {
      target.write('?${state.uri.query}');
    }
    final String login = ref.read(authLoginPathProvider);
    final String enc = Uri.encodeComponent(target.toString());
    return '$login?redirect=$enc';
  };
});

bool _isUnderPublicPrefix(List<String> publicPaths, String normalizedPath) {
  for (final String raw in publicPaths) {
    final String p = RouteAccessPolicy.normalizePath(raw);
    if (normalizedPath == p || normalizedPath.startsWith('$p/')) {
      return true;
    }
  }
  return false;
}
