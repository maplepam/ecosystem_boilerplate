import 'dart:async';

import 'package:emp_ai_auth/core/shared/identity_infrastructure/entities/identity_introspect.dart';
import 'package:emp_ai_auth/emp_ai_auth.dart';
import 'package:emp_ai_auth/features/auth/domain/entities/state/auth_state.dart';
import 'package:emp_ai_auth/features/auth/shared/auth_providers.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/session/emp_ai_auth_session_reader.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/auth_navigation_refresh.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `true` when [EmpAuth] is configured via `--dart-define=AUTH_*` or
/// [BoilerplateEnvironmentCatalog] (flavor from `FLAVOR`).
bool boilerplateEmpAiAuthRuntimeConfigured() =>
    isEmpAiAuthBootstrapConfigured();

AuthSnapshot _authSnapshotFromEmpIdentity(
  IdentityInstrospect? identity,
) {
  if (identity == null) {
    return const AuthSnapshot(
      isAuthenticated: true,
      roles: <String>{},
      permissions: <String>{},
    );
  }
  final Set<String> roles = <String>{
    ...?identity.realmAccess?.roles,
  };
  final Set<String> permissions = <String>{};
  final String? scope = identity.scope;
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

AuthSnapshot _snapshotFromEmpState(AuthState state) {
  return state.maybeWhen(
    authenticated: _authSnapshotFromEmpIdentity,
    successExchangeAuthCode: _authSnapshotFromEmpIdentity,
    orElse: () => const AuthSnapshot(isAuthenticated: false),
  );
}

/// UI-facing session: same as [AuthSessionReader.readSession] for redirects.
///
/// Extend in tests — see [test/support/boilerplate_auth_test_overrides.dart].
final boilerplateAuthSnapshotProvider =
    NotifierProvider<BoilerplateAuthSnapshotNotifier, AuthSnapshot>(
  BoilerplateAuthSnapshotNotifier.new,
);

class BoilerplateAuthSnapshotNotifier extends Notifier<AuthSnapshot> {
  @override
  AuthSnapshot build() {
    ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) => unawaited(_refreshFromReader()),
    );
    final AuthNavigationRefreshListenable nav =
        ref.read(authNavigationRefreshListenableProvider);
    void listener() => unawaited(_refreshFromReader());
    nav.addListener(listener);
    ref.onDispose(() => nav.removeListener(listener));
    unawaited(_refreshFromReader());
    return _snapshotFromEmpState(ref.read(authNotifierProvider));
  }

  Future<void> _refreshFromReader() async {
    final AuthSnapshot next =
        await ref.read(authSessionReaderProvider).readSession();
    state = next;
  }
}

Future<void> boilerplateSignOut(WidgetRef ref) async {
  await EmpAuth().logout(ref);
  ref.read(authNavigationRefreshListenableProvider).notifyAuthChanged();
}
