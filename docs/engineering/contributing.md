# Contributing

**Fork / upstream**: how to open PRs to the canonical boilerplate and how product forks can merge or path-pull updates — [upstream_git_workflow.md](upstream_git_workflow.md).

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

## PR description

- State **what** changed and **why** in plain language.
- Link the **ticket** or initiative if applicable.
- Call out **breaking** changes to public package APIs or `MiniApp` shapes.

## Code review focus

- Correct **flow**: UI → Notifier / **`cached_query`** → **Repository** → Impl → DataSource.
- **Testability**: can we fake the repository in tests?
- **Host concerns** (auth, flags) stay out of domain.
