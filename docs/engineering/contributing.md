# Contributing

**Where code lives:** shared **`emp_ai_*`** packages are developed in **ecosystem-platform**; **`emp_ai_auth`** in the auth repository; this repo holds the **host**, **mini-apps**, **docs**, and **tooling**. See **[repositories_overview.md](repositories_overview.md)** before opening a PR so changes land in the right Git remote.

**Fork / upstream:** how to open PRs to the canonical boilerplate and how product forks merge or path-pull updates — [upstream_git_workflow.md](upstream_git_workflow.md).

## Must do (strict implementation)

1. **Respect layer boundaries** (see [architecture.md](architecture.md)):
   - `domain/` has **no** imports from `data/`, `presentation`, `flutter`, `dio`, or vendor SDKs.
   - `data/` implements **only** domain contracts; DTOs stay in `data/`.
   - `presentation/` owns **Riverpod notifiers**, **`presentation/di/`** providers, and widgets; notifiers and **`cached_query`** factories call the **repository**, not Dio.

2. **Dependency direction**: outer layers depend on inner abstractions, never the reverse.

3. **Results**: prefer **`AppResult<T>`** from `emp_ai_foundation` at repository boundaries; map failures in notifiers (see samples mini-app).

4. **Riverpod**:
   - Prefer **`AsyncNotifier` / `Notifier`** with explicit provider files for wiring.
   - Use **`const`** constructors where possible; **`final`** for fields; **trailing commas** in multi-line argument lists (project style).

5. **New mini-apps**: scaffold with **`melos run create:miniapp`**, then **`melos run generate:miniapps`**; do not hand-edit generated catalog files without updating the registry.

6. **Analyze and test before PR** (same shape as [GitHub Actions CI](../platform/ci_cd.md#github-actions-in-this-repo)):

   ```bash
   dart run melos run analyze:all
   dart run melos run test:boilerplate
   ```

   `test:boilerplate` runs `flutter test` for the boilerplate app. Widget tests that need a signed-in user should use [`boilerplateAuthenticatedTestOverrides()`](../../apps/emp_ai_boilerplate_app/test/support/boilerplate_auth_test_overrides.dart) (see `test/widget_test.dart`).

7. **Tests**: add or update tests when behavior changes (overridden **repository** / datasource providers are the highest leverage).

8. **Design system**: new UI uses **`emp_ai_ds_northstar`** tokens/theme; do not introduce ad-hoc colors for shared components.

## Hard no

1. **No business logic in widgets** beyond trivial formatting: use notifiers, **`cached_query`**, and the **repository** via providers — not ad-hoc HTTP in `build`.

2. **No `Dio`, `http`, or JSON parsing in `domain/`**.

3. **No direct feature-flag or auth SDK calls from `domain/`**.

4. **No circular imports** between packages or between mini-app layers.

5. **Do not bypass** `miniapps_registry.yaml` for catalog registration (keeps codegen and CI honest).

6. **No drive-by refactors** unrelated to the task in the same PR (keep diffs reviewable).

<a id="adding-sdks-and-integrations"></a>

## Adding SDKs and third-party integrations

Use this when you add a vendor SDK (analytics, crash reporting, remote flags, maps, payments, …).

### Principles

1. **Contracts** in **`emp_ai_foundation`** (or a small package) when the abstraction is shared across apps.
2. **Implementations** in the host under **`lib/src/platform/<capability>/`** (host-wide services) or **`lib/src/integrations/<system>/`** (adapters used by several mini-apps). One-off Riverpod glue may live under **`lib/src/providers/`**.
3. **Domain / mini-apps** depend on **interfaces** or **providers** — not on `Firebase.initialize`, `Mixpanel.init`, or vendor types directly.

### Steps

1. Add the package to **`apps/emp_ai_boilerplate_app/pubspec.yaml`** (or a shared package if multiple apps ship it).
2. **Create or reuse** a foundation interface (`AnalyticsSink`, `CrashReportingSink`, `FeatureFlagSource`, …) when one exists.
3. **Implement** the adapter under **`platform/`** or **`integrations/`**.
4. **Register** a `Provider` beside the adapter or from **`boilerplate_startup_overrides.dart`** so **one place** turns the SDK on (often `--dart-define` or flavor).
5. **Document** a short bullet in [docs/README.md — integrations hub](../README.md#integrations-hub); for long write-ups add **`docs/integrations/<topic>.md`** and link it from the hub.

### Where to look today

| Concern | Doc / code |
|---------|------------|
| Analytics | [analytics_mixpanel.md](../integrations/analytics_mixpanel.md), [analytics_firebase.md](../integrations/analytics_firebase.md), [HOST_SERVICES.md](../platform/HOST_SERVICES.md) |
| Crash / logs | [`observability_providers.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/observability_providers.dart), [HOST_SERVICES.md](../platform/HOST_SERVICES.md) |
| Feature flags | [`boilerplate_feature_flags.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart), [feature_flags.md](../integrations/feature_flags.md) |
| Notifications | [HOST_SERVICES.md](../platform/HOST_SERVICES.md) |

### Anti-patterns

- Vendor SDK imports from **`domain/`** or mini-app **`domain/`**.
- **`Firebase.initializeApp`** scattered in `main()` without a guarded host module (hard to test and disable).

Layer rules: [architecture.md](architecture.md).

## PR description

- State **what** changed and **why** in plain language.
- Link the **ticket** or initiative if applicable.
- Call out **breaking** changes to public package APIs or `MiniApp` shapes.

## Code review focus

- Correct **flow**: UI → Notifier / **`cached_query`** → **Repository** → Impl → DataSource.
- **Testability**: can we fake the repository in tests?
- **Host concerns** (auth, flags) stay out of domain.
