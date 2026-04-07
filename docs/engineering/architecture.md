# Architecture

## Goals

- **Separation of concerns**: UI does not call HTTP or persistence directly.
- **Testability**: domain and data layers are mockable; Riverpod wires implementations.
- **Super-app ready**: multiple mini-apps compose under one host router and optional `StatefulShellRoute`.

## Layer layout (per feature / mini-app)

Place code under the mini-app (or feature) root using three folders:

| Layer           | Responsibility                                                                                                                                                                                 |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `presentation/` | Widgets, screens, Riverpod **notifiers** (controllers), provider wiring only.                                                                                                                  |
| `domain/`       | **Entities** and **repository interfaces** (contracts). Optional **domain-only services** if several repositories must be orchestrated. No Flutter imports, no `dio`, no `shared_preferences`. |
| `data/`         | DTOs, **data sources** (remote/local), **repository implementations** that satisfy domain contracts.                                                                                           |

Shared cross-cutting code belongs in workspace packages (`emp_ai_foundation`, `emp_ai_core`, `emp_ai_app_shell`, `emp_ai_ds_northstar`, etc.), not duplicated inside every mini-app.

## Dependency rule

Dependencies point **inward**:

- `presentation` → `domain` (and Riverpod, Flutter).
- `data` → `domain` (implements interfaces).
- `domain` → **nothing** from `data` or `presentation`.

## Request flow

```
UI (Widget)
  → ref.watch / ref.read (Notifier and/or providers in presentation/di)
       Presentation: Notifier, and/or cached_query Query/InfiniteQuery factories
  → Repository (abstract, domain)
  → RepositoryImpl (data)
  → DataSource (API / local / cache)
```

- **Widgets** and **`QueryBuilder`** render state; they do not call HTTP or parse JSON.
- **Notifiers** and **`cached_query` `queryFn`s** (wired in **`presentation/di/`**) call the **repository**; they should not contain URLs, request maps, or DTO parsing.
- **Repository** exposes **named operations** (the app’s verbs) and hides whether data is remote or local.
- **DataSource** is the thinnest IO boundary (Dio, isolate, platform channel, etc.).

**Optional:** a **domain service** (no Flutter) sits between presentation and multiple repositories when one user action truly coordinates several contracts — avoid extra types until that appears.

The **samples** and **announcements** mini-apps under `apps/emp_ai_boilerplate_app/lib/src/miniapps/` follow this shape; **announcements** uses **`cached_query`** for list/detail reads.

**Where that code sits in the host tree** (shell vs platform vs mini-apps) is documented in [host_structure.md](host_structure.md).

## Host app vs packages

| Piece                                                              | Location                                                                                                                                                                 |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `GoRouter` assembly, host mode (super-app / standalone / embedded) | `emp_ai_core` + host `lib/src/shell/router/`                                                                                                                             |
| `MiniApp` contract, hub, shell scaffold, route factory             | `emp_ai_app_shell`                                                                                                                                                       |
| Feature-flag reader contract                                       | `emp_ai_foundation`                                                                                                                                                      |
| Northstar theme + tokens                                           | `emp_ai_ds_northstar`                                                                                                                                                    |
| Optional real auth                                                 | **`emp_ai_auth`** Git dep (Bitbucket); **`emp_ai_ds`** via Git **`ref: myemapta_main`** on the **`ecosystem_boilerplate`** branch ([emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)) |

## Comparison to the wider `lib/` + `packages/` monorepo

The production host is **`emp_ai_flutter_boilerplate`** (repo root `pubspec.yaml`, `lib/`). The ecosystem sample is **`apps/emp_ai_boilerplate_app`**. Below is a **concrete** gap list from reviewing root `lib/main.dart`, `lib/src/main/app.dart`, and root dependencies—not an exhaustive audit of all 1700+ `lib` files.

### What the main app has today (representative)

| Capability                     | Where it shows up (root app)                                                     |
| ------------------------------ | -------------------------------------------------------------------------------- | --- | ------- | ------------------------------------- |
| **Multi-env / flavors**        | `AppEnvironment`, `firebase_options_dev                                          | uat | staging | prod.dart`, `mainCommon(environment)` |
| **Firebase**                   | `firebase_core`, messaging, Crashlytics, Analytics                               |
| **Deep links**                 | `app_links`, subscription in `main.dart` / `MyApp`                               |
| **Push + local notifications** | `firebase_messaging`, `flutter_local_notifications`                              |
| **Feature flags**              | `FeatureFlag`, Split via `emp_ai_ds` (`split_config`, Riverpod providers)        |
| **Auth**                       | `EmpAuth`, token refresh, identity introspect, login providers                   |
| **RBAC / route gates**         | `route_permission_validator`, `app_permissions`, `role_checker_registry`         |
| **Analytics**                  | `emp_ai_ds` `AnalyticsService`, Mixpanel constants                               |
| **DI**                         | **Riverpod + `get_it`** (boilerplate standard is Riverpod-only composition)      |
| **Errors**                     | **`dartz`** `Either` in many flows                                               |
| **UX / platform**              | `loader_overlay`, `overlay_support`, native splash, connectivity / network utils |
| **Large feature modules**      | `announcement_module`, `shop_and_rewards_module`, `emp_ai_chatbot`, etc.         |
| **Layout**                     | `responsive_framework`, `flutter_screenutil`                                     |

