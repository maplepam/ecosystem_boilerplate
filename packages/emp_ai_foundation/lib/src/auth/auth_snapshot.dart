import 'package:meta/meta.dart';

/// Point-in-time principal for route / feature checks. Produced by
/// [AuthSessionReader] implementations (Keycloak, Cognito, stubs).
@immutable
class AuthSnapshot {
  const AuthSnapshot({
    required this.isAuthenticated,
    this.roles = const <String>{},
    this.permissions = const <String>{},
  });

  final bool isAuthenticated;

  /// Role names from your IdP or app RBAC (e.g. `manager`, `employee`).
  final Set<String> roles;

  /// Fine-grained strings (e.g. `read:samples`, `orders:approve`).
  final Set<String> permissions;
}
