import 'package:meta/meta.dart';

/// Access rule for a route prefix. Empty [anyOfRoles] / [anyOfPermissions] /
/// [allOfPermissions] means “no constraint on that dimension”.
@immutable
class RouteAccessRequirement {
  const RouteAccessRequirement({
    this.requiresAuthentication = false,
    this.anyOfRoles = const <String>{},
    this.anyOfPermissions = const <String>{},
    this.allOfPermissions = const <String>{},
    this.denyAll = false,
  });

  /// Shorthand for “signed-in user only”.
  const RouteAccessRequirement.authenticated()
      : requiresAuthentication = true,
        anyOfRoles = const <String>{},
        anyOfPermissions = const <String>{},
        allOfPermissions = const <String>{},
        denyAll = false;

  /// Used with [RouteAccessUnmatched.deny] — no user can satisfy.
  const RouteAccessRequirement.denyAll()
      : requiresAuthentication = false,
        anyOfRoles = const <String>{},
        anyOfPermissions = const <String>{},
        allOfPermissions = const <String>{},
        denyAll = true;

  final bool requiresAuthentication;
  final Set<String> anyOfRoles;
  final Set<String> anyOfPermissions;
  final Set<String> allOfPermissions;
  final bool denyAll;

  bool satisfiedBy({
    required bool isAuthenticated,
    required Set<String> roles,
    required Set<String> permissions,
  }) {
    if (denyAll) {
      return false;
    }
    if (requiresAuthentication && !isAuthenticated) {
      return false;
    }
    if (anyOfRoles.isNotEmpty &&
        !anyOfRoles.any(roles.contains)) {
      return false;
    }
    if (anyOfPermissions.isNotEmpty &&
        !anyOfPermissions.any(permissions.contains)) {
      return false;
    }
    if (allOfPermissions.isNotEmpty) {
      for (final String p in allOfPermissions) {
        if (!permissions.contains(p)) {
          return false;
        }
      }
    }
    return true;
  }
}
