# Host integration guides

These files are **deep dives** for wiring the sample host (auth, env, flags, network, analytics, shell).

**Code layout:** cross-cutting **host** wiring for flags, analytics, and notifications lives under **`apps/emp_ai_boilerplate_app/lib/src/platform/`**; **router / scaffold / auth / deep links** under **`lib/src/shell/`** — see [host_structure.md](../engineering/host_structure.md). This **`docs/integrations/`** folder is **documentation only** (not to be confused with app `lib/src/integrations/`, which holds shared adapters such as employee-assignment HTTP).

The **[integrations hub](../README.md#integrations-hub)** on the main docs index is the canonical entry (related docs, analytics summary, role table); **this folder** is the per-topic file listing below.

**Start here:** [Integrations hub](../README.md#integrations-hub).

| Doc | Topic |
|-----|--------|
| [auth.md](auth.md) | `empAiAuth`, token refresh, permissions in UI |
| [environment.md](environment.md) | Flavor catalog, `API_BASE_URL`, `AUTH_*`, CI defines |
| [emp_ai_auth_dependency.md](emp_ai_auth_dependency.md) | Platform + auth Git deps, BOM, SSH |
| [feature_flags.md](feature_flags.md) | `BoilerplateFeatureFlags`, `MiniAppGate` |
| [network.md](network.md) | Dio, interceptors |
| [analytics_mixpanel.md](analytics_mixpanel.md) | Mixpanel |
| [analytics_firebase.md](analytics_firebase.md) | Firebase Analytics |
| [navigation.md](navigation.md) | GoRouter: add routes, **configurable main-shell menu** (`boilerplate_shell_nav_config`), navigate, redirects, file map |
| [shell_and_patterns.md](shell_and_patterns.md) | Router + RBAC overview, `AppResult`, Riverpod |
| [contributing.md — Adding SDKs](../engineering/contributing.md#adding-sdks-and-integrations) | New SDKs |
