# Auth (`emp_ai_auth`)

How the host wires **sign-in**, **tokens**, **Dio refresh**, and **UI permissions** without pulling `emp_ai_auth` into mini-app `domain/`.

**Package resolution** (Git / submodule): [emp_ai_auth_dependency.md](emp_ai_auth_dependency.md). **Flavor catalog & defines** (Keycloak URLs, `AUTH_*`): [environment.md](environment.md).

The boilerplate keeps a **stub reference** in [`auth_integration_stub.dart`](../../apps/emp_ai_boilerplate_app/lib/src/integrations/auth_integration_stub.dart) so the real package stays a normal dependency. You do **not** delete `emp_ai_auth` for production; you **turn on** the real backend (below).

## Production auth in plain steps

Think of three pieces: **(1) who is signed in**, **(2) where tokens live**, **(3) who may see which routes**. The host uses **`emp_ai_auth`** for **(1)** and **(2)**; **(3)** is already wired.

| Step | What to do                                 | Where                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| ---- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Configure Keycloak / OAuth                 | [`boilerplate_auth_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_auth_config.dart) documents app links; auth itself is always **`EmpAuth`** from `emp_ai_auth`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 2    | Initialize Keycloak / OAuth settings       | The app calls **`EmpAuth().initialize(...)`** from [`emp_ai_auth_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart) inside [`loadBoilerplateStartupOverrides()`](../../apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_startup_overrides.dart) **before** `runApp`. **Precedence:** (a) **`AUTH_*`** `--dart-define`s when **`AUTH_CLIENT_ID`** is set ([define-only auth](environment.md#auth-dart-defines-advanced)); (b) else **[flavor catalog](environment.md#flavor-catalog-emapta-style)** from `--dart-define=FLAVOR` (defaults to development).                                                                                                                                                                                                                                                                                                            |
| 3    | Token storage                              | Access/refresh tokens are handled **inside `emp_ai_auth`** (secure storage + `AuthNotifier`). The host adds [**token refresh adapters**](#token-refresh-host--emp_ai_auth-core) and Dio interceptors so API calls refresh on **401**.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| 4    | Login UI                                   | [`login_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/screens/login_screen.dart) uses **`EmpAuth().login`** when runtime config is present; otherwise it explains missing flavor catalog / `AUTH_*` configuration. Aligning behavior with **emapta’s main app**: [mini_app_vs_feature.md — Emapta parity](../engineering/mini_app_vs_feature.md#emapta-parity-login-and-emp_ai_auth).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| 5    | **GoRouter** redirects (already hooked up) | [`boilerplateGoRouterRedirectProvider`](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_redirect_provider.dart) chains **custom** redirects + **RBAC/auth**. You usually **only** edit providers — not `emp_ai_core` — unless your org forks core. Customize: **`boilerplateCustomRedirectProvider`** (maintenance, force upgrade), **`routeAccessPolicyProvider`** ([`boilerplate_route_access.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart)), and [**public paths**](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_public_paths.dart). After login/logout, call **`authNavigationRefreshListenableProvider`** so GoRouter re-runs redirects ([`auth_navigation_refresh.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/token_refresh/auth_navigation_refresh.dart)). **Step-by-step navigation:** [navigation.md](navigation.md). |

**Tests without Keycloak:** override [`authSessionReaderProvider`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/session/emp_ai_auth_session_reader.dart) and [`boilerplateAuthSnapshotProvider`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/ui/boilerplate_auth_ui.dart) — see [`test/support/boilerplate_auth_test_overrides.dart`](../../apps/emp_ai_boilerplate_app/test/support/boilerplate_auth_test_overrides.dart).

**Rule:** mini-app `domain/` must **not** import `emp_ai_auth`. Authentication is a **host** concern; pass **`AuthSnapshot`** or tokens into **repositories** or **datasources** via constructor/DI if a feature needs them — keep `domain/` free of auth SDKs.

## Token refresh (host + `emp_ai_auth` core)

- **Core logic** lives in **`emp_ai_auth`**: `CoreTokenRefreshService`, `TokenRefreshInterceptor`, and **`TokenRefreshAdapter`**.
- Host wiring:
  - [`emp_ai_auth_token_refresh_providers.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/token_refresh/emp_ai_auth_token_refresh_providers.dart) — `empAiAuthTokenRefreshAdapterProvider`, `coreTokenRefreshServiceProvider`, `empAiAuthTokenRefreshInterceptorProvider`.
  - [`emp_ai_auth_token_refresh_adapter.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/token_refresh/emp_ai_auth_token_refresh_adapter.dart) — `TokenRefreshAdapter` for `emp_ai_auth`.
- Analytics hooks: [`boilerplateAnalyticsSinkProvider`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/boilerplate_analytics_backends_provider.dart).

<a id="permissions-in-ui"></a>

## Permissions in UI (e.g. show or hide a button)

Route rules in **`routeAccessPolicyProvider`** only affect **navigation** (redirect). **Buttons** and **tiles** need the same claims checked in the widget layer.

1. **Read the current principal** (mapped from `emp_ai_auth` via [`boilerplateAuthSnapshotProvider`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/ui/boilerplate_auth_ui.dart)):

   ```dart
   final AuthSnapshot auth = ref.watch(boilerplateAuthSnapshotProvider);
   ```

   [`boilerplateAuthSnapshotProvider`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/ui/boilerplate_auth_ui.dart) returns **`AuthSnapshot`**: `isAuthenticated`, `roles`, `permissions`.

2. **Gate a button** with the same permission strings you use in **`RouteAccessRule`** (e.g. `orders:approve`; **`/samples` is public** in this boilerplate — use permissions for in-app gates, not for that route):

   ```dart
   final AuthSnapshot auth = ref.watch(boilerplateAuthSnapshotProvider);
   final bool canManageOrders =
       auth.isAuthenticated && auth.permissions.contains('orders:approve');

   if (canManageOrders)
     FilledButton(
       onPressed: () { /* ... */ },
       child: const Text('Approve order'),
     ),
   ```

3. **Reuse the exact same logic as the router** (optional, avoids drift)  
   Build a **`RouteAccessRequirement`** and call **`satisfiedBy`** with the snapshot (types from **`emp_ai_core`**):

   ```dart
   import 'package:emp_ai_core/emp_ai_core.dart';
   import 'package:emp_ai_foundation/emp_ai_foundation.dart';

   bool canDoAction(AuthSnapshot auth) {
     const RouteAccessRequirement req = RouteAccessRequirement(
       requiresAuthentication: true,
       anyOfPermissions: <String>{'orders:approve'},
     );
     return req.satisfiedBy(
       isAuthenticated: auth.isAuthenticated,
       roles: auth.roles,
       permissions: auth.permissions,
     );
   }
   ```

4. **Roles instead of permissions**  
   Use `auth.roles.contains('manager')` or `RouteAccessRequirement(anyOfRoles: {'manager'}, ...)`.

**Note:** Hiding a button does **not** secure the API; the backend must still enforce authorization. UI gating is for **UX** only.

**Router / path rules:** [shell_and_patterns.md](shell_and_patterns.md#route-access-roles--permissions-per-path).

---

[← Docs home — integrations hub](../README.md#integrations-hub)
