# Upstream Git workflow: contribute to the boilerplate, pull updates into a fork

This repository is a **Melos workspace** for the **host app** under **`apps/`**, mini-apps as slices + **`miniapps_registry.yaml`**, and root tooling. **Platform** packages (`emp_ai_core`, `emp_ai_app_shell`, design system, …), **`emp_ai_auth`**, and **`emp_ai_ds`** live as **Git submodules** under **`packages/`** and are consumed via **`path:`** from the host app. See **[repositories_overview.md](repositories_overview.md)** and **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

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

Contribute in **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)** (separate clone/PRs). After a release, **`git checkout <sha>`** in **`packages/ecosystem-platform`**, **`git add packages/ecosystem-platform`**, and commit on the boilerplate branch. See **[emp_ai_auth_dependency.md — Bumping submodule pins](../integrations/emp_ai_auth_dependency.md#bumping-submodule-pins)**.

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

**Platform** sources are the **`packages/ecosystem-platform`** submodule — refresh the pointer with **`git fetch` / `git checkout`** in that submodule and **`git add`** on the parent repo, or open a PR on **ecosystem-platform** and then bump here.

Then **commit** the result on your branch. Fix any **merge conflicts** if those paths were edited on your side.

**Caveats**

- Path-based checkout **does not** apply upstream commits you did not select; you may need **transitive** paths if upstream renamed folders.
- If upstream changed **shared** files (`melos.yaml`, root `pubspec.yaml`, CI), you may still need a **full merge** occasionally.
- **`emp_ai_auth`** and **`emp_ai_ds`** are **submodules** — bump their commits with **`git checkout`** + **`git add`**; see [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md).

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
| Ship **fixes/features** in `emp_ai_core` / `emp_ai_ds_*` for everyone | **PR** to **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)**; then **`git checkout`** in **`packages/ecosystem-platform`** + **`git add`**. |
| Refresh your fork from upstream | **`git merge upstream/main`** (or rebase), then **`git submodule update --init --recursive`**, **bootstrap** + **generate:miniapps** if needed. |
| Bump **platform** (`emp_ai_core`, …) | New commit on **ecosystem-platform** → **`git checkout <sha>`** in **`packages/ecosystem-platform`** + **`git add packages/ecosystem-platform`**. |
| Take **only** one mini-app (this repo) | **`git checkout upstream/main -- <paths>`** + **`generate:miniapps`** + commit; or **cherry-pick** specific SHAs. |

For day-to-day code standards and layer rules, use [contributing.md](contributing.md). For scaffolding details, use [packages.md](packages.md) and [miniapps.md](miniapps.md).
