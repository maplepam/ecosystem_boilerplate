# EMP AI Flutter ecosystem boilerplate

Self-contained **Melos workspace** (its own git repository) that models how to split **auth**, **design system**, **core infrastructure**, **foundation utilities**, and a **host app**. It usually lives as a sibling of the main `emapta` app repo under the same parent folder.

## Documentation

Guides live under **`docs/`** (grouped by **onboarding**, **platform**, **integrations**, **engineering**, **design**, **meta**): **[docs/README.md](docs/README.md)**. **New to this repo?** **[docs/onboarding/getting_started.md](docs/onboarding/getting_started.md)** — or **[docs/onboarding/first_day.md](docs/onboarding/first_day.md)** for commands only. **Stuck?** **[docs/platform/troubleshooting.md](docs/platform/troubleshooting.md)**. **Integrations hub:** **[docs/README.md#integrations-hub](docs/README.md#integrations-hub)**. **Flavor catalog / defines:** **[docs/integrations/environment.md](docs/integrations/environment.md)**. **Toggles / `FLAVOR`:** **[docs/platform/dart_defines.md](docs/platform/dart_defines.md)**, **[apps/emp_ai_boilerplate_app/config/build_defines.example.json](apps/emp_ai_boilerplate_app/config/build_defines.example.json)**. **CI/CD:** **[docs/platform/ci_cd.md](docs/platform/ci_cd.md)** (includes **GitHub Actions** in this repo).

## Packages

| Package                       | Role                                                                                                                                                                                                                                                                                                                                                                                                                   |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `emp_ai_foundation`           | Contracts only: feature-flag reader, lightweight platform helpers. No UI, no Split/Dio.                                                                                                                                                                                                                                                                                                                                |
| `emp_ai_ds_northstar`         | Northstar V3 **tokens + ThemeData**. **DTCG JSON** from `1 Tokens.zip` is under `design_tokens/dtcg/` with Dart **[NorthstarDtcgPresets](packages/emp_ai_ds_northstar/lib/src/northstar_dtcg_presets.dart)**; legacy [v3] remains available.                                                                                                                                                                           |
| `emp_ai_core`                 | **Router assembly** (super-app vs mini-app prefix) and **Dio factory** config. Host apps extend via config objects.                                                                                                                                                                                                                                                                                                    |
| `emp_ai_app_shell`            | **[MiniApp](packages/emp_ai_app_shell/lib/src/mini_app.dart)** + [MiniAppAlwaysOn](packages/emp_ai_app_shell/lib/src/mini_app.dart), route merging, [SuperAppHubPage](packages/emp_ai_app_shell/lib/src/super_app_hub_page.dart), [StatefulShellRoute](packages/emp_ai_app_shell/lib/src/mini_app_route_factory.dart) scaffold, feature-flag [filter](packages/emp_ai_app_shell/lib/src/mini_app_feature_filter.dart). |
| `apps/emp_ai_boilerplate_app` | Wires Riverpod + `go_router` + the packages above; `emp_ai_auth` via Git (see [docs/integrations/emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md)). Host **token refresh**: `TokenRefreshAdapter` + `CoreTokenRefreshService` + Dio interceptors — [docs/README.md#integrations-hub](docs/README.md#integrations-hub).                                                                          |

## Figma tokens (local file / Cursor)

**Downloaded `.fig` files:** the outer archive is a ZIP with `meta.json` (canvas background, file name) and `canvas.fig` (**`fig-kiwij`** binary). This repo includes [tool/extract_fig_meta.dart](tool/extract_fig_meta.dart) for the ZIP metadata only — it does **not** decode the full canvas, so color styles / variables inside the design file are not auto-imported.

```bash
dart run melos run extract:fig-meta -- "/path/to/V3 NORTHSTAR_ DESIGNSYSTEM.fig"
```

**For every semantic color:** use Figma **Variables** (or Tokens Studio), **export to JSON**, and map into [NorthstarColorTokens](packages/emp_ai_ds_northstar/lib/src/northstar_color_tokens.dart) (or extend a codegen script). Paste that JSON into the repo if you want help generating Dart.

**This environment cannot read the Figma desktop app or Cursor’s Figma plugin** unless you export files into the workspace.

## vs `flutter_superapp_boilerplate` (Downloads)

The folder you referenced is a **minimal sketch** (no `pubspec.yaml` in the tree we inspected): `MiniApp` + hand-written `miniapps.g.dart` + flat `go_router` list. The README you quoted describes a **target** architecture (generators, clean layers, CI) that **is not fully implemented** in those files.

| Topic                           | Downloads sample                                                      | `ecosystem_boilerplate`                                                                                                                                                                                                                                                                                                           |
| ------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Melos                           | Yes                                                                   | Yes                                                                                                                                                                                                                                                                                                                               |
| MiniApp contract                | `MiniApp` (name, routes, home)                                        | `MiniApp` (id, displayName, entryLocation, routes) + **redirect** on `/${id}` for valid `go_router` parents                                                                                                                                                                                                                       |
| Route aggregation               | `...expand((a) => a.routes)`                                          | [MiniAppRouteFactory](packages/emp_ai_app_shell/lib/src/mini_app_route_factory.dart) **nested** (default) or **flat**                                                                                                                                                                                                             |
| Hub                             | `HomePage` used **Navigator.pushNamed** (mismatched with `go_router`) | [SuperAppHubPage](packages/emp_ai_app_shell/lib/src/super_app_hub_page.dart) uses **`context.go`**                                                                                                                                                                                                                                |
| Host modes                      | N/A                                                                   | **Super-app / standalone / embedded** via [AppHostMode](packages/emp_ai_core/lib/src/router/app_host_mode.dart) + [CoreGoRouterFactory](packages/emp_ai_core/lib/src/router/core_go_router_factory.dart)                                                                                                                          |
| Design system                   | Not present                                                           | **Token-only** `emp_ai_ds_northstar`                                                                                                                                                                                                                                                                                              |
| Foundation (flags, platform)    | Not present                                                           | `emp_ai_foundation`                                                                                                                                                                                                                                                                                                               |
| Network                         | Not present                                                           | `NetworkStackConfig` + sample Dio provider                                                                                                                                                                                                                                                                                        |
| Auth                            | Stub controller only                                                  | Path to real **`emp_ai_auth`** + stub reference                                                                                                                                                                                                                                                                                   |
| Clean architecture per mini-app | Described only                                                        | **Implemented** under `samples/` (`domain` / `data` / `presentation`)                                                                                                                                                                                                                                                             |
| Auto mini-app generator         | Described only                                                        | **`miniapps_registry.yaml`** + `melos run generate:miniapps`; **`melos run create:miniapp -- name`** scaffolds a new slice                                                                                                                                                                                                        |
| Stateful shell                  | N/A                                                                   | **`StatefulShellRoute.indexedStack`** + bottom [NavigationBar](packages/emp_ai_app_shell/lib/src/super_app_stateful_shell_scaffold.dart); toggle `kSuperAppUseStatefulShell` in [host_mode.dart](apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart)                                                                       |
| Feature-flagged mini-apps       | N/A                                                                   | [MiniApp.requiredFeatureFlagKey](packages/emp_ai_app_shell/lib/src/mini_app.dart) + [MiniAppGate](apps/emp_ai_boilerplate_app/lib/src/platform/miniapps_registry/mini_app_gate.dart) + [BoilerplateFeatureFlags.samplesMiniAppEnabled](apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart) |
| CI                              | N/A                                                                   | [`.github/workflows/ci.yml`](.github/workflows/ci.yml) in this repository                                                                                                                                                                                                                                                         |

**Compatibility:** The Downloads `MiniApp` idea maps directly to `emp_ai_app_shell`; this repo adds redirects, hub/`go`, **stateful tabs**, **flag gating**, **codegen registry**, and **CI**.

### Auth (`emp_ai_auth`)

The sample app uses **`emp_ai_auth`** at **`packages/emp_ai_auth`**. **`melos bootstrap`** runs a **pre-hook** that **clones** the repo when needed and **patches** auth’s `pubspec.yaml` so **`emp_ai_ds`** comes from **Git** (no `packages/emp_ai_ds` checkout). See **[docs/integrations/emp_ai_auth_dependency.md](docs/integrations/emp_ai_auth_dependency.md)**. New UI should use **`emp_ai_ds_northstar`**.

### Utilities outside the design system

Yes—**feature flags, platform detection, device info, date/currency helpers** belong in `emp_ai_foundation` (interfaces) and small implementation packages (e.g. `emp_ai_split`, `emp_ai_device`), not in the DS. The current `emp_ai_ds` mix of Split, network, and widgets is exactly what this layout avoids.

## Router choice

**Recommendation: stay on `go_router`.** It matches your production app, supports **shell routes**, **redirects** (auth / feature flags), **named routes**, and **deep links**. For super-app vs mini-app:

- **Standalone mini-app:** `AppHostMode.standaloneMiniApp` + top-level routes (`/home`, …).
- **Embedded mini-app:** `AppHostMode.embeddedMiniApp` + `pathPrefix` (e.g. `demo` → `/demo/...`) via `CoreGoRouterFactory`.
- **Super-app:** compose multiple modules by merging route trees or using a `StatefulShellRoute` in the host; keep **one** `GoRouter` at the root.

`auto_route` is viable if you want codegen; **avoid** mixing two routers in one app.

Try embedded mode by editing `apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart`:

```dart
const AppHostMode kBoilerplateHostMode = AppHostMode.embeddedMiniApp;
```

## Tooling

| Command                                                    | Purpose                                                                       |
| ---------------------------------------------------------- | ----------------------------------------------------------------------------- |
| `dart pub get`                                             | Resolve workspace `yaml` / `path` deps for `tool/*.dart`                      |
| `dart run melos bootstrap`                                 | Link all Flutter packages                                                     |
| `dart run melos run generate:miniapps`                     | Regenerate `miniapp_catalog.g.dart` from `miniapps_registry.yaml`             |
| `dart run melos run extract:fig-meta -- /path/to/file.fig` | Print `meta.json` canvas background (see `emp_ai_ds_northstar` docs below)    |
| `dart run melos run create:miniapp -- my_feature`          | Scaffold `lib/src/miniapps/my_feature/` (clean-arch layout) + append registry |
| `dart run melos run analyze:all`                           | `flutter analyze` in every package with `lib/`                                |
| `dart run melos run test:boilerplate`                      | `flutter test` in `emp_ai_boilerplate_app`                                    |

After editing `miniapps_registry.yaml` or running `create:miniapp`, always run **`generate:miniapps`** before commit.

## Commands

```bash
cd ecosystem_boilerplate   # repository root
dart pub get
dart run melos bootstrap
dart run melos run generate:miniapps
cd apps/emp_ai_boilerplate_app && flutter run
```

## Mono-repo vs multi-repo (dependency versions)

| Approach                  | When it helps                                                             | Tradeoff                                                                           |
| ------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| **Mono-repo (Melos)**     | Same release train, shared refactors, one `melos bootstrap` / unified CI. | Large clone; needs discipline on package boundaries.                               |
| **Multi-repo + git refs** | Teams own packages; smaller checkouts.                                    | Version drift, painful `dependency_overrides`, duplicate `pubspec.lock` debugging. |

**Pragmatic recommendation:** use a **mono-repo for “platform” packages** (`foundation`, `core`, `ds_northstar`, `auth`, shared modules) and **Melos** to align versions; publish **versioned tags** or **pub server** only when a package must be consumed outside the mono-repo. If you stay multi-repo, add a **single “bill of materials”** repo or script that pins **git refs + SDK** for every app, and run CI that runs `flutter pub get` on all consumers when a shared package changes.

Submodule vs path: submodules are fine for **read-only** consumption; for daily development, **path** or **Melos** linking is less fragile.

## Renaming `emp_ai_ds_northstar`

When you are ready to replace the old package in Git, rename this package to `emp_ai_ds` in `pubspec.yaml` and update dependents—keep **scope** limited to tokens/themes/widgets that map to Northstar Figma, not feature infrastructure.
