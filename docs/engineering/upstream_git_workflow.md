# Upstream Git workflow: contribute to the boilerplate, pull updates into a fork

This repository is a **Melos workspace** for the **host app** under **`apps/`**, mini-apps as slices + **`miniapps_registry.yaml`**, and root tooling. **Platform** Dart packages (`emp_ai_core`, `emp_ai_app_shell`, design system, …) are **not** vendored here — they resolve from **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)** via **Git** dependencies; **`emp_ai_auth`** resolves from **Bitbucket**. See **[repositories_overview.md](repositories_overview.md)** and **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

This file still applies to **forks and PRs** against **ecosystem_boilerplate** (and separately to **ecosystem-platform** if you contribute there).

## Roles

| Role | Repository | Goal |
|------|------------|------|
| **Platform / boilerplate maintainers** | Canonical `ecosystem_boilerplate` (upstream) | Merge PRs, tag releases, keep CI green. |
| **Product team** | **Fork** or **clone** of upstream (often private) | Ship a product; optionally **push improvements back** as PRs to upstream. |

Treat the **canonical boilerplate** as **`upstream`**. Your fork or internal mirror is **`origin`**.

---

## Contributing a new package or mini-app (or updates) to upstream

### 1. Git setup (contributor)

```bash
git remote add upstream https://<host>/<org>/ecosystem_boilerplate.git   # if you cloned only your fork
git fetch upstream
git checkout -b feature/my-contribution upstream/main    # or rebase your main on upstream/main first
```

### 2. New **package** (product-only, under `packages/`)

If the package is **not** part of the shared platform, add **`packages/some_package/`** with `pubspec.yaml`, `lib/`, tests — see [packages.md](packages.md). Add that glob to **`melos.yaml`** if you introduce a new local package. **Shared** libraries belong in **ecosystem-platform** instead.

1. Wire **`path:`** or **`git:`** from consumers (`apps/...`).
2. Run **`dart run melos bootstrap`**, **`dart run melos run analyze:all`**, and tests that touch the new surface.

Open a **PR to `upstream`** (target **`main`** unless your org uses another default). Keep the PR **scoped** (prefer one package or one theme per PR so review and rollback stay simple).

### 3. New **mini-app**

1. From repo root: **`dart run melos run create:miniapp -- my_feature`** — see [miniapps.md](miniapps.md).
2. Run **`dart run melos run generate:miniapps`** so `miniapp_catalog.g.dart` matches **`miniapps_registry.yaml`**.
3. Implement routes/screens, flags if needed, and at least a **smoke widget test** when the mini-app is meant for reuse.
4. PR to upstream with a short **note for other teams** (how to register the mini-app in *their* host if the entry is optional).

### 4. Updates to **platform** packages (`emp_ai_core`, `emp_ai_ds_widgets`, …)

Contribute in **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)** (separate clone/PRs). After a release, bump the **`ref`** in this repo’s **`pubspec.yaml`** (and **[BOM](../meta/platform_bom.yaml)**) to match.

- Prefer **additive** API changes; document **breaking** changes and bump **`version`** + **CHANGELOG** when your process requires it.
- Run **analyze** in **both** repos as appropriate.

### 5. PR hygiene (aligns with [contributing.md](contributing.md))

- One coherent change per PR when possible.
- Call out **public API** or **`MiniApp`** shape changes.
- Ensure **CI** (analyze, `generate_miniapps`, boilerplate tests) would pass — see [ci_cd.md](../platform/ci_cd.md#github-actions-in-this-repo).

**Merge strategy** (squash vs merge vs rebase, versioning, review checklist): [maintainer_policy.md](maintainer_policy.md). Forks should **`git fetch upstream`** and merge or rebase **`upstream/main`** regularly to avoid giant drift.

---

## If your product already forked the boilerplate: pull only what you need

Because this is a **single repo**, you do not `git pull` “just `emp_ai_core`” as a separate remote by default. Practical options:

### A. Merge or rebase **all** of upstream (recommended when feasible)

```bash
git fetch upstream
git checkout main
git merge upstream/main          # or: git rebase upstream/main
dart run melos bootstrap
dart run melos run generate:miniapps   # if registry or tool changed upstream
dart run melos run analyze:all
dart run melos run test:boilerplate
```

Resolve conflicts in **`pubspec.yaml` / `pubspec_overrides.yaml`**, host-only files, and any paths you customized.

### B. Bring **only specific paths** from upstream (host / mini-apps in this repo)

After **`git fetch upstream`**, check out **paths from `upstream/main`** into your branch (examples):

```bash
# Example: one mini-app slice + registry + generated catalog (all three should stay consistent)
git checkout upstream/main -- apps/emp_ai_boilerplate_app/lib/src/miniapps/my_feature
git checkout upstream/main -- miniapps_registry.yaml
# Then always regenerate the catalog locally:
dart run melos run generate:miniapps
```

**Platform** package sources are **not** in this tree — refresh them by changing **`ref`** in **`apps/emp_ai_boilerplate_app/pubspec.yaml`** / **[BOM](../meta/platform_bom.yaml)** or by opening a PR on **ecosystem-platform**.

Then **commit** the result on your branch. Fix any **merge conflicts** if those paths were edited on your side.

**Caveats**

- Path-based checkout **does not** apply upstream commits you did not select; you may need **transitive** paths if upstream renamed folders.
- If upstream changed **shared** files (`melos.yaml`, root `pubspec.yaml`, CI), you may still need a **full merge** occasionally.
- **`emp_ai_auth`** and transitive **`emp_ai_ds`** are **Git** dependencies — bump **`ref`** in **`pubspec.yaml`** / BOM; see [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md).

### C. **Cherry-pick** known upstream commits

When upstream merged a fix you want **without** merging all of `main`:

```bash
git fetch upstream
git cherry-pick <sha>
```

Useful for **targeted** bugfixes; fragile if the commit assumes other upstream changes — run **analyze** and tests after.

### D. **Published packages** (if your org publishes to a private pub server)

Some teams **extract** a package to a **versioned** pub dependency later. That flow is **outside** this monorepo default; see [packages.md](packages.md#maintaining-packages-and-rolling-updates-to-other-teams). Until then, **path** packages + git upstream are the norm.

---

## Summary

| Goal | Approach |
|------|----------|
| Share a **new package** or **mini-app** with all teams | Open a **PR to upstream** `main`; keep changes scoped; run **melos** + **analyze** + tests. |
| Ship **fixes/features** in `emp_ai_core` / `emp_ai_ds_*` for everyone | **PR** to **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)**; then bump **`ref`** here. |
| Refresh your fork from upstream | **`git merge upstream/main`** (or rebase), then **bootstrap** + **generate:miniapps** if needed. |
| Bump **platform** (`emp_ai_core`, …) | New **tag/SHA** on **ecosystem-platform** → update **`pubspec.yaml`** + **[BOM](../meta/platform_bom.yaml)**. |
| Take **only** one mini-app (this repo) | **`git checkout upstream/main -- <paths>`** + **`generate:miniapps`** + commit; or **cherry-pick** specific SHAs. |

For day-to-day code standards and layer rules, use [contributing.md](contributing.md). For scaffolding details, use [packages.md](packages.md) and [miniapps.md](miniapps.md).
