import 'package:flutter/foundation.dart';

/// Project GitHub Pages lives under `https://<user>.github.io/<repo>/`, not at
/// the user-site root. [EmpAuth] defaults post-logout navigation to `/`, which
/// becomes `https://<user>.github.io/` and 404s for this deployment.
///
/// Returns a hash-router home URL only for [maplepam.github.io]; other hosts
/// return `null` so [EmpAuth] keeps its default.
String? resolveMaplepamGitHubPagesLogoutUrl() {
  if (!kIsWeb) {
    return null;
  }
  final Uri u = Uri.base;
  if (u.host != 'maplepam.github.io') {
    return null;
  }
  final List<String> segs =
      u.pathSegments.where((String s) => s.isNotEmpty).toList();
  if (segs.isNotEmpty) {
    return '${u.origin}/${segs.first}/#/';
  }
  return '${u.origin}/ecosystem_boilerplate/#/';
}
