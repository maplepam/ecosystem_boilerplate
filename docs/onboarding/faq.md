# FAQ for new teams

Short answers first; follow the links for full detail. **Errors and tooling quirks** also live in [troubleshooting.md](../platform/troubleshooting.md).

---

## Repositories and ownership

**What is the difference between the boilerplate repo and ecosystem-platform?**  
The **boilerplate** holds the **host app**, **mini-apps**, **docs**, and **tooling**. **ecosystem-platform** holds shared **`emp_ai_*`** Dart packages (foundation, core, Northstar DS, app shell). The host pulls them as **Git dependencies**. → [repositories_overview.md](../engineering/repositories_overview.md)

**Where does `emp_ai_auth` live?**  
In a **separate Git remote** (e.g. Bitbucket), not under `packages/` in the boilerplate. The host lists it as a second **`git:`** dependency. → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)

**We only work on product features — what should we clone?**  
Usually **only the boilerplate** (your fork). Run **`melos bootstrap`**; `pub get` fetches platform + auth. → [getting_started.md](getting_started.md), [first_day.md](first_day.md)

**We need to change router / `MiniApp` / design-system widgets — where do we PR?**  
Against **ecosystem-platform**, then bump the **platform `ref`** (same SHA for every package path) in the host **`pubspec.yaml`** and **[platform_bom.yaml](../meta/platform_bom.yaml)**. → [repositories_overview.md §7](../engineering/repositories_overview.md#7-contributions)

**`packages/` is empty — how do I edit platform code locally?**  
Clone **ecosystem-platform** somewhere on disk (e.g. next to this repo). Copy **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml.example`** → **`pubspec_overrides.yaml`** and add **`dependency_overrides`** with **`path:`** to **`../ecosystem-platform/packages/<name>`** for each **`emp_ai_*`** you need (overriding **all five** platform packages avoids Pub mixing Git + path). Run **`flutter pub get`** in the app. **Do not commit** overrides. When done, delete overrides and bump the Git **`ref`** / BOM after your platform PR merges. → [dependencies.md § Local platform development](../engineering/dependencies.md#local-platform-development), **`pubspec_overrides.yaml.example`**

---

## Setup and daily commands

**What do I run after a fresh clone?**  
`dart pub get` → `dart run melos bootstrap` → `dart run melos run generate:miniapps` → `cd apps/emp_ai_boilerplate_app && flutter run`. → [first_day.md](first_day.md), [getting_started.md §2](getting_started.md#gs-2)

**`melos bootstrap` / `flutter pub get` fails on Git dependencies.**  
You need **SSH** (or HTTPS + credentials) for **GitHub** (platform) and **Bitbucket** (auth + legacy DS). → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md), [troubleshooting.md](../platform/troubleshooting.md)

**Why do we pin a commit SHA for every `ecosystem-platform` package?**  
Pub must see **one** revision for **in-repo `path:`** links between packages (e.g. widgets → northstar). Using only `ref: main` without a unified resolution can break the solver. → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md), [platform_bom.yaml](../meta/platform_bom.yaml)

**The auth branch moved; `pub get` still resolves an old commit.**  
Run **`flutter pub upgrade emp_ai_auth`** in the host app and commit **`pubspec.lock`**. → [emp_ai_auth_dependency.md § When the auth branch moves forward](../integrations/emp_ai_auth_dependency.md)

---

## Configuration

**Where do API URLs and OAuth client ids go?**  
Default: **`BoilerplateEnvironmentCatalog`** per flavor. Optional overrides: **`API_BASE_URL`**, **`AUTH_*`** defines or **`build_defines.json`**. → [environment.md](../integrations/environment.md), [dart_defines.md](../platform/dart_defines.md)

**How do we wire CI secrets / flavors?**  
Generate **`build_defines.json`** (or equivalent) in the pipeline from the vault; pass **`--dart-define-from-file`**. → [ci_cd.md](../platform/ci_cd.md)

---

## App structure and features

**Where does host code live (`shell` vs `platform` vs mini-apps)?**  
→ [host_structure.md](../engineering/host_structure.md)

**New screen: new mini-app or feature inside an existing mini-app?**  
→ [mini_app_vs_feature.md](../engineering/mini_app_vs_feature.md)

**Add a mini-app; registry and codegen**  
→ [miniapps.md](../engineering/miniapps.md)

**Mini-app shipped from another team’s repo**  
→ [miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md)

**Routes, redirects, main-shell menu**  
→ [navigation.md](../integrations/navigation.md)

**Auth, token refresh, permissions in UI**  
→ [auth.md](../integrations/auth.md)

---

## Governance and docs map

**Bill of materials — what file is canonical?**  
**[`docs/meta/platform_bom.yaml`](../meta/platform_bom.yaml)** lists the **`url` + `ref`** you should keep in sync with **`apps/emp_ai_boilerplate_app/pubspec.yaml`**. Forks edit the same file for **their** remotes.

**PR rules and layer boundaries**  
→ [contributing.md](../engineering/contributing.md)

**Maintainer merge / tags / versioning (boilerplate)**  
→ [maintainer_policy.md](../engineering/maintainer_policy.md)

**Fork upstream and pull selective paths**  
→ [upstream_git_workflow.md](../engineering/upstream_git_workflow.md)

**Full documentation index**  
→ [docs README](../README.md)

---

## Related (not quite FAQ)

| Page | Role |
|------|------|
| [troubleshooting.md](../platform/troubleshooting.md) | Concrete failures: bootstrap, codegen, Firebase, web CORS, deep links |
| [adopting_the_boilerplate.md](adopting_the_boilerplate.md) | Productize fork: auth catalog, hide samples, RBAC, real HTTP |
| [design_system.md](../design/design_system.md) | Tokens, theme, Figma workflow |

Back to [getting_started.md](getting_started.md) or [documentation index](../README.md).
