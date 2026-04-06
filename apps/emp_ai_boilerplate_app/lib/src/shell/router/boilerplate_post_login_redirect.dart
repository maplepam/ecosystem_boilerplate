import 'package:flutter/foundation.dart';

/// Shapes `?redirect=` targets for [GoRouter.go] after sign-in.
///
/// On GitHub Pages (`/repo-name/` + hash routing), the browser path segment
/// for the static site must not be treated as an in-app location (e.g.
/// `/ecosystem_boilerplate` has no matching [GoRoute]).
String sanitizeBoilerplatePostLoginRedirect(
  String? rawRedirect,
  String fallback,
) {
  if (rawRedirect == null) {
    return fallback;
  }
  final String trimmed = rawRedirect.trim();
  if (trimmed.isEmpty) {
    return fallback;
  }
  late final Uri uri;
  try {
    uri = trimmed.contains('://') || trimmed.startsWith('//')
        ? Uri.parse(trimmed)
        : Uri.parse(trimmed.startsWith('/') ? trimmed : '/$trimmed');
  } on FormatException {
    return fallback;
  }

  String path = uri.path;
  if (path.isEmpty || path == '/') {
    return fallback;
  }

  if (kIsWeb) {
    final List<String> baseSegs =
        Uri.base.pathSegments.where((String s) => s.isNotEmpty).toList();
    final List<String> pathSegs =
        uri.pathSegments.where((String s) => s.isNotEmpty).toList();
    if (baseSegs.isNotEmpty &&
        pathSegs.isNotEmpty &&
        pathSegs.first == baseSegs.first) {
      final List<String> rest = pathSegs.skip(1).toList();
      if (rest.isEmpty) {
        return fallback;
      }
      path = '/${rest.join('/')}';
    }
  }

  if (!_isBoilerplateRoutablePath(path)) {
    return fallback;
  }

  if (uri.hasQuery) {
    return '$path?${uri.query}';
  }
  return path;
}

bool _isBoilerplateRoutablePath(String path) {
  final List<String> segs =
      path.split('/').where((String s) => s.isNotEmpty).toList();
  if (segs.isEmpty) {
    return false;
  }
  const Set<String> roots = <String>{
    'main',
    'hub',
    'login',
    'unauthorized',
    'samples',
    'announcements',
    'resources',
    'dev',
    'demo',
  };
  return roots.contains(segs.first);
}