### What the ecosystem boilerplate emphasizes instead

| Capability                 | Status in `ecosystem_boilerplate`                                                                                                                                                                                                   |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Layered mini-app slice** | Mini-apps: UI → Notifier / **`cached_query`** → **Repository** → DataSource                                                                                                                                                         |
| **Super-app shell**        | `MiniApp` registry, codegen, hub / stateful shell, host modes                                                                                                                                                                       |
| **Thin contracts**         | `emp_ai_foundation` (flags), `emp_ai_core` (router/Dio shape), Northstar DS package                                                                                                                                                 |
| **Auth**                   | Demo vs `empAiAuth` backends; **host `TokenRefreshAdapter`** + `CoreTokenRefreshService` + Dio interceptors (see [README.md](../README.md#integrations-hub)); `emp_ai_auth` on disk + legacy `emp_ai_ds` from Git (patched pubspec) |

### Suggested enhancements (priority-ordered)

Use this as a backlog to **converge** the sample host with production expectations **without** re-importing all of `emp_ai_ds` into new code.

1. **`Result` / `Either` / sealed failures** — **Done:** `AppResult` / `AppSuccess` / `AppFailure` in `emp_ai_foundation`; **samples** repository returns `AppResult` (notifier maps failures, optional crash sink).
2. **Router guards** — **Hook done:** `boilerplateGoRouterRedirectProvider` → `CoreRouterConfig.redirect` for all host modes. **Your logic:** override the provider (auth, maintenance, roles).
3. **Environment config** — **Done:** `ApplicationHostProfile` + `applicationHostProfileProvider` + **`FLAVOR`** (catalog) + optional **`API_BASE_URL`** / **`VERBOSE_LOGS`** ([README.md](../README.md#integrations-hub)); `boilerplateDioProvider` uses `apiBaseUrl` when set and stacks **bearer header + 401 token-refresh** interceptors. `host_mode.dart` remains for **router topology** (super-app vs embedded).
4. **Observability stub** — **Done:** `AnalyticsSink` / `CrashReportingSink` + no-op providers; samples notifier reports failures to the crash sink.
5. **Deep link sample** — Single `app_links` (or `go_router` extra) example that routes into a mini-app path; documents where subscription lives vs `MyApp`.
6. **Optional `get_it` note** — If org standard remains dual DI, document **what must stay in Riverpod** (notifiers, overrides in tests) vs what may stay in `get_it` during migration.
7. **Offline / cache** — Second datasource + repository policy (cache-then-network) next to samples remote datasource.
8. **Integration test** — One test: hub → open samples → assert notifier state (already listed below).

### Structural note (main `lib/`)

Features under `lib/src/features/*` often follow **presentation / data / domain**, but some trees use **`domain/providers`** (Riverpod next to domain). The boilerplate rule is stricter: **notifiers and `*_providers.dart` live under `presentation/`** so `domain/` stays framework-free. New work should follow the boilerplate layout; legacy folders can migrate gradually.

### Summary table (short)

| Area                    | Main monorepo (typical)                     | This boilerplate                                     |
| ----------------------- | ------------------------------------------- | ---------------------------------------------------- |
| Mini-app modularization | Large modules + globals in `main.dart`      | Explicit `MiniApp` + registry + codegen              |
| Clean architecture      | Varies by feature; some domain/provider mix | **Required** template for new mini-apps              |
| Result / Either         | Often `dartz`                               | **`AppResult`** in foundation + samples              |
| Logging / analytics     | `emp_ai_ds` + Mixpanel + Firebase           | **Sink interfaces** + no-op / host overrides         |
| Flavors / env           | Full Firebase + env enum                    | **`ApplicationHostProfile`** + dart-define           |
| CI                      | Org-wide pipelines                          | Path-filtered workflow under `ecosystem_boilerplate` |

**Enhancements you may add** without breaking the model:

1. **Local datasource** + cache policy next to `SamplesRemoteDataSource` for offline-first demos.
2. **Integration tests** that pump the shell and assert navigation + one notifier path.
3. **Deep links** (`app_links`) wired through a host-owned service + redirect provider.

Treat this document as the **canonical flow** for new code; legacy modules can migrate incrementally.
