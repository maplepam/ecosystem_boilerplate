/// Authentication: **always** [emp_ai_auth] (Keycloak-shaped OAuth via `EmpAuth`).
///
/// Configure before `runApp` via [bootstrapEmpAiAuthIfEnabled] — see
/// `emp_ai_auth_bootstrap.dart`, flavor catalog, or `--dart-define=AUTH_*`
/// (see `docs/integrations/environment.md`).
///
/// Widget tests can override [boilerplateAuthSnapshotProvider] — see
/// `test/support/boilerplate_auth_test_overrides.dart`.
library;

/// When true, [DeepLinkListener] applies cold-start + stream URIs from
/// [AppLinks].
const bool kBoilerplateEnableAppLinks = true;

