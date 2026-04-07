# Repositories, packages, and ownership

This page is the **canonical map** of how the **boilerplate**, **platform**, and **auth** codebases relate, what each package does, and how teams **version**, **govern**, and **contribute**. For day-to-day host wiring (SSH, `pubspec.yaml`, bill of materials), see **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

---

## 1. Three Git repositories

| Repository | Remote (example) | Purpose |
|------------|------------------|---------|
| **Boilerplate** | `ecosystem_boilerplate` (your product or template fork) | **Host app** (`apps/emp_ai_boilerplate_app`), **mini-apps**, `miniapps_registry.yaml`, root **tooling** (`tool/`), **documentation** (`docs/`), and **Melos** scripts aimed at app developers. |
| **Platform** | [`ecosystem-platform`](https://github.com/maplepam/ecosystem-platform) | **Shared Dart packages**: foundation contracts, router/Dio config, Northstar design system, app shell / `MiniApp` contract. Built and analyzed as its own Melos workspace. |
| **Auth** | `emp-ai-flutter-auth` (e.g. Bitbucket) | **`emp_ai_auth`** package: OAuth/session flows, secure storage, auth UI. Depends on **platform** (`emp_ai_core`) and **legacy design system** (`emp_ai_ds`) via Git. |

**Consumers** (product teams) usually clone **only the boilerplate**; `flutter pub get` pulls **platform** and **auth** as **Git dependencies**. Pin versions using **[`docs/meta/platform_bom.yaml`](../meta/platform_bom.yaml)**.

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
| **`melos.yaml`** | Normally **`apps/**` only** — no vendored platform packages at the repo root. |
| **`packages/`** | Optional **product-only** packages; **do not** duplicate `emp_ai_*` platform sources here. **`packages/emp_ai_auth/`** is **gitignored** if you clone auth locally for debugging — the template resolves **`emp_ai_auth`** from Git. |

---

## 4. **Auth** package (`emp_ai_auth`)

- **Source of truth:** auth Git repository (branch e.g. `ecosystem_boilerplate`), not the boilerplate tree.
- **Dependencies:** `emp_ai_core` from **platform** (same **commit SHA** as the host’s other platform deps), `emp_ai_ds` from your **legacy design-system** repo (e.g. `ref: myemapta_main`).
- **Host usage:** `emp_ai_auth` is listed as a **second** Git dependency in `apps/.../pubspec.yaml` alongside platform packages. See **[emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)**.

---

## 5. Versioning and pins

| Artifact | Rule |
|----------|------|
| **Platform** | Host pins **one Git `ref` per clone** for **every** `path:` under `ecosystem-platform` (often a **full commit SHA**). Pub must see a **single** revision for in-repo **`path:`** links between packages (e.g. `emp_ai_ds_widgets` → `emp_ai_ds_northstar`). |
| **BOM** | **[`platform_bom.yaml`](../meta/platform_bom.yaml)** records `platform_git`, `auth_git`, and **legacy `emp_ai_ds`** coordinates. Update it whenever you bump pins. |
| **Auth** | Pin **branch or tag** on the auth remote; ensure its `emp_ai_core` ref stays **aligned** with the host’s platform SHA when you upgrade. After the auth branch moves, run **`flutter pub upgrade emp_ai_auth`** in the host app and commit **`pubspec.lock`** ([emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)). |
| **Semantic versions** | Each platform package has a **`version:`** in its `pubspec.yaml` for **changelog and API discipline**; consumers still resolve via **Git ref**, not necessarily pub.dev. |
| **Host lockfile** | Commit **`apps/emp_ai_boilerplate_app/pubspec.lock`** for reproducible CI and installs. |

**Release tagging (recommended):** tag **`ecosystem-platform`** (e.g. `platform-2026.04.1`) when you want products to move off a floating branch; point all platform `ref:` entries at the tag or SHA.

---

## 6. Governance and maintenance

| Topic | Boilerplate | Platform | Auth |
|--------|-------------|----------|------|
| **Default owners** | Product / vertical teams (host, mini-apps, customer-specific adapters). | Shared mobile or design-system chapter, or a **platform guild**. | Identity / security chapter or auth maintainers. |
| **CI** | Analyze + test **host**; run **`generate_miniapps`**; SSH to **GitHub + Bitbucket** if using private Git deps. | Analyze (and optional tests) for **all** `packages/*`. | Package tests + analyze in auth repo’s pipeline. |
| **Breaking changes** | Host and mini-apps adapt to new platform APIs; coordinate **bump PRs** with a single platform ref change. | Prefer **additive** API; document **breaks** in PRs and bump package **version** / changelog. | Coordinate with consumers for OAuth, storage, or router integration changes. |
| **Security** | Secrets only in **CI vault** / defines — see [ci_cd.md](../platform/ci_cd.md). | No product secrets in platform packages. | Tokens, client secrets, and WebView/OAuth settings are especially sensitive. |

---

## 7. Contributions

### Boilerplate (this repo)

- **Scope:** host behavior, mini-apps, docs, tooling that does not belong in platform.
- **Process:** [contributing.md](contributing.md), [upstream_git_workflow.md](upstream_git_workflow.md) for fork/upstream; run **`melos run analyze:all`** and **`test:boilerplate`** before PRs.
- **Do not** copy-edit large chunks of `emp_ai_*` here — change **ecosystem-platform** instead, then bump the **BOM** / `pubspec` **ref**.

### Platform (`ecosystem-platform`)

- **Scope:** shared packages only; keep **no product-specific** screens or customer URLs.
- **Process:** branch or PR workflow on the platform repo; tag when dropping a consumer-facing release; notify boilerplate maintainers to bump SHAs.
- **Compatibility:** run **`flutter analyze`** (and tests) across packages; avoid breaking **`MiniApp`**, router factories, or foundation contracts without a **migration note**.

### Auth (`emp-ai-flutter-auth`)

- **Scope:** authentication UX and session lifecycle; keep **dependency versions** aligned with platform (`go_router`, Riverpod majors).
- **Process:** merge to the branch products pin (e.g. `ecosystem_boilerplate`); keep **`emp_ai_core`** and **`emp_ai_ds`** as **Git** deps, not `path:`, so boilerplate clones need no extra folders.

---

## 8. Local development tips

- **Empty `packages/` here is normal.** Platform code is not vendored in the boilerplate repo.
- **Edit platform locally:** clone **ecosystem-platform**, then add **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml`** with **`path:`** overrides for **all five** `emp_ai_*` platform packages (avoids Pub mixing Git refs with local paths). See [dependencies.md — Local platform development](dependencies.md#local-platform-development) and **`pubspec_overrides.yaml.example`** in the app folder.
- **Optional auth clone:** override **`emp_ai_auth`** (and sometimes **`emp_ai_ds`**) the same way; do not commit overrides.

---

## 9. Documentation: boilerplate vs platform

| Audience | Where docs live | Examples |
|----------|-----------------|----------|
| **Product / host developers** — clone boilerplate only, pin Git deps, mini-apps, flavors, CI | **[ecosystem_boilerplate](https://github.com/maplepam/ecosystem_boilerplate)** `docs/` | [getting_started.md](../onboarding/getting_started.md), [faq.md](../onboarding/faq.md), [repositories_overview.md](repositories_overview.md) (this page), integrations |
| **Platform maintainers** — change `emp_ai_*` APIs, run analyze in this monorepo, cut tags | **[ecosystem-platform](https://github.com/maplepam/ecosystem-platform)** **[README](https://github.com/maplepam/ecosystem-platform/blob/main/README.md)** + **[CONTRIBUTING](https://github.com/maplepam/ecosystem-platform/blob/main/CONTRIBUTING.md)** (+ optional per-package `README`) | Clone → `melos bootstrap` → `analyze:all`; consumers pin **one** `ref` for all platform paths |

**Principle:** avoid maintaining **two** full copies of the same platform guide. The **boilerplate** explains *how consumers depend on* platform (BOM, SHA pins, `pubspec_overrides`, SSH). The **platform** repo explains *how to work inside* platform (Melos layout, contributing, breaking-change policy). Link across repos (e.g. boilerplate → platform README; platform README → boilerplate onboarding).

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
| `pubspec` / SSH / BOM | [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md) |
| **Platform** repo (clone, Melos, analyze, PR rules) | [ecosystem-platform README](https://github.com/maplepam/ecosystem-platform/blob/main/README.md), [CONTRIBUTING](https://github.com/maplepam/ecosystem-platform/blob/main/CONTRIBUTING.md) |

Back to [engineering README](README.md) or [documentation index](../README.md).
