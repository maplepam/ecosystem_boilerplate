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

## Melos, submodules, and local packages

- **`apps/emp_ai_boilerplate_app`** uses **`path:`** dependencies into **`packages/ecosystem-platform`**, **`packages/emp_ai_auth`**, and **`packages/emp_ai_ds`** (Git **submodules**). Bump submodule commits with Git — **[emp_ai_auth_dependency.md § Bumping submodule pins](../integrations/emp_ai_auth_dependency.md#bumping-submodule-pins)**.
- **`melos bootstrap`** runs **`pub get`** / **`flutter pub get`** for every package matched by **`melos.yaml`** (here: **`apps/**`** only). It does **not** run **`git submodule update`** — initialize submodules after clone first.
- Optional **product-only** packages under **`packages/`** (not submodules): add the folder, extend **`melos.yaml`** `packages:` to include them, use **`path:`** from the app, then **`dart run melos bootstrap`**.

<a id="local-platform-development"></a>

### Local platform development

Default layout: **`packages/ecosystem-platform`** is already a **submodule**. For a **separate** clone (e.g. two checkouts while a platform PR is in flight):

1. **Clone** `ecosystem-platform` elsewhere (e.g. `../ecosystem-platform` next to this repo).
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

   Or point at the in-repo submodule with **`../../packages/ecosystem-platform/packages/...`** from the app directory if you only need a branch tip without changing the submodule pointer yet.

   Adjust **`path`** if your clone lives elsewhere (absolute paths are fine).

4. From **`apps/emp_ai_boilerplate_app`**: **`flutter pub get`**, then **`flutter analyze`** / run the app.

5. **Before commit:** remove **`pubspec_overrides.yaml`** (or empty overrides); merge platform changes in **ecosystem-platform**, then **`git checkout`** the new commit in **`packages/ecosystem-platform`** and **`git add packages/ecosystem-platform`** on the boilerplate branch.

Template: [`pubspec_overrides.yaml.example`](../../apps/emp_ai_boilerplate_app/pubspec_overrides.yaml.example).

## Flutter / Dart SDK

- Pin **`environment.sdk`** ranges in each `pubspec.yaml` to what CI and developers use.
- When bumping Flutter, run **full analyze** and fix deprecations across **`apps/*`** and any local **`packages/*`**, and re-resolve dependencies.

## Transitive conflicts (e.g. auth + legacy DS)

- Document known pairs (e.g. `emp_ai_auth` → legacy `emp_ai_ds`) in the root README; track removal in your backlog.
- Prefer **isolating** new UI on `emp_ai_ds_northstar` so upgrades to auth do not force redesign of new screens.

## Automation (optional)

- Renovate / Dependabot against this repository root with path filters mirroring CI.
- Require **green `analyze:all`** before merging dependency PRs.
