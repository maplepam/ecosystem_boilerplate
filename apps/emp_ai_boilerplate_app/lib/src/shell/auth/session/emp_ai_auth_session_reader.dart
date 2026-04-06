import 'package:emp_ai_auth/core/shared/identity_infrastructure/entities/identity_introspect.dart';
import 'package:emp_ai_auth/core/shared/utils/access_token_jwt_rbac.dart';
import 'package:emp_ai_auth/features/auth/domain/entities/state/auth_notifier.dart';
import 'package:emp_ai_auth/features/auth/domain/entities/state/auth_state.dart';
import 'package:emp_ai_auth/features/auth/shared/auth_providers.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Maps `emp_ai_auth` state into [AuthSnapshot] for [RouteAccessPolicy].
///
/// **No token refresh** here — [readSession] must stay cheap for GoRouter
/// redirects. Refresh happens when calling APIs ([getSignedInCredentials] /
/// 401 interceptors).
///
/// When only local credentials exist (no `authenticated` [AuthState] yet),
/// roles/permissions come from **persisted identity** via
/// [AuthNotifier.fetchStoredIdentity], or from a **JWT access token** payload
/// ([AccessTokenJwtRbac]) if identity is missing.
final class EmpAiAuthSessionReader implements AuthSessionReader {
  EmpAiAuthSessionReader(this._ref);

  final Ref _ref;

  @override
  Future<AuthSnapshot> readSession() async {
    final AuthNotifier notifier = _ref.read(authNotifierProvider.notifier);
    final AuthState state = _ref.read(authNotifierProvider);

    final AuthSnapshot? fromAuthFlow = state.maybeWhen(
      authenticated: _snapshotFromIdentity,
      successExchangeAuthCode: _snapshotFromIdentity,
      orElse: () => null,
    );
    if (fromAuthFlow != null) {
      return fromAuthFlow;
    }

    final bool hasLocalSession = await notifier.hasLocalSessionForRouting();
    if (!hasLocalSession) {
      return const AuthSnapshot(isAuthenticated: false);
    }
    final IdentityInstrospect? storedIdentity =
        await notifier.fetchStoredIdentity();
    if (storedIdentity != null) {
      return _snapshotFromIdentity(storedIdentity);
    }

    final String? accessToken = await notifier.fetchStoredAccessToken();
    final AccessTokenJwtRbac? jwt = accessToken != null
        ? AccessTokenJwtRbac.parse(accessToken)
        : null;
    if (jwt != null) {
      return AuthSnapshot(
        isAuthenticated: true,
        roles: jwt.roles,
        permissions: jwt.permissions,
      );
    }

    return _snapshotFromIdentity(null);
  }

  static AuthSnapshot _snapshotFromIdentity(IdentityInstrospect? id) {
    if (id == null) {
      return const AuthSnapshot(
        isAuthenticated: true,
        roles: <String>{},
        permissions: <String>{},
      );
    }
    final Set<String> roles = <String>{
      ...?id.realmAccess?.roles,
    };
    final Set<String> permissions = <String>{};
    final String? scope = id.scope;
    if (scope != null && scope.isNotEmpty) {
      permissions.addAll(
        scope.split(RegExp(r'\s+')).where((String s) => s.isNotEmpty),
      );
    }
    return AuthSnapshot(
      isAuthenticated: true,
      roles: roles,
      permissions: permissions,
    );
  }
}

/// [EmpAiAuthSessionReader] — same source as route redirects (`readSession`).
final authSessionReaderProvider = Provider<AuthSessionReader>(
  (Ref ref) => EmpAiAuthSessionReader(ref),
);
