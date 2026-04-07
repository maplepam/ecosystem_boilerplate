# EMP AI Flutter ecosystem boilerplate

Self-contained **Melos** monorepo that shows how to split **auth**, **design system (tokens + widgets)**, **core infrastructure**, **foundation utilities**, and a **host app** behind a single workspace. Use it as a template or reference for multi-package Flutter products.

## Documentation


| Start here                                                                   | Purpose                                                              |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **[docs/onboarding/getting_started.md](docs/onboarding/getting_started.md)** | Clone → bootstrap → run → where code lives → env catalog → platforms |
| **[docs/onboarding/first_day.md](docs/onboarding/first_day.md)**             | Command-only cheat sheet after clone                                 |
| **[docs/README.md](docs/README.md)**                                         | Full doc map, **integrations hub**, and role-based index             |
| **[docs/platform/troubleshooting.md](docs/platform/troubleshooting.md)**     | Bootstrap, codegen, defines, web, deep links                         |


**Also useful:** [environment / flavors](docs/integrations/environment.md), [dart defines & `FLAVOR](docs/platform/dart_defines.md)`, `[build_defines.example.json](apps/emp_ai_boilerplate_app/config/build_defines.example.json)`, [CI / GitHub Actions](docs/platform/ci_cd.md).

## Packages


| Package                       | Role                                                                                                                                                                                                                                                                                  |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `emp_ai_foundation`           | Contracts: feature flags, platform helpers. No UI, no Split/Dio.                                                                                                                                                                                                                      |
| `emp_ai_ds_northstar`         | Northstar **tokens** + `ThemeData` builders; DTCG JSON assets and Dart presets. See [design/design_system.md](docs/design/design_system.md).                                                                                                                                          |
| `emp_ai_ds_widgets`           | Reusable **Northstar-aligned UI** (navigation shell pieces, layouts, data table, snackbars, catalog, etc.) on top of `emp_ai_ds_northstar`. See [design/design_system_widgets.md](docs/design/design_system_widgets.md).                                                              |
| `emp_ai_core`                 | Router assembly (super-app vs mini-app prefix), Dio factory config; host extends via config objects.                                                                                                                                                                                  |
| `emp_ai_app_shell`            | `MiniApp` contract, route merging, hub, `StatefulShellRoute` scaffold, feature-flag filtering.                                                                                                                                                                                        |
| `apps/emp_ai_boilerplate_app` | Host: Riverpod + `go_router` + packages above; `**emp_ai_auth`** via Git path (see [emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md)). Token refresh: `TokenRefreshAdapter` + `CoreTokenRefreshService` — [integrations hub](docs/README.md#integrations-hub). |


**Design tokens from Figma:** export variables / DTCG-style JSON and map into Dart (see [design_system.md](docs/design/design_system.md)). Optional: [tool/extract_fig_meta.dart](tool/extract_fig_meta.dart) reads **ZIP metadata** from a downloaded `.fig` archive only — not full canvas decode; details in **getting_started** §8 and **melos** script `extract:fig-meta`.

**Auth:** `emp_ai_auth` is resolved under `packages/emp_ai_auth` (clone during `melos bootstrap` per [emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md)). Prefer `**emp_ai_ds_northstar` / `emp_ai_ds_widgets`** for new UI rather than legacy DS packages in other repos.

**Where “extra” utilities go:** flags, platform detection, analytics interfaces → `emp_ai_foundation` and small focused packages — not the design-system layer ([design_system_widgets.md](docs/design/design_system_widgets.md)).

## Router choice

**Recommendation: `go_router`.** It supports shell routes, redirects (auth / flags), named routes, and deep links — aligned with common production setups.

- **Standalone mini-app:** `AppHostMode.standaloneMiniApp` + top-level routes.
- **Embedded mini-app:** `AppHostMode.embeddedMiniApp` + `pathPrefix` via `CoreGoRouterFactory`.
- **Super-app:** merge route trees or use `StatefulShellRoute` at the host; **one** `GoRouter` at the root.

Avoid running two router libraries in the same app. Try embedded mode in [host_mode.dart](apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart):

```dart
const AppHostMode kBoilerplateHostMode = AppHostMode.embeddedMiniApp;
```

## Tooling & commands

**Day-to-day commands** (prerequisites, `flutter run`, flavors, web/iOS/Android) live in **[getting_started.md](docs/onboarding/getting_started.md)** and **[first_day.md](docs/onboarding/first_day.md)** — use those as the source of truth.

**Melos scripts** (see [melos.yaml](melos.yaml)) include:


| Script              | Purpose                                          |
| ------------------- | ------------------------------------------------ |
| `generate:miniapps` | Regenerate catalog from `miniapps_registry.yaml` |
| `create:miniapp`    | Scaffold a new mini-app slice                    |
| `analyze:all`       | `flutter analyze` on packages with `lib/`        |
| `test:boilerplate`  | Tests in `emp_ai_boilerplate_app`                |
| `extract:fig-meta`  | `.fig` ZIP metadata helper                       |


After changing `miniapps_registry.yaml` or running `create:miniapp`, run `**generate:miniapps`** before commit.

## Mono-repo vs multi-repo (dependency versions)


| Approach                  | When it helps                                                           | Tradeoff                                                  |
| ------------------------- | ----------------------------------------------------------------------- | --------------------------------------------------------- |
| **Mono-repo (Melos)**     | Same release train, shared refactors, one `melos bootstrap`, unified CI | Large clone; clear package boundaries still matter        |
| **Multi-repo + git refs** | Teams own packages; smaller checkouts                                   | Version drift, `dependency_overrides`, multiple lockfiles |


**Pragmatic approach:** mono-repo for **platform** packages (foundation, core, DS, auth, shared modules) with Melos; publish versioned artifacts only when a package must be consumed outside the monorepo. If you stay multi-repo, maintain a **single bill of materials** (pinned git refs + SDK) and CI that validates all consumers on shared changes.

Submodules work for read-only consumption; for daily work, **path** or **Melos** linking is usually simpler. More detail: [engineering/dependencies.md](docs/engineering/dependencies.md), [engineering/packages.md](docs/engineering/packages.md).

## Contributing & merge policy

- **Contributors:** [engineering/contributing.md](docs/engineering/contributing.md) (scope, layers, PR checklist).
- **Maintainers (squash vs merge, versioning, pre-merge checks):** [engineering/maintainer_policy.md](docs/engineering/maintainer_policy.md).

