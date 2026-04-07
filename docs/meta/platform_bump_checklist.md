# Checklist: bumping ecosystem-platform (and keeping the host in sync)

Use this when you advance **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)** and want clones of **ecosystem_boilerplate** to resolve the same Dart sources. For Git URLs, SSH, and solver constraints, see **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

---

## Automation (Melos)

From the **ecosystem_boilerplate** root (after `dart pub get` so workspace deps resolve):

| Command | What it does |
|---------|----------------|
| **`melos run bump:platform-refs -- [<40-char-platform-sha>] [--auth-sha=<sha>] [--dry-run] [--no-pub]`** | If you pass a **platform SHA** (positional or **`--platform-sha=`**), replaces the **current** `platform_git.ref` from **[`platform_bom.yaml`](platform_bom.yaml)** everywhere it appears in **`apps/emp_ai_boilerplate_app/pubspec.yaml`**, the BOM, **[`emp_ai_auth_dependency.md`](../integrations/emp_ai_auth_dependency.md)**, and **[`miniapp_packages_and_extract.md`](../engineering/miniapp_packages_and_extract.md)**. Omit the platform SHA to leave it unchanged (**auth-only** bump). If **`--auth-sha`** is set and the BOM **`auth_git.ref`** is already a **40-character SHA**, it updates auth refs in the BOM, **`pubspec.yaml`**, and **`emp_ai_auth_dependency.md`**. Then runs **`flutter pub get`** in the app (unless **`--no-pub`** or **`--dry-run`**). You must still bump **`emp_ai_core`** in **emp-ai-flutter-auth** when the platform SHA changes (see §1). |
| **`melos run sync:northstar-dtcg -- --light=PATH --dark=PATH --white-labeled=PATH [--output=...] [--dry-run]`** | Rewrites **`NorthstarBaseTokens`** `Color(0x…)` values in **`northstar_base_tokens.dart`** from three Figma DTCG JSON exports. Default **`--output`**: **`../ecosystem-platform/packages/emp_ai_ds_northstar/lib/src/northstar_base_tokens.dart`** (sibling clone). Then run **`dart format`** on that file and **`dart analyze`** / **`flutter analyze`** in **ecosystem-platform**. |

Underlying scripts: **[`tool/bump_platform_refs.dart`](../../tool/bump_platform_refs.dart)**, **[`tool/sync_northstar_base_tokens_from_dtcg.dart`](../../tool/sync_northstar_base_tokens_from_dtcg.dart)**.

---

## 1. Outside this repo (required for a clean `pub get`)

| Where | What to change |
|--------|----------------|
| **ecosystem-platform** | Merge your work; note the **full commit SHA** (or tag) you want products to pin. |
| **emp-ai-flutter-auth** (`emp_ai_auth`) | In **`pubspec.yaml`**, set **`emp_ai_core`** → **`git`** → **`ref:`** to the **same platform SHA** as the host. Without this, Pub fails: the host and auth cannot request two different revisions of **`emp_ai_core`**. Push to the branch your products use (e.g. **`ecosystem_boilerplate`**). |

Then either:

- Pin **`emp_ai_auth`** in the host by **commit SHA** (recommended after you change auth’s `pubspec`), **or**
- Keep a **branch** ref and run **`flutter pub upgrade emp_ai_auth`** so **`pubspec.lock`** picks up the new auth tree (ensure CI and teammates refresh the lock).

---

## 2. This repo — files you must update

| File | What |
|------|------|
| **[`apps/emp_ai_boilerplate_app/pubspec.yaml`](../../apps/emp_ai_boilerplate_app/pubspec.yaml)** | Set the **same** **`ref:`** on **every** Git dependency whose URL is **ecosystem-platform** (`emp_ai_foundation`, `emp_ai_core`, `emp_ai_ds_northstar`, `emp_ai_ds_widgets`, `emp_ai_app_shell`). Update **`emp_ai_auth`** **`ref:`** if you pin auth by SHA/tag. |
| **[`apps/emp_ai_boilerplate_app/pubspec.lock`](../../apps/emp_ai_boilerplate_app/pubspec.lock)** | Regenerate with **`flutter pub get`** (from **`apps/emp_ai_boilerplate_app/`**, or via **`dart run melos bootstrap`** from the repo root). **Commit** the lockfile. |
| **[`docs/meta/platform_bom.yaml`](platform_bom.yaml)** | Set **`platform_git.ref`** to the same SHA as **`pubspec.yaml`**. Set **`auth_git.ref`** to match how the host pins **`emp_ai_auth`**. **`legacy_ds_git`** only changes when the auth package’s transitive **`emp_ai_ds`** pin changes. |

**Do not commit** **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml`** (gitignored). Remove or empty overrides before bumping pins for real; see **[dependencies.md](../engineering/dependencies.md#local-platform-development)**.

---

## 3. This repo — documentation that embeds example SHAs

These files include **copy-paste YAML** (or similar) with a **literal platform `ref:`**. After a bump, either update them to the new SHA or replace the example with a placeholder and point readers at **`platform_bom.yaml`**.

| File | Note |
|------|------|
| **[`docs/integrations/emp_ai_auth_dependency.md`](../integrations/emp_ai_auth_dependency.md)** | Example **`pubspec.yaml`** block (platform + auth refs). |
| **[`docs/engineering/miniapp_packages_and_extract.md`](../engineering/miniapp_packages_and_extract.md)** | External mini-app sample **`emp_ai_app_shell`** **`git`** / **`ref:`**. |

**Finding stragglers:** from the repo root, search for the **old** SHA or for Git blocks:

```bash
rg 'ref:\s+[0-9a-f]{40}' docs apps --glob '*.md' --glob '*.yaml'
rg 'maplepam/ecosystem-platform\.git' docs apps --glob '*.md' --glob '*.yaml'
```

---

## 4. Usually *no* change needed on bump

- **Docs that link to `.../blob/main/...` on GitHub** — they track **`main`**, not your pin; optional to update.
- **`.github/workflows/ci.yml`** — no pinned SHAs; it resolves whatever **`pubspec.yaml`** + lock specify (SSH secrets must still allow GitHub + Bitbucket).
- **Root `README.md`**, **onboarding**, **architecture** — they describe *process*; only edit if you change **policy** (e.g. always pin auth by SHA).

---

## 5. Verify before you push

1. **`dart run melos bootstrap`** (or **`flutter pub get`** in the app).
2. **`flutter analyze`** / **`flutter test`** under **`apps/emp_ai_boilerplate_app`**.
3. Optional: confirm BOM matches app pins, e.g. **`platform_git.ref`** equals each ecosystem-platform **`ref`** in **`pubspec.yaml`**.

---

## Related

- **[platform_bom.yaml](platform_bom.yaml)** — canonical recorded pins.
- **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)** — auth + platform + Pub constraints.
- **[repositories_overview.md](../engineering/repositories_overview.md) § versioning** — roles of each repo.
- **[getting_started.md § platform upgrade](../onboarding/getting_started.md)** — short narrative flow.
