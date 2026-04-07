# FAQ for new teams

Short answers first; follow the links for full detail. **Errors and tooling quirks** also live in [troubleshooting.md](../platform/troubleshooting.md).

---

## Repositories and ownership

**Boilerplate vs ecosystem-platform**  
The **boilerplate** holds the **host app**, **mini-apps**, **docs**, and **tooling**. **ecosystem-platform** holds shared **`emp_ai_*`** Dart packages (foundation, core, Northstar DS, app shell). The boilerplate tracks them as a **submodule** under **`packages/ecosystem-platform`**. → [repositories_overview.md](../engineering/repositories_overview.md)

**Where `emp_ai_auth` lives**  
In a **separate Git remote** (e.g. Bitbucket), vendored here as **`packages/emp_ai_auth`** (submodule). The host uses **`path:`** into that folder. → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)

**Cloning for product features only**  
Clone the boilerplate, then **`git submodule update --init --recursive`** (or **`git clone --recurse-submodules`**). Then **`dart pub get`** and **`melos bootstrap`**. → [getting_started.md §2](getting_started.md#gs-2)

**Contributing router / `MiniApp` / design-system changes**  
Open PRs against **ecosystem-platform**, then **`git checkout`** the desired commit in **`packages/ecosystem-platform`**, **`git add packages/ecosystem-platform`**, and commit on the boilerplate branch. → [repositories_overview §7](../engineering/repositories_overview.md#7-contributions), [emp_ai_auth_dependency — bumping pins](../integrations/emp_ai_auth_dependency.md#bumping-submodule-pins)

**IDE shows thousands of errors under `packages/ecosystem-platform`**  
That tree is excluded in the boilerplate root **`analysis_options.yaml`** because nested packages are not bootstrapped from here. Analyze **`apps/emp_ai_boilerplate_app`**, or open **`packages/ecosystem-platform`** and run **`dart run melos bootstrap`** there. → [troubleshooting.md](../platform/troubleshooting.md)

**Local platform edits (alternate clone)**  
Clone **ecosystem-platform** somewhere on disk (e.g. next to this repo). Copy **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml.example`** → **`pubspec_overrides.yaml`** and add **`dependency_overrides`** with **`path:`** for each **`emp_ai_*`** you need (overriding **all five** platform packages keeps resolution consistent). Run **`flutter pub get`** in the app. **Do not commit** overrides. When done, delete overrides and move the **`packages/ecosystem-platform`** submodule to the merged commit, then **`git add`** and commit. → [dependencies.md § Local platform development](../engineering/dependencies.md#local-platform-development), **`pubspec_overrides.yaml.example`**

---

## Setup and daily commands

**After a fresh clone**  
`dart pub get` → `dart run melos bootstrap` → `dart run melos run generate:miniapps` → `cd apps/emp_ai_boilerplate_app && flutter run`. → [getting_started.md §2](getting_started.md#gs-2)

**`melos bootstrap` / `flutter pub get` fails (missing packages / path deps)**  
Run **`git submodule update --init --recursive`** first. **SSH** (or HTTPS + credentials) is required to **fetch** submodules from **GitHub** and **Bitbucket**. → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md), [troubleshooting.md](../platform/troubleshooting.md)

**Why every `ecosystem-platform` package uses the same commit SHA**  
Pub must see **one** revision for **in-repo `path:`** links between packages (e.g. widgets → northstar). Using only `ref: main` without a unified resolution can break the solver. → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)

**Auth moved on Bitbucket; host still on an old auth tree**  
**`git fetch`** in **`packages/emp_ai_auth`**, **`git checkout <sha>`**, **`git add packages/emp_ai_auth`**. Then **`flutter pub get`** in the app and commit **`pubspec.lock`** if it changes. → [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md#bumping-submodule-pins)

---

## Configuration

**API URLs and OAuth client ids**  
Default: **`BoilerplateEnvironmentCatalog`** per flavor. Optional overrides: **`API_BASE_URL`**, **`AUTH_*`** defines or **`build_defines.json`**. → [environment.md](../integrations/environment.md), [dart_defines.md](../platform/dart_defines.md)

**CI secrets and flavors**  
Generate **`build_defines.json`** (or equivalent) in the pipeline from the vault; pass **`--dart-define-from-file`**. → [ci_cd.md](../platform/ci_cd.md)

---

## App structure and features

**Host layout (`shell` vs `platform` vs mini-apps)**  
→ [host_structure.md](../engineering/host_structure.md)

**New screen: mini-app vs feature inside an existing mini-app**  
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

**Where pins live**  
Submodule **URLs** are in **`.gitmodules`**. **Commits** are whatever Git records when you **`git add packages/…`** on the parent branch — check with **`git submodule status`**. The host **`pubspec.yaml`** uses **`path:`** only.

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
