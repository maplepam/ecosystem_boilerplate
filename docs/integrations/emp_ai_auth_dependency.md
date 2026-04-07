# Consuming `emp_ai_auth` and platform submodules

Tactical reference for **submodules**, **`pubspec.yaml`**, and **SSH**. For **repository roles** and governance, read **[repositories_overview.md](../engineering/repositories_overview.md)** first.

The host app depends on **`ecosystem-platform`**, **`emp_ai_auth`**, and **`emp_ai_ds`** as **Git submodules** under **`packages/`**, with **`path:`** dependencies in **`apps/emp_ai_boilerplate_app/pubspec.yaml`**. After **`git clone`**, run **`git submodule update --init --recursive`** (or clone with **`--recurse-submodules`**). CI uses **`actions/checkout`** with **`submodules: recursive`** plus SSH for GitHub and Bitbucket.

Submodule **remotes** live in **`.gitmodules`**. **Pins** are the **gitlinks** Git records when you commit — inspect with **`git submodule status`** or **`git -C packages/ecosystem-platform rev-parse HEAD`**.

**`emp_ai_auth`** still declares **`emp_ai_core`** and **`emp_ai_ds`** via **Git** in its own **`pubspec.yaml`**. The host **`dependency_overrides`** force **one** in-tree resolution (see app **`pubspec.yaml`**).

## `pubspec.yaml` shape (host app)

```yaml
dependencies:
  emp_ai_app_shell:
    path: ../../packages/ecosystem-platform/packages/emp_ai_app_shell
  # …same relative base for other platform packages…
  emp_ai_auth:
    path: ../../packages/emp_ai_auth

dependency_overrides:
  emp_ai_core:
    path: ../../packages/ecosystem-platform/packages/emp_ai_core
  emp_ai_ds:
    path: ../../packages/emp_ai_ds
```

## Bumping submodule pins

Use **Git** only:

1. **`cd packages/ecosystem-platform`** (or auth / DS) → **`git fetch`** → **`git checkout <sha-or-tag>`** → back to repo root → **`git add packages/ecosystem-platform`** (or the submodule you moved).
2. **`flutter pub get`** in **`apps/emp_ai_boilerplate_app`** (or **`dart run melos bootstrap`** from root).
3. Commit the **parent** repo (updated gitlinks + **`pubspec.lock`** if it changed).

**Auth** still pinning **`emp_ai_core`** via Git: edit **`emp_ai_core` → `ref`** in the **auth** repo’s **`pubspec.yaml`** to the **same** platform commit your **`packages/ecosystem-platform`** submodule uses, commit/push Bitbucket, then **`git fetch` / `git checkout`** in **`packages/emp_ai_auth`** to that auth commit and **`git add packages/emp_ai_auth`**.

**`emp_ai_ds`:** same pattern inside **`packages/emp_ai_ds`**.

**Before pushing:** **`git submodule status`**, **`dart run melos bootstrap`**, **`flutter analyze`** / **`flutter test`** under **`apps/emp_ai_boilerplate_app`**.

<a id="northstar-tokens-dtcg"></a>

## Northstar tokens (DTCG → Dart)

From the boilerplate root: **`melos run sync:northstar-dtcg -- --light=... --dark=... --white-labeled=...`** — see **[`melos.yaml`](../../melos.yaml)** and **[`tool/sync_northstar_base_tokens_from_dtcg.dart`](../../tool/sync_northstar_base_tokens_from_dtcg.dart)**. Then format/analyze in **ecosystem-platform**.

## Local setup

1. **Submodules:** **`git clone --recurse-submodules <url>`** or **`git submodule update --init --recursive`**.
2. **`dart pub get`** at repo root.
3. **`dart run melos bootstrap`** — **`flutter pub get`** for **`apps/**`**.
4. **SSH** for **GitHub** + **Bitbucket** (submodule URLs).

### Optional: auth `pubspec` with path deps

If **`emp_ai_auth`** uses **`path: ../ecosystem-platform/packages/emp_ai_core`** and **`path: ../emp_ai_ds`**, you can drop host **`dependency_overrides`** for those once that revision is the submodule pointer (requires a Bitbucket commit).

## Alternative: auth inside the platform monorepo

Drop the **auth** submodule; depend on **`path: ../../packages/ecosystem-platform/packages/emp_ai_auth`**.

## Local overrides

**`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml`** (gitignored) — see **`pubspec_overrides.yaml.example`**.
