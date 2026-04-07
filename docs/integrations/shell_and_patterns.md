# Shell: design system, router, patterns

Cross-cutting **UI tokens**, **GoRouter** + **RBAC**, **typed errors**, and **Riverpod** composition rules.

**Navigation (add routes, `go` / `push`, redirects, file map):** [navigation.md](navigation.md). **Auth & login flow:** [auth.md](auth.md). **Network:** [network.md](network.md).

## Design system (`emp_ai_ds_northstar`)

- Use **tokens + ThemeData** from `emp_ai_ds_northstar` for new UI.
- Legacy **`emp_ai_ds`** may still appear transitively through `emp_ai_auth`; isolate new screens to Northstar to avoid spreading legacy widgets.

## Typed errors (`AppResult`)

- Use **`AppResult<T>`** with **`AppSuccess`** / **`AppFailure`** at **repository** boundaries (see **samples** and **announcements** mini-apps).
- **`AppFailure`** implements **`Exception`** so **`AsyncValue.guard`** and crash sinks integrate cleanly.

## Observability (crash reporting)

- **Analytics:** [analytics_mixpanel.md](analytics_mixpanel.md), [analytics_firebase.md](analytics_firebase.md), and [docs home — both vendors](../README.md#analytics-mixpanel-and-firebase).
- **`CrashReportingSink`:** default **no-op** in [`observability_providers.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/observability_providers.dart); swap for Crashlytics / Sentry in the host without importing vendors into `domain/`.

Details: [HOST_SERVICES.md](../platform/HOST_SERVICES.md).

## Global router redirect

- **`boilerplateGoRouterRedirectProvider`** chains:
  1. **`boilerplateCustomRedirectProvider`** — maintenance, forced upgrades, etc.
  2. **`createRouteAccessRedirect`** — RBAC + auth.
- **`CoreRouterConfig.redirect`** is wired for all host modes.

<a id="route-access-roles--permissions-per-path"></a>

## Route access (roles / permissions per path)

- Types in **`emp_ai_core`**: [`RouteAccessPolicy`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_core/lib/src/router/route_access_policy.dart), [`RouteAccessRule` / `RouteAccessRequirement`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_core/lib/src/router/route_access_requirement.dart), [`createRouteAccessRedirect`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_core/lib/src/router/route_access_redirect.dart).
- **Longest matching `pathPrefix` wins.** Configure in **`routeAccessPolicyProvider`** ([`boilerplate_route_access.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart)).
- **`RouteAccessUnmatched`**: `public`, `requireAuthentication`, or `deny` → `/unauthorized`.

**Buttons / menus** (same claims as routes): [auth.md](auth.md#permissions-in-ui).

## Auth gate → login

- Contract: **`AuthSessionReader`** + **`AuthSnapshot`** in **`emp_ai_foundation`**.
- Implementation: **`authSessionReaderProvider`** → [`EmpAiAuthSessionReader`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/session/emp_ai_auth_session_reader.dart) maps **`emp_ai_auth`** state into **`AuthSnapshot`**. Tests can override with **`StaticAuthSessionReader`** — see [`boilerplate_auth_test_overrides.dart`](../../apps/emp_ai_boilerplate_app/test/support/boilerplate_auth_test_overrides.dart).
- Keep **`authNavigationRefreshListenableProvider`** ([`auth_navigation_refresh.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/token_refresh/auth_navigation_refresh.dart)) so **`GoRouter`** re-evaluates redirects after login/logout.
- Login / unauthorized routes: [`boilerplate_router.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_router.dart). **`authLoginPathProvider`** / **`authUnauthorizedPathProvider`** adjust for embedded mode.

## Riverpod as composition root

- **`presentation/providers/*_providers.dart`** binds interfaces to implementations (e.g. `samplesRepositoryProvider` → `SamplesRepositoryImpl`).
- Keeps **domain** free of Riverpod; **notifiers** live in `presentation`.

## Embedded / standalone host modes

- Configure **`AppHostMode`** in `lib/src/config/host_mode.dart`.

## Super-app vs demo shell (navigation & customization)

- **Outer Apps rail**, **Hub**, **`BoilerplateShellPaths`**, **`boilerplateShellNavConfigProvider`**, **`kSuperAppShowMiniAppRail`:** [navigation.md — Super-app vs main shell](navigation.md#super-app-and-main-shell) (file map + **Main shell side navigation** below that).

## Checklist for a new integration (e.g. another vendor)

1. Add a **small interface** in `emp_ai_foundation` (or a dedicated package) if it is cross-cutting.
2. Implement it in the **host** or `data/` for app-specific adapters.
3. Register in **Riverpod** near other host-level providers.
4. Inject via **constructor / provider**, not service locators.

**Adding SDKs:** [contributing.md — Adding SDKs](../engineering/contributing.md#adding-sdks-and-integrations).

---

[← Docs home — integrations hub](../README.md#integrations-hub)
