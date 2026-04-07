# Mini-apps: adding and integrating

**Sharing a mini-app via Git** (PR to upstream, or checking out one mini-app path from upstream into a fork): [upstream_git_workflow.md](upstream_git_workflow.md).

## Concepts

- A **mini-app** is a **`MiniApp`** instance: id, display name, `GoRoute` list, entry location, optional feature-flag key.
- The host **merges** routes and shows a **hub** (or **stateful shell**) from `emp_ai_app_shell`.
- **Codegen**: `miniapps_registry.yaml` drives `miniapp_catalog.g.dart` via Melos.
- **Folder:** product code lives under **`lib/src/miniapps/<id>/`**. Host-wide gating uses **`MiniAppGate`** in **`lib/src/platform/miniapps_registry/`** — see [host_structure.md](host_structure.md).

## Remote mini-app registry (server allow-list)

The **runtime catalog** is **`kHostMiniAppsCatalog`** in [`miniapp_host_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/miniapp_host_catalog.dart): it starts with codegen **`kAllMiniApps`** (`miniapps_registry.yaml`) and **appends** external package + WebView mini-apps. An optional **remote** step can restrict **which ids** are enabled **before** feature flags run.

**Clean architecture (host `platform/miniapps_registry/`):**

| Layer | Files |
|--------|--------|
| **Domain** | `domain/miniapps_remote_registry_snapshot.dart`, `domain/miniapps_remote_registry_repository.dart` |
| **Data** | `data/dtos/miniapps_registry_response_dto.dart`, `data/datasources/*_http.dart` / `*_stub.dart`, `data/miniapps_remote_registry_repository_impl.dart` |
| **DI** | `di/miniapps_registry_providers.dart` → **`miniappsRemoteRegistryRepositoryProvider`** |

1. **`MiniAppGate`** uses **`MiniappsRemoteRegistryRepository`** (wired in **`mini_app_gate.dart`**).
2. **`MINIAPPS_REGISTRY_URL`** — non-empty → **`MiniappsRegistryRemoteDataSourceHttp`** + host **`Dio`**. JSON shape: **`docs/fixtures/miniapps_registry.json`**. **`MINIAPPS_REGISTRY_USE_STUB=true`** or empty URL → stub (no network).
3. **REPLACE** in code: DTO keys, URL source (flavor vs define), error handling — see comments in **`miniapps_registry_remote_datasource_http.dart`**.

On fetch **failure** or parse mismatch, HTTP datasource returns **`enabledIds: null`** (no server filter). The gate still falls back to full catalog when flag filtering yields an empty list.

**External / extracted packages:** [miniapp_packages_and_extract.md](miniapp_packages_and_extract.md).

## Add a new mini-app (scaffold)

From `ecosystem_boilerplate/`:

```bash
dart run melos run create:miniapp -- my_feature_name
```

This typically:

- Appends an entry to **`miniapps_registry.yaml`**.
- Creates a **clean-architecture** skeleton under `apps/emp_ai_boilerplate_app/lib/src/miniapps/my_feature_name/`:
  - `domain/` (entities, repository contract)
  - `data/datasources/`, `data/repositories/`
  - `presentation/` (screen, `providers/*_providers.dart`, `*_home_notifier.dart`)
- You must run code generation after registry changes:

```bash
dart run melos run generate:miniapps
```

## Integrate into navigation

1. Implement the **home screen** and wire **`routes`** in the generated `*_miniapp.dart` (or equivalent) to match your `GoRoute` tree.
2. If the mini-app should **hide behind a flag**, set **`requiredFeatureFlagKey`** to a stable string and implement that key in **[`BoilerplateFeatureFlags`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart)** (or your own **`FeatureFlagSource`**); see [feature_flags.md](../integrations/feature_flags.md#feature-flags). Use **`MiniAppAlwaysOn`** only for demos (see `emp_ai_app_shell`).
3. For **super-app tabs**, ensure the shell branch index matches the order of `MiniApp` entries you want in the hub when the outer Apps rail is enabled — [navigation.md — Super-app vs main shell](../integrations/navigation.md#super-app-and-main-shell).

## Clean architecture inside the mini-app

Follow the flow in [architecture.md](architecture.md):

- UI → **Notifier** / **`cached_query`** (via **`presentation/di/`**) → **Repository (abstract)** → **RepositoryImpl** → **DataSource**.

Keep **`presentation/providers/*_providers.dart`** as the **composition root** for that mini-app’s slice.

## Feature flags and access control

- Use **`MiniAppGate`** (or equivalent host pattern) so deep links do not bypass flags.
- Auth redirects belong in the **host router**, not inside individual mini-app widgets, unless the mini-app is only ever run standalone.

## Testing

- **Widget test** the home screen with **overridden** Riverpod providers (fake **repository** or datasource).
- Optional: **integration test** navigation from hub to the mini-app path.
