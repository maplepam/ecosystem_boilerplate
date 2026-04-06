# Ecosystem boilerplate documentation

Deep guides live here; the repo root [README.md](../README.md) stays a short overview.

## Where things live

| Folder | What |
|--------|------|
| **[onboarding/](onboarding/)** | **Default start:** [getting_started.md](onboarding/getting_started.md) (clone → run → what to change); then [first_day.md](onboarding/first_day.md) for commands only |
| **[platform/](platform/)** | `FLAVOR`, defines, CI/CD, host services (Dio, analytics stack, notifications) |
| **[integrations/](integrations/)** | Host wiring deep dives — auth, env catalog, flags, network, analytics vendors, shell |
| **[engineering/](engineering/)** | Architecture, host `lib/src` layout, packages, contributing — **start:** [engineering/README.md](engineering/README.md) |
| **[design/](design/)** | Design system tokens and widgets |
| **[meta/](meta/)** | Internal inventory / roadmap |

Add new topics under the folder that matches the audience (onboarding vs platform vs integrations, …).

---

## Why so many files?

Each doc has a **narrow job** so you can link to one topic (anchors, PRs) without loading one giant page.

**Engineering:** if you are coding in the host app, open **[engineering/README.md](engineering/README.md)** first (four canonical links), then dive into narrow files.

### Three layers of configuration (don’t mix them up)

