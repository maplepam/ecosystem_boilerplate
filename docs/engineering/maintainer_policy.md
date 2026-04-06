# Maintainer policy: versioning, review, and merge strategies

For **contributor** Git workflow (forks, path pull), see [upstream_git_workflow.md](upstream_git_workflow.md). This page is for **canonical boilerplate maintainers**: how to version packages, what to enforce in review, and **concrete Git / GitHub** steps for merging PRs.

---

## Versioning: do’s and don’ts

### Do

- **Bump `version:` in `pubspec.yaml`** for any package whose **public API** or **behavior contract** other packages rely on, when you want forks to reason about “what changed.” Pre-1.0 is normal (`0.1.0`, `0.2.0`, …).
- **Prefer additive changes** in shared packages (`emp_ai_foundation`, `emp_ai_app_shell`, `emp_ai_core`): new optional parameters, new types, new exports — over renaming/removing without a story.
- **Document breaking changes** in the PR description and, when you maintain one, a **CHANGELOG.md** per package or a single repo **CHANGELOG** section for releases.
- **Tag the monorepo** when you cut a “known good” snapshot for other teams (e.g. `boilerplate-2026.03.1` or semver if you adopt repo-wide versioning). Tags are optional but help forks **`git merge v2026.03.1`** or compare diffs.
- **Run the same checks as CI** before merging: `dart run melos bootstrap`, `dart run melos run generate:miniapps` if the registry or generator changed, `dart run melos run analyze:all`, `dart run melos run test:boilerplate`.

### Don’t

- **Don’t silently break** `MiniApp` shape, `GoRoute` paths used in docs, or **generated** `miniapp_catalog.g.dart` without updating **`miniapps_registry.yaml`** and regenerating.
- **Don’t mix unrelated refactors** with a version bump in one PR (hard to revert and hard to explain in release notes).
- **Don’t treat `pubspec.lock`** in **packages** as the cross-team contract — **path** dependencies and **`version:` in pubspec** are; apps own their lockfiles.
- **Don’t publish** to pub.dev from this boilerplate without org approval; internal **private pub** is a separate release process (see [packages.md](packages.md)).

### Suggested semver habits (packages still on `0.x`)

| Change | Suggested bump |
|--------|----------------|
| Bugfix, internal only, no API change | **Patch** `0.1.0 → 0.1.1` |
| New public API, backward compatible | **Minor** `0.1.1 → 0.2.0` (or `0.1.2` if you use minor only for “features”) — **pick one rule per org and stick to it** |
| Rename/remove public types, change required params | **Minor** with **breaking** callout pre-1.0, or reserve **1.0** and then **major** |

Align with [packages.md — Versioning policy](packages.md#versioning-policy-suggested).

---

## Review checklist (maintainers)

1. **Scope**: PR does one thing (or one package / one mini-app) where possible.
2. **Layers**: No domain importing Dio/SDK; matches [contributing.md](contributing.md).
3. **Registry / codegen**: `miniapps_registry.yaml` ↔ `generate:miniapps` if touched.
4. **Public API**: Exports from package barrels are intentional; breaking changes called out.
5. **Tests**: New behavior has tests when risk is non-trivial.
6. **Auth / secrets**: No committed tokens; defines documented in [dart_defines.md](../platform/dart_defines.md) / [environment.md](../integrations/environment.md).

---

## Merge policy: merge vs squash vs rebase

Choose based on how much history you want on `main`.

| Strategy | When to use | History on `main` |
|----------|-------------|-------------------|
| **Squash merge** | Default for **feature PRs** from forks; one commit per PR | Linear, easy to revert one PR = one revert |
| **Merge commit** | You want to **preserve** every commit from a long-lived branch or **record** the merge node | Shows branch topology |
| **Rebase + fast-forward** | Maintainer **rebased** branch locally onto `main` and PR is **up to date** | Straight line, no merge commit |

### GitHub UI (typical)

- **Squash and merge**: Combines PR into **one** commit; edit the commit message to summarize.
- **Merge pull request**: Creates a **merge commit** `Merge pull request #N from ...`.
- **Rebase and merge**: Replays commits on top of `main` (requires **linear history** setting off or compatible branch protections).

### Command line equivalents (maintainer local)

Assume **`main`** is default branch and PR branch is **`feature/foo`**.

**Squash-like (single commit from PR branch):**

```bash
git fetch origin
git checkout main
git pull origin main
git merge --squash origin/feature/foo
# resolve conflicts if any
git commit -m "feat(ds_widgets): short summary (#123)"
git push origin main
```

**Merge commit:**

```bash
git checkout main
git pull origin main
git merge --no-ff origin/feature/foo -m "Merge branch 'feature/foo' (#123)"
git push origin main
```

**Rebase then fast-forward (contributor or maintainer):**

```bash
git checkout feature/foo
git fetch origin
git rebase origin/main
# fix conflicts, git rebase --continue
git checkout main
git pull origin main
git merge --ff-only feature/foo
git push origin main
```

**After any merge to `main`**, optional **tag** for downstream forks:

```bash
git tag -a boilerplate-2026.03.30 -m "Snapshot after auth + shell fixes"
git push origin boilerplate-2026.03.30
```

### Branch protection (recommended)

- Require **PR** + **CI green** before merge to `main`.
- Optional: **Require linear history** → favors **squash** or **rebase merge**, not merge commits.

---

## Relationship to forks

After you merge to **`main`**, teams with **`upstream`** remote run:

```bash
git fetch upstream
git merge upstream/main
```

They may use **path checkout** or **cherry-pick** for partial updates; see [upstream_git_workflow.md](upstream_git_workflow.md).
