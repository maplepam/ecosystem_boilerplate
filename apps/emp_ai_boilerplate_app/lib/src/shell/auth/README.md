# Host auth layout (`lib/src/shell/auth`)

Use this map when you need to change **login**, **tokens**, or **redirects**.

| Folder | Role | When you edit here |
|--------|------|--------------------|
| **`bootstrap/`** | `EmpAuth` init before `runApp` | IdP URLs, client id, flavor catalog vs **`AUTH_*`** defines ([environment.md](../../../../../../docs/integrations/environment.md), [auth.md](../../../../../../docs/integrations/auth.md)) |
| **`session/`** | `AuthSessionReader` + Riverpod provider for RBAC / redirects | How **`AuthSnapshot`** is built from **`emp_ai_auth`** (`EmpAiAuthSessionReader`) |
| **`token_refresh/`** | `EmpAiAuthTokenRefreshAdapter`, `emp_ai_auth_token_refresh_providers.dart`, **GoRouter** refresh listenable | 401 refresh, notifying router after login/logout |
| **`ui/`** | `boilerplateAuthSnapshotProvider` and shared auth-related providers | Widgets that need **`AuthSnapshot`** without importing `emp_ai_auth` directly |

**Tests:** [`test/support/boilerplate_auth_test_overrides.dart`](../../../../test/support/boilerplate_auth_test_overrides.dart) — `StaticAuthSessionReader` + snapshot notifier overrides.

**Imports:** prefer `package:emp_ai_boilerplate_app/src/shell/auth/<folder>/<file>.dart` from outside this tree.

**Feature flags** (mini-app gating, etc.) live under **`lib/src/platform/feature_flags/`** — see [feature_flags.md](../../../../../../docs/integrations/feature_flags.md#feature-flags).
