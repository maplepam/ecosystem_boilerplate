# Packages: adding, versioning, and distributing updates

## Adding a new workspace package

1. **Create** `packages/<package_name>/` (under this repository root) with:
   - `pubspec.yaml` (`name`, `version`, `environment`, `dependencies`).
   - `lib/<package_name>.dart` as the public API barrel (export only what consumers need).
   - `analysis_options.yaml` if you need stricter rules than the root.

2. **Register in Melos**: the glob `packages/**` in `melos.yaml` already picks it up. Run:

   ```bash
   dart run melos bootstrap
   ```

3. **Depend from apps or other packages** using **path** deps while developing inside the monorepo:

   ```yaml
   dependencies:
     my_new_package:
       path: ../../packages/my_new_package
   ```

4. **Document** the package’s role (contracts vs implementation) in its `README.md` (one short paragraph is enough).

## Package boundaries (recommended)

| Kind | Example | Depends on |
|------|---------|------------|
| Contracts only | `emp_ai_foundation` | Minimal SDK |
| Design tokens / theme | `emp_ai_ds_northstar` | Flutter material |
| Design-system widgets | `emp_ai_ds_widgets` | `emp_ai_ds_northstar`, `go_router` (where needed) |
| Routing / Dio config | `emp_ai_core` | `go_router`, `dio`, foundation |
| Shell / MiniApp | `emp_ai_app_shell` | `go_router`, foundation |
| Feature implementation | future `emp_ai_split` | vendor SDK + foundation |

Avoid **circular** package dependencies; keep **interfaces** in foundation or core, implementations in leaf packages.

### `emp_ai_ds_northstar` vs `emp_ai_ds_widgets`

The repo splits the design system into a **token + primitive** package and a **composition + behavior** package so tokens stay reusable (including white-label) without pulling navigation, drawers, or product flows into the lowest layer.

**`emp_ai_ds_northstar`** is the Northstar V3 source of truth for colors, typography, theme builders, the icon registry, **`NorthstarSpacing` / `NorthstarSpacingToken`**, branding bundles, and **`lib/src/atomic/`** — small presentational pieces that map to Figma **atoms** (or trivial molecules): text atom, labeled row, page header, and reference widgets such as **`NorthstarSpacingScaleTable`** and **`NorthstarDesignSystemShowcasePage`**. Do **not** add `go_router`, shell auth, or feature-specific copy here.

**`emp_ai_ds_widgets`** holds reusable Northstar-styled widgets (buttons, chips, avatars, accordion, search field, drawer, dashboard shells, tri-state helpers, etc.) that **compose** primitives and define **interaction** (tap, expand, loading, selection). Prefer **`NorthstarSpacing`** and **`NorthstarColorTokens.of(context)`** (or the theme extension) instead of raw pixel literals when the value matches the Figma scale. New catalog widgets should be exported from **`lib/emp_ai_ds_widgets.dart`** and listed in **`NorthstarWidgetLibraryPage.builtInEntries()`** when they are part of the supported library (including **spacing** — `NorthstarSpacing` / `NorthstarSpacingScaleTable`).

| If this is true… | Put it in… |
|------------------|------------|
| Only colors / type / spacing / theme, or a tiny visual primitive | `emp_ai_ds_northstar` |
| Combines atoms, handles gestures, or encodes a reusable UX pattern | `emp_ai_ds_widgets` |
| Needs `go_router` or app-shell concepts | `emp_ai_ds_widgets` or higher — **not** northstar |

## Maintaining packages and rolling updates to other teams

**Git workflow** (forks, PRs to upstream, pulling a single package path): [upstream_git_workflow.md](upstream_git_workflow.md).

Teams that maintain **their own boilerplate fork** or **vendored copy** of these packages should treat this repo as **upstream**:

1. **Source of truth**: `packages/*` in this repository (or a tagged release branch).
2. **Consuming updates**:
   - **Git subtree / submodule**: pull upstream changes into their mirror path.
   - **Published packages**: if you publish to a private pub server, bump semver and run `dart pub upgrade` in consumer apps.
   - **Copy-paste migration**: diff the package folder against theirs and port commits intentionally (error-prone; prefer git history).

3. **Communication**: breaking changes require **changelog entry**, **version bump**, and a short **migration note** (e.g. renames on `MiniApp` or router factory).

4. **Compatibility tests**: downstream teams should run their app’s `flutter analyze` and critical integration tests after upgrading a shared package.

## Versioning policy (suggested)

**Maintainer depth** (do’s/don’ts, semver habits, merge/rebase commands, review checklist): [maintainer_policy.md](maintainer_policy.md).

- **Pre-1.0** packages: minor bumps for small API additions, patch for fixes; document breaking renames in CHANGELOG.
- **Shared contracts** (`foundation`, `app_shell`): prefer **additive** changes (new optional parameters, new types) over breaking removals.

## When to add a package vs a folder in the app

- **Multiple apps or mini-apps** need the same code → **package**.
- **Single mini-app only** → keep inside that mini-app’s `domain` / `data` / `presentation` until a second consumer appears.
