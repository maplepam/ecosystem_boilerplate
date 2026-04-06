import 'package:emp_ai_auth/emp_ai_auth.dart';

/// Optional reference to the real auth facade for tooling / codegen.
///
/// Host wiring: call `bootstrapEmpAiAuthIfEnabled()` from startup, and use
/// `boilerplateAuthSnapshotProvider` + `LoginScreen` ([EmpAuth]).
final class AuthIntegrationStub {
  const AuthIntegrationStub._();

  static Type get authFacadeType => EmpAuth;
}
