# Ecosystem boilerplate documentation

Deep guides live here; the repo root [README.md](../README.md) stays a short overview.

## Where things live

| Folder | What |
|--------|------|
| **[onboarding/](onboarding/)** | **Default start:** [getting_started.md](onboarding/getting_started.md) (includes **[§2 first commands](onboarding/getting_started.md#gs-2)**); [faq.md](onboarding/faq.md) |
| **[platform/](platform/)** | `FLAVOR`, defines, CI/CD, host services (Dio, analytics stack, notifications) |
| **[integrations/](integrations/)** | Host wiring deep dives — auth, env catalog, flags, network, analytics vendors, shell |
| **[engineering/](engineering/)** | Architecture, host `lib/src` layout, packages, contributing — **start:** [engineering/README.md](engineering/README.md) |
| **[design/](design/)** | Design system tokens and widgets |
| **[meta/](meta/)** | Optional roadmap / inventory notes ([`BOILERPLATE_INVENTORY_AND_ROADMAP.md`](meta/BOILERPLATE_INVENTORY_AND_ROADMAP.md)) |

Add new topics under the folder that matches the audience (onboarding vs platform vs integrations, …).

---

## Documentation structure

Each doc has a **narrow job** so readers can link to one topic (anchors, PRs) without loading one giant page.

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
| **Productize fork** (auth, samples, RBAC, real HTTP) | [onboarding/adopting_the_boilerplate.md](onboarding/adopting_the_boilerplate.md) |
| **New SDKs, folder layout** | [contributing.md — Adding SDKs](engineering/contributing.md#adding-sdks-and-integrations) |
| **`emp_ai_auth` resolution** | [integrations/emp_ai_auth_dependency.md](integrations/emp_ai_auth_dependency.md) |
| **Notifications, `cached_query`, Dio summary** | [platform/HOST_SERVICES.md](platform/HOST_SERVICES.md) |
| **First-time clone, catalog §3, platforms** | [onboarding/getting_started.md](onboarding/getting_started.md) |
| **First commands after clone** | [getting_started §2](onboarding/getting_started.md#gs-2) |
| **FAQ: which repo, which doc, upgrades** | [onboarding/faq.md](onboarding/faq.md) |
| **Melos / Git deps / defines / deep links** | [platform/troubleshooting.md](platform/troubleshooting.md) |

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

## Documentation index

**Host app coding:** start at [engineering/README.md](engineering/README.md). **Changing shared packages (`emp_ai_*`):** [ecosystem-platform CONTRIBUTING](https://github.com/maplepam/ecosystem-platform/blob/main/CONTRIBUTING.md).

| I want to… | Doc |
|------------|-----|
| Full onboarding (clone, catalog, run Web/iOS/Android) | [getting_started.md](onboarding/getting_started.md) |
| Bootstrap / run commands | [getting_started §2](onboarding/getting_started.md#gs-2) |
| FAQ, repos | [faq.md](onboarding/faq.md) |
| Productize fork (auth, samples, RBAC, HTTP) | [adopting_the_boilerplate.md](onboarding/adopting_the_boilerplate.md) |
| Bootstrap / codegen / Firebase / deep links failures | [troubleshooting.md](platform/troubleshooting.md) |
| Boilerplate vs platform vs auth | [repositories_overview.md](engineering/repositories_overview.md) |
| Flavor catalog, `API_BASE_URL`, `AUTH_*` | [environment.md](integrations/environment.md) |
| Auth, Dio, navigation, shell patterns | [auth.md](integrations/auth.md), [network.md](integrations/network.md), [navigation.md](integrations/navigation.md), [shell_and_patterns.md](integrations/shell_and_patterns.md) |
| Feature flags | [feature_flags.md](integrations/feature_flags.md) |
| `FLAVOR`, toggles, `build_defines` | [dart_defines.md](platform/dart_defines.md), [ci_cd.md](platform/ci_cd.md) |
| Analytics (Mixpanel / Firebase + summary) | [analytics_mixpanel.md](integrations/analytics_mixpanel.md), [analytics_firebase.md](integrations/analytics_firebase.md), [§ above](#analytics-mixpanel-and-firebase) |
| Host services (Dio stack, notifications, `cached_query`) | [HOST_SERVICES.md](platform/HOST_SERVICES.md) |
| Design tokens / widgets / theming checklist | [design_system.md](design/design_system.md), [design_system_widgets.md](design/design_system_widgets.md) |
| `emp_ai_auth`, submodules, SSH | [emp_ai_auth_dependency.md](integrations/emp_ai_auth_dependency.md) |
| Architecture, mini-apps, shell layout, packages, deps, upstream, maintainer | [engineering/README.md](engineering/README.md) → [architecture](engineering/architecture.md), [miniapps](engineering/miniapps.md), [host_structure](engineering/host_structure.md), [navigation — super-app shell](integrations/navigation.md#super-app-and-main-shell), [mini_app_vs_feature](engineering/mini_app_vs_feature.md), [miniapp_packages_and_extract](engineering/miniapp_packages_and_extract.md), [announcements_miniapp_layout](engineering/announcements_miniapp_layout.md), [packages](engineering/packages.md), [dependencies](engineering/dependencies.md), [upstream_git_workflow](engineering/upstream_git_workflow.md), [maintainer_policy](engineering/maintainer_policy.md), [contributing](engineering/contributing.md) |
| Submodule pins, SSH | [emp_ai_auth_dependency.md](integrations/emp_ai_auth_dependency.md) |
| Optional roadmap ideas | [BOILERPLATE_INVENTORY_AND_ROADMAP.md](meta/BOILERPLATE_INVENTORY_AND_ROADMAP.md) |

**Integrations folder:** [integrations/README.md](integrations/README.md). **Build defines template:** [`build_defines.example.json`](../apps/emp_ai_boilerplate_app/config/build_defines.example.json).
