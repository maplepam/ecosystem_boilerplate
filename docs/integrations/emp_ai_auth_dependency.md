# Consuming `emp_ai_auth`

`emp_ai_auth` upstream still lists **`emp_ai_ds`** as `path: ../emp_ai_ds`. This workspace does not vendor **`packages/emp_ai_ds`** (new UI uses **`emp_ai_ds_northstar`**).

## What the boilerplate does

1. **`tool/ensure_emp_ai_auth_clone.dart`** (Melos **bootstrap pre-hook**):
   - Clones **`emp-ai-flutter-auth`** into **`packages/emp_ai_auth`** when missing.
   - **Patches** `packages/emp_ai_auth/pubspec.yaml`: replaces the `emp_ai_ds` **path** block with the same **Git** URL/ref as the old design-system repo (`myemapta_main`).

2. After that, **`flutter pub get`** / **`flutter analyze`** inside **`packages/emp_ai_auth`** work without a sibling `emp_ai_ds` folder.

3. The host app **does not** need **`dependency_overrides`** for `emp_ai_ds` (auth brings it via Git).

### Commands

```bash
dart pub get
dart run melos bootstrap
```

### Private Bitbucket

Configure Git so both clones succeed (HTTPS + app password, or SSH + `ssh-agent`).

### Clone / patch vs submodule

- **Hook + gitignored `packages/emp_ai_auth/`:** patch lives only on disk; safe.
- **`git submodule` for auth:** each **`melos bootstrap`** re-applies the patch if upstream still uses `path: ../emp_ai_ds`, so the submodule working tree becomes **dirty**. Prefer **upstreaming** the `emp_ai_ds` **git** dependency in the auth repo, or clone without submodule and rely on the hook.

### Changing DS URL or branch

Edit **`_dsGitUrl` / `_dsRef`** in `tool/ensure_emp_ai_auth_clone.dart` (and re-run bootstrap so the patch re-applies if you reset `pubspec.yaml`).

## Local overrides

Use **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml`** (gitignored) for machine-specific tweaks — see `pubspec_overrides.yaml.example`.
