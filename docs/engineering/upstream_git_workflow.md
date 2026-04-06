# Upstream Git workflow: contribute to the boilerplate, pull updates into a fork

This repository is a **Melos monorepo**: packages under `packages/`, the host app under `apps/`, mini-apps as slices + **`miniapps_registry.yaml`**. There is **no separate Git repo per package** inside the workspace — history and PRs live **here**.

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

### 2. New **package** (`packages/some_package`)

1. Add `packages/some_package/` with `pubspec.yaml`, `lib/`, tests as needed — see [packages.md](packages.md).
2. Wire **path dependencies** from consumers (`apps/...` or other packages).
3. Run **`dart run melos bootstrap`**, **`dart run melos run analyze:all`**, and tests that touch the new surface.

Open a **PR to `upstream`** (target **`main`** unless your org uses another default). Keep the PR **scoped** (prefer one package or one theme per PR so review and rollback stay simple).

### 3. New **mini-app**

1. From repo root: **`dart run melos run create:miniapp -- my_feature`** — see [miniapps.md](miniapps.md).
2. Run **`dart run melos run generate:miniapps`** so `miniapp_catalog.g.dart` matches **`miniapps_registry.yaml`**.
3. Implement routes/screens, flags if needed, and at least a **smoke widget test** when the mini-app is meant for reuse.
4. PR to upstream with a short **note for other teams** (how to register the mini-app in *their* host if the entry is optional).

### 4. Updates to **existing** packages (e.g. `emp_ai_core`, `emp_ai_ds_widgets`)

Same as any shared library change:

- Prefer **additive** API changes; document **breaking** changes in PR description and bump **`version`** + **CHANGELOG** when your process requires it.
- Run **analyze** across the workspace (`melos run analyze:all`) because many packages depend on core and DS.

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

### B. Bring **only specific paths** from upstream (one package or mini-app)

After **`git fetch upstream`**, check out **paths from `upstream/main`** into your branch:

```bash
# Example: only refresh emp_ai_core from upstream
git checkout upstream/main -- packages/emp_ai_core

# Example: only refresh DS widgets + barrel exports (adjust paths as needed)
git checkout upstream/main -- packages/emp_ai_ds_widgets

# Example: one mini-app slice + registry + generated catalog (all three should stay consistent)
git checkout upstream/main -- apps/emp_ai_boilerplate_app/lib/src/miniapps/my_feature
git checkout upstream/main -- miniapps_registry.yaml
# Then always regenerate the catalog locally:
dart run melos run generate:miniapps
```

Then **commit** the result on your branch. Fix any **merge conflicts** if those paths were edited on your side.

**Caveats**

- Path-based checkout **does not** apply upstream commits you did not select; you may need **transitive** paths (e.g. if upstream split a package or renamed folders).
- If upstream changed **shared** files (`melos.yaml`, root `pubspec.yaml`, CI), you may still need a **full merge** occasionally.
- **`packages/emp_ai_auth`** is often **cloned by Melos** from another remote — pulling “only auth” is a different process; see [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md).

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
| Ship **fixes/features** in `emp_ai_core` / `emp_ai_ds_*` for everyone | Same: **PR upstream**; avoid drive-by unrelated edits. |
| Refresh your fork from upstream | **`git merge upstream/main`** (or rebase), then **bootstrap** + **generate:miniapps** if needed. |
| Take **only** `packages/emp_ai_core` (or one mini-app) | **`git checkout upstream/main -- <paths>`** + regenerate + commit; or **cherry-pick** specific SHAs. |

For day-to-day code standards and layer rules, use [contributing.md](contributing.md). For scaffolding details, use [packages.md](packages.md) and [miniapps.md](miniapps.md).