| Layer | Where | Use for |
|--------|--------|---------|
| **Flavor catalog** | `BoilerplateEnvironmentCatalog` in the app (Dart) | Default **base URLs**, OAuth client ids, feature-ish endpoints per **`FLAVOR`** — replace template values after fork ([getting_started §3](onboarding/getting_started.md#gs-3)). |
| **`build_defines.json`** | `apps/emp_ai_boilerplate_app/config/` (local / CI-generated) | **Compile-time** toggles: `VERBOSE_LOGS`, Samples demos, `MIXPANEL_TOKEN`, `ENABLE_FIREBASE`, … ([dart_defines.md](platform/dart_defines.md)). |
| **Advanced defines** | Same JSON or `--dart-define=` | Optional **`API_BASE_URL`** / **`AUTH_*`** overrides for CI or define-only auth ([environment.md](integrations/environment.md)). |

**Compile-time toggles** (middle row): [platform/dart_defines.md](platform/dart_defines.md). **Catalog + overrides** (first and third): [integrations/environment.md](integrations/environment.md).

<a id="integrations-hub"></a>

## Integrations hub

How the host connects **auth**, **environment / flavors**, **feature flags**, **network**, **analytics**, and **shell** concerns without coupling **domain** code to vendor SDKs.

### Related docs (repo-wide)

| Topic | Document |
|--------|----------|
| **CI/CD** (Bitbucket, Bitrise, `build_defines.json`) | [platform/ci_cd.md](platform/ci_cd.md) |
| **Fork / clone: remove demo, real auth, HTTP vs emapta** | [onboarding/adopting_the_boilerplate.md](onboarding/adopting_the_boilerplate.md) |
| **New SDKs, folder layout** | [integrations/extending_tooling.md](integrations/extending_tooling.md) |
| **`emp_ai_auth` resolution** | [integrations/emp_ai_auth_dependency.md](integrations/emp_ai_auth_dependency.md) |
| **Notifications, `cached_query`, Dio summary** | [platform/HOST_SERVICES.md](platform/HOST_SERVICES.md) |
| **First-time clone, catalog §3, platforms** | [onboarding/getting_started.md](onboarding/getting_started.md) |
| **Command-only first day** | [onboarding/first_day.md](onboarding/first_day.md) |
| **Melos / auth clone / defines / deep links** | [platform/troubleshooting.md](platform/troubleshooting.md) |

**Compile-time toggles** (`FLAVOR`, `VERBOSE_LOGS`, Samples, `MIXPANEL_TOKEN`, `ENABLE_FIREBASE`, …): [platform/dart_defines.md](platform/dart_defines.md). Add new integration guides under **`docs/integrations/`** and link them here.

### Deep dives (`docs/integrations/`)

| Topic | Document |
|--------|----------|
| **Auth** — `empAiAuth`, token refresh, **permissions in UI** | [integrations/auth.md](integrations/auth.md) |
| **Environment** — flavor catalog, `API_BASE_URL`, `AUTH_*`, CI defines | [integrations/environment.md](integrations/environment.md) |
| **Feature flags** — keys, `BoilerplateFeatureFlags`, `MiniAppGate` | [integrations/feature_flags.md](integrations/feature_flags.md) |
| **Network (Dio)** — interceptors, samples HTTP demo | [integrations/network.md](integrations/network.md) |
| **Analytics: Mixpanel** — token, `track` / `identify` | [integrations/analytics_mixpanel.md](integrations/analytics_mixpanel.md) |
| **Analytics: Firebase** — `ENABLE_FIREBASE`, naming rules, `track` / `identify` | [integrations/analytics_firebase.md](integrations/analytics_firebase.md) |
| **Navigation** — add routes, **`boilerplate_shell_nav_config`** (main-shell menu), `go` / `push`, redirects, host modes, mini-apps | [integrations/navigation.md](integrations/navigation.md) |
| **Shell & patterns** — design system, router + RBAC summary, `AppResult`, Riverpod | [integrations/shell_and_patterns.md](integrations/shell_and_patterns.md) |

Browsing the **`docs/integrations/`** folder in the repo: [integrations/README.md](integrations/README.md).

<a id="analytics-mixpanel-and-firebase"></a>

### Analytics (both vendors)

Product analytics use **`AnalyticsSink`** from **`emp_ai_foundation`**. The host can enable **Mixpanel**, **Firebase Analytics**, or **both** — events fan out through **`CompositeAnalyticsSink`**.

- **Mixpanel:** [integrations/analytics_mixpanel.md](integrations/analytics_mixpanel.md) (`MIXPANEL_TOKEN`).
- **Firebase:** [integrations/analytics_firebase.md](integrations/analytics_firebase.md) (`ENABLE_FIREBASE` + FlutterFire / native config).
- **Wiring:** [`boilerplate_analytics_backends_provider.dart`](../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/boilerplate_analytics_backends_provider.dart), [`observability_providers.dart`](../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/observability_providers.dart).

---

## How to read this (by role)

| I want to… | Start here |
|------------|------------|
| Clone, fork, rename, first `flutter run`, prerequisites, demo routes, Figma ZIP, catalog §3, platforms §4 | [onboarding/getting_started.md](onboarding/getting_started.md) |
| Minimal commands after clone | [onboarding/first_day.md](onboarding/first_day.md) |
| Common failures (bootstrap, `generate:miniapps`, Firebase, web CORS, deep links) | [platform/troubleshooting.md](platform/troubleshooting.md) |
| Flavor catalog, `API_BASE_URL` / `AUTH_*` | [integrations/environment.md](integrations/environment.md) |
| Auth, Dio, RBAC, permissions in UI, navigation | [integrations/auth.md](integrations/auth.md), [integrations/network.md](integrations/network.md), [integrations/navigation.md](integrations/navigation.md), [integrations/shell_and_patterns.md](integrations/shell_and_patterns.md) |
| Feature flags | [integrations/feature_flags.md](integrations/feature_flags.md) |
| `FLAVOR`, `VERBOSE_LOGS`, Mixpanel, Samples, `build_defines.example.json` | [platform/dart_defines.md](platform/dart_defines.md) |
| Bitbucket / Bitrise, `build_defines.json` in CI | [platform/ci_cd.md](platform/ci_cd.md) |
| Remove demo, ship real HTTP, emapta parity notes | [onboarding/adopting_the_boilerplate.md](onboarding/adopting_the_boilerplate.md) |
| Layers, mini-app layout, vs main monorepo | [engineering/architecture.md](engineering/architecture.md) |
| New mini-app, registry, codegen | [engineering/miniapps.md](engineering/miniapps.md) |
| Super-app shell, Hub, `BoilerplateShellPaths`, hide Apps rail | [engineering/super_app_and_demo_shell.md](engineering/super_app_and_demo_shell.md) |
| Announcements mini-app layers, notifiers per API call, DS widgets | [engineering/announcements_miniapp_layout.md](engineering/announcements_miniapp_layout.md) |
| Contribute a package/mini-app to shared boilerplate, or pull only some paths from upstream | [engineering/upstream_git_workflow.md](engineering/upstream_git_workflow.md) |
| Version bumps, maintainer merge policy, review checklist | [engineering/maintainer_policy.md](engineering/maintainer_policy.md) |
| When to add a mini-app vs a feature; emapta parity (login, announcements) | [engineering/mini_app_vs_feature.md](engineering/mini_app_vs_feature.md) |
| Mixpanel analytics | [integrations/analytics_mixpanel.md](integrations/analytics_mixpanel.md) |
| Firebase Analytics | [integrations/analytics_firebase.md](integrations/analytics_firebase.md) |
| Both vendors (summary) | [README.md#analytics-mixpanel-and-firebase](#analytics-mixpanel-and-firebase) (this page) |
| Notifications, `cached_query`, Dio helpers | [platform/HOST_SERVICES.md](platform/HOST_SERVICES.md) |
| Tokens, theme, Figma, **clone theming checklist** | [design/design_system.md#boilerplate-host-theming-checklist](design/design_system.md#boilerplate-host-theming-checklist), [design/design_system_widgets.md](design/design_system_widgets.md) |
| `emp_ai_auth` Git / submodule | [integrations/emp_ai_auth_dependency.md](integrations/emp_ai_auth_dependency.md) |
| PR rules | [engineering/contributing.md](engineering/contributing.md) |
| Internal planning | [meta/BOILERPLATE_INVENTORY_AND_ROADMAP.md](meta/BOILERPLATE_INVENTORY_AND_ROADMAP.md) |

---

## Index (all topics)

### Onboarding

| Topic | Document |
|--------|----------|
| Fresh clone, fork, rename, §2 prerequisites / demo routes / Figma, §3 catalog, §4 Web/Android/iOS, checklists | [onboarding/getting_started.md](onboarding/getting_started.md) |
| Command-only bootstrap + run + CI parity | [onboarding/first_day.md](onboarding/first_day.md) |
| Remove demo, real auth, HTTP sample vs emapta | [onboarding/adopting_the_boilerplate.md](onboarding/adopting_the_boilerplate.md) |

### Platform (build & runtime)

| Topic | Document |
|--------|----------|
| `FLAVOR` + toggles, `build_defines.example.json` | [platform/dart_defines.md](platform/dart_defines.md), [`build_defines.example.json`](../apps/emp_ai_boilerplate_app/config/build_defines.example.json) |
| Bitbucket / Bitrise, generated JSON, emapta-style | [platform/ci_cd.md](platform/ci_cd.md) |
| GitHub Actions reference job in this repo | [platform/ci_cd.md#github-actions-in-this-repo](platform/ci_cd.md#github-actions-in-this-repo) |
| Host services summary (analytics stack, notifications, cache) | [platform/HOST_SERVICES.md](platform/HOST_SERVICES.md) |
| Bootstrap, codegen, defines, analytics, deep links | [platform/troubleshooting.md](platform/troubleshooting.md) |

### Integrations (deep dives)

| Topic | Document |
|--------|----------|
| **Hub** (this page) | [README.md#integrations-hub](#integrations-hub) |
| Flavor catalog, defines, CI env | [integrations/environment.md](integrations/environment.md) |
| Auth, network, shell / router | [integrations/auth.md](integrations/auth.md), [integrations/network.md](integrations/network.md), [integrations/navigation.md](integrations/navigation.md), [integrations/shell_and_patterns.md](integrations/shell_and_patterns.md) |
| Feature flags | [integrations/feature_flags.md](integrations/feature_flags.md) |
| New SDKs / third-party tooling | [integrations/extending_tooling.md](integrations/extending_tooling.md) |
| Auth folder layout (`bootstrap/`, `session/`, …) | [apps/emp_ai_boilerplate_app/lib/src/shell/auth/README.md](../apps/emp_ai_boilerplate_app/lib/src/shell/auth/README.md) |
| `emp_ai_auth` resolution (Git / submodule) | [integrations/emp_ai_auth_dependency.md](integrations/emp_ai_auth_dependency.md) |

### Analytics (vendors)

| Topic | Document |
|--------|----------|
| Mixpanel / Firebase setup, `analyticsSinkProvider` | [integrations/analytics_mixpanel.md](integrations/analytics_mixpanel.md), [integrations/analytics_firebase.md](integrations/analytics_firebase.md) |

### Engineering

| Topic | Document |
|--------|----------|
| **Start here (four links)** | [engineering/README.md](engineering/README.md) |
| Layers, data flow, mini-app vs monorepo | [engineering/architecture.md](engineering/architecture.md) |
| **`lib/src` map:** `shell/`, `platform/`, `miniapps/`, `integrations/` | [engineering/host_structure.md](engineering/host_structure.md) |
| New package, versioning | [engineering/packages.md](engineering/packages.md) |
| New mini-app, registry, codegen | [engineering/miniapps.md](engineering/miniapps.md) |
| Super-app shell, Hub, `BoilerplateShellPaths`, hide Apps rail | [engineering/super_app_and_demo_shell.md](engineering/super_app_and_demo_shell.md) |
| Announcements mini-app layers, notifiers per API call, DS widgets | [engineering/announcements_miniapp_layout.md](engineering/announcements_miniapp_layout.md) |
| Fork vs upstream, PR shared work, pull one package/mini-app | [engineering/upstream_git_workflow.md](engineering/upstream_git_workflow.md) |
| Maintainer: versioning, PR review, squash/merge/rebase commands | [engineering/maintainer_policy.md](engineering/maintainer_policy.md) |
| Mini-app vs feature (emapta-style), announcements / auth parity notes | [engineering/mini_app_vs_feature.md](engineering/mini_app_vs_feature.md) |
| Mini-apps in **other repos** (`packages/`), **extract** when too big | [engineering/miniapp_packages_and_extract.md](engineering/miniapp_packages_and_extract.md) |
| Lockfiles, upgrading deps | [engineering/dependencies.md](engineering/dependencies.md) |
| PR rules, checklist | [engineering/contributing.md](engineering/contributing.md) |

### Design system

| Topic | Document |
|--------|----------|
| Tokens, theme, white-label, Figma, **host theming checklist** | [design/design_system.md#boilerplate-host-theming-checklist](design/design_system.md#boilerplate-host-theming-checklist) |
| DS widgets vs token package | [design/design_system_widgets.md](design/design_system_widgets.md) |

### Meta

| Topic | Document |
|--------|----------|
| Inventory + roadmap ideas | [meta/BOILERPLATE_INVENTORY_AND_ROADMAP.md](meta/BOILERPLATE_INVENTORY_AND_ROADMAP.md) |
