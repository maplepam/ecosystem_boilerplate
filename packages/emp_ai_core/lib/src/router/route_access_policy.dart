import 'package:meta/meta.dart';

import 'route_access_requirement.dart';

/// When no [RouteAccessRule] matches the path.
enum RouteAccessUnmatched {
  /// Allow without checks (public marketing, hub, etc.).
  public,

  /// Require authentication.
  requireAuthentication,

  /// Treat as denied (redirect to [RouteAccessRedirectConfig.unauthorizedPath]).
  deny,
}

@immutable
class RouteAccessRule {
  const RouteAccessRule({
    required this.pathPrefix,
    required this.requirement,
  });

  /// Normalized: no trailing slash except root `/`.
  final String pathPrefix;

  final RouteAccessRequirement requirement;
}

@immutable
class RouteAccessPolicy {
  const RouteAccessPolicy({
    required this.rules,
    this.unmatched = RouteAccessUnmatched.public,
  });

  /// Longest matching prefix wins (most specific rule). Hosts list rules in any
  /// order; [requirementFor] sorts internally.
  final List<RouteAccessRule> rules;
  final RouteAccessUnmatched unmatched;

  /// Normalizes path for matching (leading slash, trim trailing slash).
  static String normalizePath(String path) => _normalize(path);

  RouteAccessRequirement? requirementFor(String rawPath) {
    final String path = _normalize(rawPath);
    if (path.isEmpty) {
      return null;
    }

    RouteAccessRule? best;
    int bestLen = -1;
    for (final RouteAccessRule r in rules) {
      final String prefix = _normalize(r.pathPrefix);
      if (prefix.isEmpty || prefix == '/') {
        if (best == null || prefix.length > bestLen) {
          best = r;
          bestLen = prefix.length;
        }
        continue;
      }
      if (path == prefix || path.startsWith('$prefix/')) {
        if (prefix.length > bestLen) {
          best = r;
          bestLen = prefix.length;
        }
      }
    }
    if (best != null) {
      return best.requirement;
    }
    return switch (unmatched) {
      RouteAccessUnmatched.public => null,
      RouteAccessUnmatched.requireAuthentication =>
        const RouteAccessRequirement.authenticated(),
      RouteAccessUnmatched.deny => const RouteAccessRequirement.denyAll(),
    };
  }

  static String _normalize(String path) {
    if (path.isEmpty) {
      return '/';
    }
    String p = path.trim();
    if (!p.startsWith('/')) {
      p = '/$p';
    }
    if (p.length > 1 && p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return p;
  }
}
