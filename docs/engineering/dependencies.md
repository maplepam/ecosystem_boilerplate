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

## Melos and path packages

- Internal **`path:`** dependencies resolve to local folders; `melos bootstrap` runs `pub get` across the graph.
- After adding or renaming a package, always **`dart run melos bootstrap`**.

## Flutter / Dart SDK

- Pin **`environment.sdk`** ranges in each `pubspec.yaml` to what CI and developers use.
- When bumping Flutter, run **full analyze** and fix deprecations across `packages/*` and `apps/*`.

## Transitive conflicts (e.g. auth + legacy DS)

- Document known pairs (e.g. `emp_ai_auth` → legacy `emp_ai_ds`) in the root README; track removal in your backlog.
- Prefer **isolating** new UI on `emp_ai_ds_northstar` so upgrades to auth do not force redesign of new screens.

## Automation (optional)

- Renovate / Dependabot against this repository root with path filters mirroring CI.
- Require **green `analyze:all`** before merging dependency PRs.
