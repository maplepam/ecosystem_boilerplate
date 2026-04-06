import 'package:emp_ai_boilerplate_app/src/shell/auth/session/emp_ai_auth_session_reader.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const AuthSnapshot kBoilerplateTestAuthSnapshot = AuthSnapshot(
  isAuthenticated: true,
  roles: <String>{'employee'},
  permissions: <String>{'read:samples'},
);

/// Widget / integration tests without Keycloak: pretend the user is signed in
/// so [authSessionReaderProvider], route redirects, and shell chrome match a
/// real session.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(
///   ProviderScope(
///     overrides: boilerplateAuthenticatedTestOverrides(),
///     child: const BoilerplateApp(),
///   ),
/// );
/// ```
List<Override> boilerplateAuthenticatedTestOverrides() {
  return <Override>[
    authSessionReaderProvider.overrideWithValue(
      const StaticAuthSessionReader(snapshot: kBoilerplateTestAuthSnapshot),
    ),
    boilerplateAuthSnapshotProvider.overrideWith(
      _TestAuthenticatedSnapshotNotifier.new,
    ),
  ];
}

final class _TestAuthenticatedSnapshotNotifier
    extends BoilerplateAuthSnapshotNotifier {
  @override
  AuthSnapshot build() => kBoilerplateTestAuthSnapshot;
}
