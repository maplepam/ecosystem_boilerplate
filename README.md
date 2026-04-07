# EMP AI Flutter ecosystem boilerplate

**Melos** workspace for a **host app** and **mini-apps** that consume **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)**, **`emp_ai_auth`** (Bitbucket), and **`emp_ai_ds`** as **Git submodules** under **`packages/`**, wired with **`path:`** dependencies from **`apps/emp_ai_boilerplate_app`**. **Pins** are **git submodule commits** (see **`git submodule status`**).

**Clone:** use **`git clone --recurse-submodules <url>`** or run **`git submodule update --init --recursive`** after clone. **SSH** must work for **GitHub** (platform submodule) and **Bitbucket** (auth + DS). The **platform** submodule is **one** checkout — all **`emp_ai_*`** packages under it share that commit. To advance platform/auth/DS, **`git checkout`** inside each submodule and **`git add`** the submodule path on the parent branch. Commit **`apps/emp_ai_boilerplate_app/pubspec.lock`** after dependency changes.

## Documentation


| Start here                                                                   | Purpose                                                              |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| **[docs/onboarding/getting_started.md](docs/onboarding/getting_started.md)** | Clone → submodules → bootstrap → run → where code lives → env catalog → platforms (**§2** = first commands) |
| **[docs/onboarding/faq.md](docs/onboarding/faq.md)**                         | Short Q&A → links (boilerplate + platform + auth)                    |
| **[docs/README.md](docs/README.md)**                                         | Full doc map, **integrations hub**, and role-based index             |
| **[docs/platform/troubleshooting.md](docs/platform/troubleshooting.md)**     | Bootstrap, codegen, defines, web, deep links                         |


**Also useful:** [environment / flavors](docs/integrations/environment.md), [dart defines & `FLAVOR`](docs/platform/dart_defines.md), [`build_defines.example.json`](apps/emp_ai_boilerplate_app/config/build_defines.example.json), [CI / GitHub Actions](docs/platform/ci_cd.md).

## Packages


| Package / area                | Role                                                                                                                                                                                                                                                                                  |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `emp_ai_foundation`           | In **ecosystem-platform**: contracts (feature flags, platform helpers). No UI, no Split/Dio. [Tree](https://github.com/maplepam/ecosystem-platform/tree/main/packages/emp_ai_foundation).                                                                                              |
| `emp_ai_ds_northstar`         | In **ecosystem-platform**: Northstar **tokens** + `ThemeData` builders. [design_system.md](docs/design/design_system.md).                                                                                                                                                              |
| `emp_ai_ds_widgets`           | In **ecosystem-platform**: Northstar-aligned UI. [design_system_widgets.md](docs/design/design_system_widgets.md).                                                                                                                                                                   |
| `emp_ai_core`                 | In **ecosystem-platform**: router assembly, Dio factory config.                                                                                                                                                                                                                       |
| `emp_ai_app_shell`            | In **ecosystem-platform**: `MiniApp` contract, route merging, hub, shell scaffold.                                                                                                                                                                                                    |
| `apps/emp_ai_boilerplate_app` | **This repo** — host: Riverpod + `go_router` + **`path:`** deps into **`packages/`** submodules + **`emp_ai_auth`**. [emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md). Token refresh: [integrations hub](docs/README.md#integrations-hub).                                          |


**Design tokens from Figma:** export variables / DTCG-style JSON and map into Dart (see [design_system.md](docs/design/design_system.md)). Optional: [tool/extract_fig_meta.dart](tool/extract_fig_meta.dart) reads **ZIP metadata** from a downloaded `.fig` archive only — not full canvas decode; details in **getting_started** §8 and **melos** script `extract:fig-meta`.

**Auth + legacy DS:** `emp_ai_auth` and `emp_ai_ds` are **submodules**; **`emp_ai_auth`** uses **`path:`** into **`ecosystem-platform`** (`emp_ai_core`) and **`emp_ai_ds`** so pins stay aligned with submodule gitlinks — [emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md). Prefer **Northstar** (`emp_ai_ds_northstar` / `emp_ai_ds_widgets` from **ecosystem-platform**) for new UI.

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

**Day-to-day commands** live in **[getting_started.md](docs/onboarding/getting_started.md)** (**[§2 — Must run these commands](docs/onboarding/getting_started.md#gs-2)**).

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
| **Multi-repo + submodules** | Pinned platform/auth/DS revisions in one parent commit                    | Larger clone; submodule discipline; SSH in CI               |


**This repo:** **ecosystem_boilerplate** (host + mini-apps + **`packages/`** submodule pointers) — see **[docs/engineering/repositories_overview.md](docs/engineering/repositories_overview.md)** and **[docs/integrations/emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md)**. **New-team Q&A:** [docs/onboarding/faq.md](docs/onboarding/faq.md).

To hack **ecosystem-platform** sources, use a separate clone + **`pubspec_overrides.yaml`**, or **`cd packages/ecosystem-platform && dart run melos bootstrap`**. Root **`analysis_options.yaml`** excludes **`packages/*`** submodules so the IDE does not false-error on un-bootstrapped nested packages. More detail: [engineering/dependencies.md](docs/engineering/dependencies.md), [engineering/packages.md](docs/engineering/packages.md).

## Contributing & merge policy

- **Contributors:** [engineering/contributing.md](docs/engineering/contributing.md) (scope, layers, PR checklist).
- **Maintainers (squash vs merge, versioning, pre-merge checks):** [engineering/maintainer_policy.md](docs/engineering/maintainer_policy.md).

