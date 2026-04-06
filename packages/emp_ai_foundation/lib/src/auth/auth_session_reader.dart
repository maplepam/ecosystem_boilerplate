import 'package:meta/meta.dart';

import 'auth_snapshot.dart';

/// Host supplies the implementation (real auth package, mock, or Riverpod
/// bridge). Keep this in foundation so `emp_ai_core` stays free of `emp_ai_auth`.
@immutable
abstract class AuthSessionReader {
  const AuthSessionReader();

  Future<AuthSnapshot> readSession();
}

/// Always unauthenticated — tests / minimal hosts.
final class UnauthenticatedAuthSessionReader extends AuthSessionReader {
  const UnauthenticatedAuthSessionReader();

  @override
  Future<AuthSnapshot> readSession() async => const AuthSnapshot(
        isAuthenticated: false,
      );
}

/// Always authenticated with optional fixed claims — local demos.
final class StaticAuthSessionReader extends AuthSessionReader {
  const StaticAuthSessionReader({
    required this.snapshot,
  });

  final AuthSnapshot snapshot;

  @override
  Future<AuthSnapshot> readSession() async => snapshot;
}
