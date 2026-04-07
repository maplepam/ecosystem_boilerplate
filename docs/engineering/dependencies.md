# Maintaining dependency versions

## Principles

- **Apps and packages** each have their own `pubspec.yaml` and lockfile behavior: Flutter apps use **`pubspec.lock`** committed for reproducible builds.
- **Workspace** tooling uses the repository root `pubspec.yaml` for shared **`tool/`** scripts; run `dart pub get` there when tool dependencies change.

## Day-to-day

1. **Upgrade a single dependency** in the package or app that owns it:

   ```bash
   cd apps/emp_ai_boilerplate_app
   flutter pub upgrade <package_name>
   ```

2. **Regenerate lockfiles** after edits; commit **`pubspec.lock`** for applications.

3. **Verify**:

   ```bash
   dart run melos run analyze:all
   dart run melos run test:boilerplate
   ```

## Melos, Git deps, and local packages

- **`apps/emp_ai_boilerplate_app`** pulls **ecosystem-platform** and **auth** via **`git:`**; pin **`ref`** together — **[`docs/meta/platform_bom.yaml`](../meta/platform_bom.yaml)**.
- **`melos bootstrap`** runs **`pub get`** / **`flutter pub get`** for every package matched by **`melos.yaml`** (here: **`apps/**`** only).
- Optional **product-only** packages under **`packages/`**: add the folder, extend **`melos.yaml`** `packages:` to include them, use **`path:`** from the app, then **`dart run melos bootstrap`**.

<a id="local-platform-development"></a>

### Local platform development

The boilerplate **`packages/`** folder is intentionally **empty** — platform sources live in **ecosystem-platform**.

1. **Clone** `ecosystem-platform` (e.g. `../ecosystem-platform` relative to this repo root).
2. In **ecosystem-platform**, use **`dart run melos bootstrap`** when you change internal **`path:`** links between packages.
3. In **this repo**, create **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml`** (gitignored) and override **every** consumed platform package you use, typically all five:

   ```yaml
   dependency_overrides:
     emp_ai_foundation:
       path: ../../../ecosystem-platform/packages/emp_ai_foundation
     emp_ai_core:
       path: ../../../ecosystem-platform/packages/emp_ai_core
     emp_ai_ds_northstar:
       path: ../../../ecosystem-platform/packages/emp_ai_ds_northstar
     emp_ai_ds_widgets:
       path: ../../../ecosystem-platform/packages/emp_ai_ds_widgets
     emp_ai_app_shell:
       path: ../../../ecosystem-platform/packages/emp_ai_app_shell
   ```

   Adjust **`path`** if your clone lives elsewhere (absolute paths are fine).

4. From **`apps/emp_ai_boilerplate_app`**: **`flutter pub get`**, then **`flutter analyze`** / run the app.

5. **Before commit:** remove **`pubspec_overrides.yaml`** (or empty overrides); merge platform changes in **ecosystem-platform**, then bump **`pubspec.yaml`** Git **`ref`s** and **[`platform_bom.yaml`](../meta/platform_bom.yaml)** on the boilerplate branch.

Template: [`pubspec_overrides.yaml.example`](../../apps/emp_ai_boilerplate_app/pubspec_overrides.yaml.example).

## Flutter / Dart SDK

- Pin **`environment.sdk`** ranges in each `pubspec.yaml` to what CI and developers use.
- When bumping Flutter, run **full analyze** and fix deprecations across **`apps/*`** and any local **`packages/*`**, and re-resolve **Git** platform deps.

## Transitive conflicts (e.g. auth + legacy DS)

- Document known pairs (e.g. `emp_ai_auth` → legacy `emp_ai_ds`) in the root README; track removal in your backlog.
- Prefer **isolating** new UI on `emp_ai_ds_northstar` so upgrades to auth do not force redesign of new screens.

## Automation (optional)

- Renovate / Dependabot against this repository root with path filters mirroring CI.
- Require **green `analyze:all`** before merging dependency PRs.
