# Repositories, packages, and ownership

This page is the **canonical map** of how the **boilerplate**, **platform**, and **auth** codebases relate, what each package does, and how teams **version**, **govern**, and **contribute**. For day-to-day host wiring (submodules, SSH, `pubspec.yaml`), see **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

---

## 1. Three Git repositories

| Repository | Remote (example) | Purpose |
|------------|------------------|---------|
| **Boilerplate** | `ecosystem_boilerplate` (your product or template fork) | **Host app** (`apps/emp_ai_boilerplate_app`), **mini-apps**, `miniapps_registry.yaml`, root **tooling** (`tool/`), **documentation** (`docs/`), and **Melos** scripts aimed at app developers. |
| **Platform** | [`ecosystem-platform`](https://github.com/maplepam/ecosystem-platform) | **Shared Dart packages**: foundation contracts, router/Dio config, Northstar design system, app shell / `MiniApp` contract. Built and analyzed as its own Melos workspace. |
| **Auth** | `emp-ai-flutter-auth` (e.g. Bitbucket) | **`emp_ai_auth`** package: OAuth/session flows, secure storage, auth UI. Depends on **platform** (`emp_ai_core`) and **legacy design system** (`emp_ai_ds`) via Git. |

**Consumers** (product teams) usually clone **only the boilerplate** with **submodules** (**`git clone --recurse-submodules`** or **`git submodule update --init --recursive`**). The host app uses **`path:`** into **`packages/ecosystem-platform`**, **`packages/emp_ai_auth`**, and **`packages/emp_ai_ds`**. Pin commits using **git submodule gitlinks** (see **`git submodule status`**).

---

## 2. Packages on **ecosystem-platform**

All live under `packages/` in the platform repo. Together they are **UI-agnostic or host-agnostic** building blocks; they do not contain product-specific mini-apps.

| Package | Responsibility |
|---------|------------------|
| **`emp_ai_foundation`** | **Contracts only**: `AppResult`, feature-flag reader, auth snapshot reader, analytics/crash/notification **ports**, platform helpers. No Flutter UI, no Dio. |
| **`emp_ai_core`** | **Router assembly** (`CoreGoRouterFactory`, host modes), **RBAC** types and redirects, **Dio** / network stack configuration hooks, **flavor** parsing. |
| **`emp_ai_ds_northstar`** | **Northstar tokens** (color, typography, spacing), `ThemeData` builders, DTCG JSON assets, branding hooks. |
| **`emp_ai_ds_widgets`** | **Reusable Northstar UI** (shell pieces, layouts, tables, catalog widgets, etc.) on top of `emp_ai_ds_northstar`. |
| **`emp_ai_app_shell`** | **`MiniApp` contract**, route merging, super-app shell / hub scaffolding, feature-flag filtering for registered mini-apps. |

**Platform repo layout (typical):** root `melos.yaml` with `packages/**`, `pubspec.yaml` for Melos tooling, optional `analysis_options.yaml`. **Library packages do not commit `pubspec.lock`** — resolution happens in the **host** (or app) that depends on them.

---

## 3. What lives in **ecosystem_boilerplate**

| Area | Contents |
|------|-----------|
| **`apps/emp_ai_boilerplate_app/`** | Sample **host**: Riverpod, `go_router`, flavor catalog, shell, platform adapters, **mini-apps** under `lib/src/miniapps/`, tests. |
| **`tool/`** | Codegen and scaffolding (`generate_miniapps`, `create_miniapp`, etc.). |
| **`docs/`** | Onboarding, integrations, engineering, design docs for **host and mini-app** developers. |
| **`melos.yaml`** | Normally **`apps/**` only** — Melos does not bootstrap nested **`packages/ecosystem-platform`** packages from the boilerplate root. |
| **`packages/`** | **Submodules:** **`ecosystem-platform`**, **`emp_ai_auth`**, **`emp_ai_ds`**. Optional **extra** product-only packages may live alongside them; **do not** duplicate `emp_ai_*` platform sources as loose copies. |

---

## 4. **Auth** package (`emp_ai_auth`)

- **Source of truth:** auth Git repository (branch e.g. `ecosystem_boilerplate`), not the boilerplate tree.
- **Dependencies:** `emp_ai_core` from **platform** (same **commit SHA** as the host’s other platform deps), `emp_ai_ds` from your **legacy design-system** repo (e.g. `ref: myemapta_main`).
- **Host usage:** `emp_ai_auth` is a **submodule** at **`packages/emp_ai_auth`**, consumed via **`path:`** from the host app (with **`dependency_overrides`** for **`emp_ai_core`** / **`emp_ai_ds`** until auth’s `pubspec` uses paths). See **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

---

## 5. Versioning and pins

| Artifact | Rule |
|----------|------|
| **Platform** | **`packages/ecosystem-platform`** submodule is **one** checkout — every `emp_ai_*` package under it shares that commit. Pub still needs that single tree for in-repo **`path:`** links (e.g. `emp_ai_ds_widgets` → `emp_ai_ds_northstar`). |
| **Submodule pins** | **`.gitmodules`** (URLs) + **gitlinks** on the parent branch (commits). Update with **`git fetch` / `git checkout`** inside each **`packages/…`** submodule, then **`git add`** from the boilerplate root. |
| **Auth** | **`packages/emp_ai_auth`** submodule commit; keep auth’s **`emp_ai_core`** Git **`ref`** aligned with the platform SHA when auth still uses Git deps, or switch auth to path deps. See [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md). |
| **Semantic versions** | Each platform package has a **`version:`** in its `pubspec.yaml` for **changelog and API discipline**; the boilerplate pins **commits** via submodules, not pub.dev. |
| **Host lockfile** | Commit **`apps/emp_ai_boilerplate_app/pubspec.lock`** for reproducible CI and installs. |

**Release tagging (recommended):** tag **`ecosystem-platform`** (e.g. `platform-2026.04.1`) when you want products to move off a floating branch; **`git checkout <tag-or-sha>`** in **`packages/ecosystem-platform`**, **`git add packages/ecosystem-platform`**, commit.

---

## 6. Governance and maintenance

| Topic | Boilerplate | Platform | Auth |
|--------|-------------|----------|------|
| **Default owners** | Product / vertical teams (host, mini-apps, customer-specific adapters). | Shared mobile or design-system chapter, or a **platform guild**. | Identity / security chapter or auth maintainers. |
| **CI** | Analyze + test **host**; run **`generate_miniapps`**; checkout **submodules**; SSH to **GitHub + Bitbucket** for submodule URLs. | Analyze (and optional tests) for **all** `packages/*`. | Optional: auth repo CI if you maintain one. |
| **Breaking changes** | Host and mini-apps adapt to new platform APIs; coordinate **bump PRs** with a single platform submodule pointer change. | Prefer **additive** API; document **breaks** in PRs and bump package **version** / changelog. | Coordinate with consumers for OAuth, storage, or router integration changes. |
| **Security** | Secrets only in **CI vault** / defines — see [ci_cd.md](../platform/ci_cd.md). | No product secrets in platform packages. | Tokens, client secrets, and WebView/OAuth settings are especially sensitive. |

---

## 7. Contributions

### Boilerplate (this repo)

- **Scope:** host behavior, mini-apps, docs, tooling that does not belong in platform.
- **Process:** [contributing.md](contributing.md), [upstream_git_workflow.md](upstream_git_workflow.md) for fork/upstream; run **`melos run analyze:all`** and **`test:boilerplate`** before PRs.
- **Do not** copy-edit large chunks of `emp_ai_*` here — change **ecosystem-platform** instead, then bump the **`packages/ecosystem-platform`** submodule commit on this repo.

### Platform (`ecosystem-platform`)

- **Scope:** shared packages only; keep **no product-specific** screens or customer URLs.
- **Process:** branch or PR workflow on the platform repo; tag when dropping a consumer-facing release; notify boilerplate maintainers to bump SHAs.
- **Compatibility:** run **`flutter analyze`** (and tests) across packages; avoid breaking **`MiniApp`**, router factories, or foundation contracts without a **migration note**.

### Auth (`emp-ai-flutter-auth`)

- **Scope:** authentication UX and session lifecycle; keep **dependency versions** aligned with platform (`go_router`, Riverpod majors).
- **Process:** merge to the branch products track; the boilerplate vendors auth as a **submodule** and may use **`dependency_overrides`** until auth’s `pubspec` switches to **`path:`** siblings for **`emp_ai_core`** / **`emp_ai_ds`**.

---

## 8. Local development tips

- **`packages/`** holds **submodules** — after clone, **`git submodule update --init --recursive`**.
- **Edit platform locally:** use the **`packages/ecosystem-platform`** submodule (**`cd` there, `dart run melos bootstrap`**) or a **separate** clone + **`pubspec_overrides.yaml`** for **all five** `emp_ai_*` platform packages. See [dependencies.md — Local platform development](dependencies.md#local-platform-development) and **`pubspec_overrides.yaml.example`** in the app folder.
- **Optional auth alternate path:** override **`emp_ai_auth`** (and sometimes **`emp_ai_ds`**) the same way; do not commit overrides.

---

## 9. Documentation: boilerplate vs platform

| Audience | Where docs live | Examples |
|----------|-----------------|----------|
| **Product / host developers** — clone boilerplate + submodules, mini-apps, flavors, CI | **[ecosystem_boilerplate](https://github.com/maplepam/ecosystem_boilerplate)** `docs/` | [getting_started.md](../onboarding/getting_started.md), [faq.md](../onboarding/faq.md), [repositories_overview.md](repositories_overview.md) (this page), integrations |
| **Platform maintainers** — change `emp_ai_*` APIs, run analyze in this monorepo, cut tags | **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)** **[README](https://github.com/maplepam/ecosystem-platform/blob/main/README.md)** + **[CONTRIBUTING](https://github.com/maplepam/ecosystem-platform/blob/main/CONTRIBUTING.md)** (+ optional per-package `README`) | Clone → `melos bootstrap` → `analyze:all`; consumers pin **one** submodule commit for the whole platform tree |

**Principle:** avoid maintaining **two** full copies of the same platform guide. The **boilerplate** explains *how consumers depend on* platform (submodules, `pubspec_overrides`, SSH). The **platform** repo explains *how to work inside* platform (Melos layout, contributing, breaking-change policy). Link across repos (e.g. boilerplate → platform README; platform README → boilerplate onboarding).

**Per-package `README.md`** under `packages/<name>/` in **ecosystem-platform** are optional but useful for one-screen “what this package exports” and migration notes — keep them short; full host integration stays in **boilerplate** `docs/`.

---

## 10. Related docs

| Need | Doc |
|------|-----|
| Host folder map | [host_structure.md](host_structure.md) |
| Mini-apps, registry | [miniapps.md](miniapps.md) |
| Adding a **product** package in boilerplate | [packages.md](packages.md) |
| External mini-app packages | [miniapp_packages_and_extract.md](miniapp_packages_and_extract.md) |
| Maintainer merge policy | [maintainer_policy.md](maintainer_policy.md) |
| Submodules / SSH | [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md) |
| **Platform** repo (clone, Melos, analyze, PR rules) | [ecosystem-platform README](https://github.com/maplepam/ecosystem-platform/blob/main/README.md), [CONTRIBUTING](https://github.com/maplepam/ecosystem-platform/blob/main/CONTRIBUTING.md) |

Back to [engineering README](README.md) or [documentation index](../README.md).
