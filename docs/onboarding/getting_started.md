# Getting started

**Use this page as the main onboarding “map”** for anyone who has never touched this monorepo: it tells you what to run, **where** code lives, and what you are allowed to change. Deep dives stay in linked docs so this file stays scannable.

_For first-time users: you do **not** need prior experience with Melos or this repo. Follow the sections in order._

**What this doc gives you**

- How to get the code (**clone** vs **fork**) and connect **your** Git remote.
- **Prerequisites** (Flutter, Melos, `emp_ai_auth` bootstrap), **demo shell routes** after first run, and optional **Figma** `.fig` metadata (**§2** and **§8**).
- Commands you **must** run once.
- **Where code lives** in the host app in plain language — **shell**, **platform**, **mini-apps**, and the **one file** that merges all mini-apps (**§2b**).
- How to change the **product name** users see (home screen, task switcher, browser tab).
- **Copy-paste examples** for common host settings (auth, API URL, routing, RBAC, external mini-apps, WebView).
- **Template environment catalog** — what to replace after clone/fork (`boilerplate_environment_catalog.dart`).
- **Web, Android, and iOS** — how to run and build with `FLAVOR` and platform notes.
- **Local + CI compile-time config** — optional **`config/build_defines.json`** (copy from the example) and **`--dart-define-from-file`**; CI generates the same JSON from secrets ([ci_cd.md](../platform/ci_cd.md)).
- What is **required** vs **optional** before you ship.

**If you know nothing about this repo yet:** read **§2b** (map), then **[engineering/README.md](../engineering/README.md)** (four short links), then come back here for run/build steps.

Deeper topics: [README.md — integrations hub](../README.md#integrations-hub) — [navigation](../integrations/navigation.md) (routes, redirects, `go` / `push`), [environment](../integrations/environment.md), [auth](../integrations/auth.md), [dart_defines.md](../platform/dart_defines.md) (`FLAVOR` + toggles), [ci_cd.md](../platform/ci_cd.md) (Bitbucket / Bitrise / emapta-style), [adopting_the_boilerplate.md](adopting_the_boilerplate.md) (remove demo / productize), [architecture.md](../engineering/architecture.md), [miniapps.md](../engineering/miniapps.md), **[host_structure.md](../engineering/host_structure.md)** (full folder map), **[miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md)** (external package / submodule / WebView onboarding).

**Faster path:** [first_day.md](first_day.md) (commands only). **Stuck?** [troubleshooting.md](../platform/troubleshooting.md).

### On this page

| §             | Topic                                                                                      |
| ------------- | ------------------------------------------------------------------------------------------ |
| [§1](#gs-1)   | Get the code: clone, fork, or copy                                                         |
| [§2](#gs-2)   | Must run these commands (prerequisites)                                                    |
| [§2b](#gs-2b) | **Where things live** in the host app (shell / platform / mini-apps) — read before editing |
| [§3](#gs-3)   | Replace template environment values                                                        |
| [§4](#gs-4)   | Run and build: Web, Android, and iOS                                                       |
| [§5](#gs-5)   | Change the product name                                                                    |
| [§6](#gs-6)   | Example snippets: host behavior                                                            |
| [§7](#gs-7)   | What to change before shipping                                                             |
| [§8](#gs-8)   | Optional later                                                                             |
| [§9](#gs-9)   | Where to look next                                                                         |

<a id="gs-1"></a>

## 1. Get the code: clone, fork, or copy

### Recommended: Git with this **monorepo** (read this first)

This workspace is **one Git repository** with **one `.git` folder at the root**. Everything under `apps/` and `packages/` is meant to move together: same branch, same `origin`, same CI run. **Melos** only wires local `path:` dependencies; it does **not** mean each package should live in a separate Git repo.

**Preferred setup for most teams**

1. **One remote = your product** — Push the **entire** tree (root `melos.yaml`, all `packages/*`, `apps/*`) to **your** GitHub/GitLab/Azure DevOps repo. That is your source of truth.
2. **How you create that repo** (pick one; both are valid):
   - **Fork** the boilerplate on GitHub/GitLab, then clone **your fork** (**Option B** below). Use this if you might open pull requests **back** to the upstream boilerplate or you like the “Fork” button workflow.
   - **Clone** the boilerplate once, then `git remote set-url origin` (or remove/add `origin`) to **your** empty repo and push (**Option A**). Use this for an internal template or when you do not need a hosting-site fork.
3. **Do not split packages into separate Git repos** unless your organization already versions shared libraries that way (separate releases, separate permissions). The boilerplate assumes **mono-repo**: shared refactors, one `melos bootstrap`, one lockfile story per app.
4. **`packages/emp_ai_auth`** is special: it is often **filled by a clone during `melos bootstrap`** and may be **gitignored**. Your team either commits that folder (vendored) or regenerates it on each machine; see [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md). Either way, it still lives **inside** the monorepo directory — not a second Git repo you `git submodule` unless you choose that explicitly.

**Summary:** Prefer **one clone, one `origin`, whole monorepo**. Fork vs “clone + repoint origin” is mostly about **whether you contribute upstream**; it does not change the rule that **apps + packages ship from the same repo**.

### Words you need

| Term         | Meaning                                                                                                       |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| **Upstream** | The original boilerplate repo (the one you copied from).                                                      |
| **Origin**   | _Your_ default remote (usually _your_ GitHub/GitLab repo).                                                    |
| **Fork**     | A copy of a repo _on the hosting site_ (GitHub “Fork” button). It keeps a link to upstream for pull requests. |
| **Clone**    | Download a repo to your laptop (`git clone`).                                                                 |

### Option A — You only want a one-off copy (no GitHub fork)

1. Clone the boilerplate (URL is whatever your team uses):

```bash
 git clone <BOILERPLATE_REPO_URL> my_product_app
 cd my_product_app
```

2. **Disconnect** from the boilerplate remote and point **origin** at **your** empty repo:

```bash
 git remote remove origin
 git remote add origin <YOUR_EMPTY_REPO_URL>
 git push -u origin main
```

If your default branch is `master`, use that instead of `main`. 3. From now on you work as a **normal** project: commit and push to `origin`. You are **not** obliged to pull updates from the boilerplate unless you add it back as a remote (see below).

### Option B — You use GitHub (or GitLab) “Fork”

1. Click **Fork** on the boilerplate project in the browser. That creates **your** repo under your account/org.
2. Clone **your** fork (not the original):

```bash
 git clone <YOUR_FORK_URL> my_product_app
 cd my_product_app
```

3. Optional: add the original repo as **upstream** so you can pull template updates later:

```bash
 git remote add upstream <BOILERPLATE_REPO_URL>
 git fetch upstream
```

Merging `upstream` into your work is a **manual** decision (can cause conflicts). Many teams fork once and rarely sync.

### Option C — You want to **pull boilerplate updates** into an existing product repo

Keep **two** remotes:

```bash
git remote add boilerplate <BOILERPLATE_REPO_URL>
git fetch boilerplate
# Later, merge or cherry-pick specific commits from boilerplate/main
```

There is no magic: merging a moving boilerplate into a customized app often needs conflict resolution. Prefer **cherry-picks** or copy patterns from docs rather than blind merges.

<a id="gs-2"></a>

---

## 2. Must run these commands (prerequisites)

### Prerequisites (before you run the table below)

- Flutter SDK (match the version your org pins; run `flutter doctor`).
- Dart SDK (bundled with Flutter).
- [Melos](https://melos.invertase.dev/) is invoked via `dart run melos` from this workspace (no global install required if you use `dart pub get` at the ecosystem root first).
- **`emp_ai_auth`:** **`dart run melos bootstrap`** runs a pre-hook that may clone into `packages/emp_ai_auth` and patch **`emp_ai_ds`** to Git ([emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)).

Do this from the folder that contains `melos.yaml` (repository root).

| Step | Command                                         | Why                                                                                                                                            |
| ---- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | `dart pub get`                                  | Tooling scripts at the repo root need packages.                                                                                                |
| 2    | `dart run melos bootstrap`                      | Links all `packages/*` and `apps/*`; may **clone** `emp_ai_auth` (see [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)). |
| 3    | `dart run melos run generate:miniapps`          | Builds the mini-app route catalog from `miniapps_registry.yaml`. **Required** after every fresh clone.                                         |
| 4    | `cd apps/emp_ai_boilerplate_app && flutter run` | Runs the host app.                                                                                                                             |

### Optional (recommended): one file for many `--dart-define` values (local)

When you need **`FLAVOR`** plus toggles (**`VERBOSE_LOGS`**, **`MIXPANEL_TOKEN`**, Samples flags, …) together, use a **JSON file** instead of a long `flutter run` line. **API / IdP URLs** normally live in the **[flavor catalog](../integrations/environment.md#flavor-catalog-emapta-style)**; add **`API_BASE_URL`** / **`AUTH_*`** to JSON only for [advanced overrides](../integrations/environment.md#host-profile-overrides-api-url-verbose-logs) (see [docs README — integrations hub](../README.md#integrations-hub)).

1. From the repo root, go to the host app:
   ```bash
   cd apps/emp_ai_boilerplate_app
   ```
2. Copy the committed template (safe defaults; **no secrets** in git):
   ```bash
   cp config/build_defines.example.json config/build_defines.json
   ```
3. Edit **`config/build_defines.json`** with your local values. That path is **gitignored** so tokens are not committed.
4. Run or build with:
   ```bash
   flutter run --dart-define-from-file=config/build_defines.json
   ```
   Use the same flag on **`flutter build`** (web, APK, IPA, etc.). Boolean keys must be the strings **`"true"`** or **`"false"`** (see [dart_defines.md](../platform/dart_defines.md)).

**Toggles / `FLAVOR`:** [dart_defines.md](../platform/dart_defines.md). **Catalog & optional auth/API defines:** [integrations/environment.md](../integrations/environment.md). **CI** generates JSON from the vault (never commit secrets): [ci_cd.md](../platform/ci_cd.md).

**Sanity check (same as CI):**

```bash
cd /path/to/ecosystem_boilerplate
dart run melos run analyze:all
dart run melos run test:boilerplate
```

<a id="gs-2b"></a>

### 2b. Where things live (host app — read this before you change code)

All paths are under **`apps/emp_ai_boilerplate_app/lib/src/`**. Think of three buckets plus a few helpers:

| If you are touching…                                                        | Folder          | In one sentence                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Router, hub, drawer, login wiring, deep links**                           | **`shell/`**    | The frame every screen sits inside. **Main-shell menu items** (Overview, Hub children, …) are **data-driven**: [`boilerplate_shell_nav_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_nav_config.dart) + **`boilerplateShellNavConfigProvider`** — see [navigation.md](../integrations/navigation.md#main-shell-side-navigation-configurable). |
| **Feature flags, analytics, push ports, which mini-apps the server allows** | **`platform/`** | How the **host** behaves for all products.                                                                                                                                                                                                                                                                                                                                                 |
| **A product area (announcements, samples, your new feature)**               | **`miniapps/`** | Real **screens + business logic** (`data` / `domain` / `presentation`).                                                                                                                                                                                                                                                                                                                    |
| **Flavors, RBAC tables, host mode**                                         | **`config/`**   | Settings and policy **data**, not UI.                                                                                                                                                                                                                                                                                                                                                      |
| **`runApp`, startup (Firebase, auth bootstrap)**                            | **`app/`**      | App entry wiring.                                                                                                                                                                                                                                                                                                                                                                          |

**The list the hub actually uses** is not only codegen. After `generate:miniapps`, the file **`miniapp_catalog.g.dart`** defines **`kAllMiniApps`** for in-repo modules. The host **merges** that with anything else (another team’s package, a WebView-only partner) in **one place**:

- **`miniapps/miniapp_host_catalog.dart`** → **`kHostMiniAppsCatalog`**
- **[`MiniAppGate`](../../apps/emp_ai_boilerplate_app/lib/src/platform/miniapps_registry/mini_app_gate.dart)** reads **`kHostMiniAppsCatalog`**, then optional **remote allow-list** (HTTP) + **feature flags**.

**You do not edit `miniapp_catalog.g.dart` by hand.** You edit **`miniapps_registry.yaml`** and re-run **`melos run generate:miniapps`**, **and/or** you append external entries in **`miniapp_host_catalog.dart`** (see **§6g**).

**Canonical diagrams and “where does X go?”** — [host_structure.md](../engineering/host_structure.md). **Guided reading order (four pages)** — [engineering/README.md](../engineering/README.md).

### Demo shell routes (after the app starts)

Paths depend on `AppHostMode` in `apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart`: super-app uses `/main/home`, `/main/widgets`, `/main/theme`; standalone uses `/home`, `/widgets`, `/theme`; embedded uses `/<prefix>/home`, etc. On viewports **≥ 1100px** wide, the widget catalog uses a **list + preview** split. Named routes for `goNamed`: `demo_home`, `demo_theme`, `demo_widgets`, `demo_widget_detail` (path parameter `catalogId`).

<a id="gs-3"></a>

---

## 3. Replace template environment values (after clone or fork)

The file **`apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart`** contains **sample defaults** only (example API hosts, identity/Keycloak base URLs, OAuth client ids, mobile vs web redirect URIs, and window titles). They exist so the boilerplate **builds and runs** without your own config.

When you adopt the repo for **your** application:

1. Open **`boilerplate_environment_catalog.dart`**.
2. Replace **each** `BoilerplateFlavorEndpoints` constant (`_development`, `_qa`, `_staging`, `_production`) with values that match **your** dev / QA / staging / production backends and IdP.
3. Keep **secrets** (e.g. OAuth `clientSecret`) out of this file — use **`--dart-define`**, CI secrets, or [advanced `AUTH_*` defines](../integrations/environment.md#auth-dart-defines-advanced).

At runtime, **`--dart-define=FLAVOR`** selects which row is used (`development`, `qa`, `staging`, `production` — see `AppBuildFlavorParser` in `emp_ai_core`). A non-empty **`API_BASE_URL`** define overrides **only** the REST API base from the catalog.

**Window title:** `MaterialApp.title` comes from **`boilerplateDisplayTitleProvider`**, which reads **`appTitle`** from the catalog — so updating **`appTitle`** in the catalog is the normal way to set the title per environment (unless you override the provider in tests or white-label builds).

More detail: [integrations/environment.md](../integrations/environment.md#flavor-catalog-emapta-style).

<a id="gs-4"></a>

---

## 4. Run and build: Web, Android, and iOS

Work from **`apps/emp_ai_boilerplate_app`** for all **`flutter`** commands below (after `melos bootstrap` from the repo root).

### 4.1 Common: flavor and defines

- **`FLAVOR`** picks a row in **`BoilerplateEnvironmentCatalog`** (default in code is `development` if you omit it).
- Optional: **`VERBOSE_LOGS`** — see [dart_defines.md](../platform/dart_defines.md). **API override / auth:** [flavor catalog](../integrations/environment.md#flavor-catalog-emapta-style) + optional **`API_BASE_URL`** or **`AUTH_*`** — [integrations/environment.md](../integrations/environment.md). Omit **`AUTH_*`** to use the catalog; use **`--dart-define-from-file`** when you need many keys locally or in CI.
- **Many keys at once:** use **`--dart-define-from-file=config/build_defines.json`** (create the file from [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json); see **§2** above).

Example (single define):

```bash
cd apps/emp_ai_boilerplate_app
flutter run --dart-define=FLAVOR=development
```

Example (define file — same pattern for **`flutter build`**):

```bash
cd apps/emp_ai_boilerplate_app
flutter run --dart-define-from-file=config/build_defines.json
```

### 4.2 Web (Chrome / Edge)

```bash
cd apps/emp_ai_boilerplate_app
flutter run -d chrome --dart-define=FLAVOR=development
```

- With **`empAiAuth`**, **`EmpAuth`** uses the catalog’s **web** OAuth client id and **`redirectUrlWeb`** when running on web. Your IdP must allow that **redirect URI** and **CORS / web origins** for your dev origin (e.g. `localhost` and port).
- **Ship:** `flutter build web --release --dart-define=FLAVOR=production` (add more flags as needed). Deploy the **`build/web`** output; production redirect URLs in the catalog (or defines) must match the **real** site origin.

### 4.3 Android

```bash
cd apps/emp_ai_boilerplate_app
flutter run -d android --dart-define=FLAVOR=development
```

- Native builds use **`redirectUrlMobile`** from the catalog (often a **custom scheme** like `myapp://...`). Ensure **AndroidManifest.xml** intent filters / **App Links** match what Keycloak (or your IdP) expects for the mobile client.
- **Release:** `flutter build apk` or `flutter build appbundle` with the same **`--dart-define`** set your CI uses for that flavor.
- **Signing & package id:** see **§5** (product name / `applicationId`).

### 4.4 iOS (Simulator or device)

```bash
cd apps/emp_ai_boilerplate_app
flutter run -d ios --dart-define=FLAVOR=development
```

- Open **`ios/Runner.xcworkspace`** in Xcode: set **Team**, **Bundle Identifier**, and any **URL Types** / **Associated Domains** needed for your **mobile** OAuth redirect scheme (must match IdP client config).
- **Archive / TestFlight:** `flutter build ipa` (your org may add **`--export-options-plist`**, extra defines, or **Xcode schemes** per flavor — similar to **emapta**’s `--target lib/src/main/main_$FLAVOR.dart` pattern).

### 4.5 CI/CD (all platforms)

Use the same **`FLAVOR`** and define set for **web**, **Android**, and **iOS** jobs so every artifact targets the same catalog row.

- **Recommended:** generate **`build_defines.json`** in the pipeline from **secured variables** (Bitbucket / Bitrise / etc.), then pass **`--dart-define-from-file=...`** to **`flutter build web`**, **`flutter build apk`**, **`flutter build ipa`**, etc. Template shape: [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json).
- **Step-by-step** (Bitbucket, Bitrise, emapta-style): [ci_cd.md](../platform/ci_cd.md).
- **Toggles / `FLAVOR`:** [dart_defines.md](../platform/dart_defines.md). **Catalog & env overrides:** [integrations/environment.md](../integrations/environment.md).

<a id="gs-5"></a>

---

## 5. Change the **product name** (what users see)

Most teams only need to change **labels** and **store IDs**. Renaming the **Dart package** (`emp_ai_boilerplate_app`) is a **large** refactor (every `import`); do that only if you insist on a new package name.

### 5a. Easy: name under the icon and in the UI (recommended first)

Change these **five** places (search in your editor for the old strings).

**1 — Window / tab title (per environment)** — Prefer **`boilerplate_environment_catalog.dart`** → each flavor’s **`appTitle`** (wired through **`boilerplateDisplayTitleProvider`** into **`MaterialApp.router`**). Override **`boilerplateDisplayTitleProvider`** only if you need a special case.

**2 — Android launcher label** (still platform-specific) — `apps/emp_ai_boilerplate_app/android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="My Product Name"
```

**3 — Android app id (Play Store / device)** — `apps/emp_ai_boilerplate_app/android/app/build.gradle.kts`

```kotlin
android {
    namespace = "com.mycompany.myproduct"
    defaultConfig {
        applicationId = "com.mycompany.myproduct"
    }
}
```

If you change `namespace`, Android **Kotlin/Java** package folders under `android/app/src/main/kotlin/` must match (or use Android Studio refactor). Until you do that, keep `namespace` and `applicationId` aligned with the existing folder structure, **or** only change `applicationId` first.

**4 — iOS display name** — `apps/emp_ai_boilerplate_app/ios/Runner/Info.plist`

```xml
<key>CFBundleDisplayName</key>
<string>My Product</string>
<key>CFBundleName</key>
<string>myproduct</string>
```

**Bundle identifier** (unique id) is usually in Xcode: open `ios/Runner.xcworkspace` → Runner target → **Signing & Capabilities** → **Bundle Identifier** (e.g. `com.mycompany.myproduct`).

**5 — Web tab title + PWA name** — `web/index.html` and `web/manifest.json`

`index.html`:

```html
<meta name="apple-mobile-web-app-title" content="My Product" />
<title>My Product</title>
```

`manifest.json`:

```json
{
    "name": "My Product",
    "short_name": "My Product",
```

**6 — Human-readable app package description (optional)** — `apps/emp_ai_boilerplate_app/pubspec.yaml`

```yaml
description: My Company customer app.
```

The `name:` field here is the **Dart package name** (`emp_ai_boilerplate_app`). Leave it until you do a full rename (next section).

### 5b. Advanced: rename the **Dart package** and folder

Only if you need `package:my_cool_app/...` everywhere.

1. Rename folder `apps/emp_ai_boilerplate_app` → `apps/my_cool_app` (optional but clearer).
2. In that app’s `pubspec.yaml`, set `name: my_cool_app`.
3. Replace **every** import `package:emp_ai_boilerplate_app/` → `package:my_cool_app/` (whole repo: host app + tests + `miniapps_registry.yaml` import lines).
4. Update `melos.yaml` script `test:boilerplate` `packageFilters` `scope` to the new package name if it references the old name.
5. Update `.github/workflows/ci.yml` paths if they hard-code `apps/emp_ai_boilerplate_app`.
6. Run `dart run melos bootstrap` and `dart run melos run generate:miniapps`, then `dart analyze`.

This is **error-prone**; many teams keep `emp_ai_boilerplate_app` as the internal package name and only change **display** strings (section 5a).

<a id="gs-6"></a>

---

## 6. Example snippets: host behavior (copy and adapt)

Paths are under `apps/emp_ai_boilerplate_app/lib/src/` unless noted.

**Full navigation guide** (file map, add route recipes, redirects, do’s/don’ts): [integrations/navigation.md](../integrations/navigation.md).

### 6a. Login (Keycloak / `emp_ai_auth`)

**Files:** `config/boilerplate_auth_config.dart` (app links and notes), `shell/auth/bootstrap/emp_ai_auth_bootstrap.dart`

Auth is always **`emp_ai_auth`** (`EmpAuth`). Startup calls **`EmpAuth().initialize(...)`** from `emp_ai_auth_bootstrap.dart` (via `loadBoilerplateStartupOverrides()`). Configure either:

- **`--dart-define=AUTH_*`** when **`AUTH_CLIENT_ID`** is set ([define-only bootstrap](../integrations/environment.md#auth-dart-defines-advanced)), or
- **[Flavor catalog](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)** — default when **`AUTH_CLIENT_ID`** is omitted (`FLAVOR` selects the row; mobile vs web client id and redirect follow `kIsWeb`, same idea as emapta `EnvInfo`).

**Widget tests** without Keycloak: [`test/support/boilerplate_auth_test_overrides.dart`](../../apps/emp_ai_boilerplate_app/test/support/boilerplate_auth_test_overrides.dart) — `boilerplateAuthenticatedTestOverrides()` (see [integrations/auth.md](../integrations/auth.md)).

Full steps, precedence, and GoRouter hooks: [integrations/auth.md](../integrations/auth.md) and [integrations/environment.md](../integrations/environment.md#flavor-catalog-emapta-style).

### 6b. Super-app vs standalone vs embedded

**File:** `config/host_mode.dart`

```dart
// Hub + multiple mini-apps (default sample)
const AppHostMode kBoilerplateHostMode = AppHostMode.superApp;

// Single product, top-level routes like /home
// const AppHostMode kBoilerplateHostMode = AppHostMode.standaloneMiniApp;

// Mounted under a prefix, e.g. /demo/...
// const AppHostMode kBoilerplateHostMode = AppHostMode.embeddedMiniApp;
// const String kEmbeddedPathPrefix = 'demo';
```

### 6c. API base URL and flavor (no code edit)

Run or build with defines (values are examples):

```bash
flutter run --dart-define=FLAVOR=staging --dart-define=API_BASE_URL=https://api.staging.example.com
```

Optional logging noise:

```bash
flutter run --dart-define=VERBOSE_LOGS=true
```

By default **`FLAVOR`** selects **`BoilerplateEnvironmentCatalog`** (API base + app title + auth URLs); optional **`API_BASE_URL`** overrides only the API host. **`VERBOSE_LOGS`** is still a define. See [integrations/environment.md](../integrations/environment.md#flavor-catalog-emapta-style) and [host profile overrides](../integrations/environment.md#host-profile-overrides-api-url-verbose-logs).

### 6d. Who can open which routes (RBAC)

**File:** `config/boilerplate_route_access.dart`

Example: require login + permission `orders:read` for anything under `/orders`:

```dart
final routeAccessPolicyProvider = Provider<RouteAccessPolicy>((ref) {
  return const RouteAccessPolicy(
    unmatched: RouteAccessUnmatched.requireAuthentication,
    rules: <RouteAccessRule>[
      RouteAccessRule(
        pathPrefix: '/orders',
        requirement: RouteAccessRequirement(
          requiresAuthentication: true,
          anyOfPermissions: <String>{'orders:read'},
        ),
      ),
    ],
  );
});
```

`pathPrefix` matching is **longest prefix wins** (see [integrations/shell_and_patterns.md](../integrations/shell_and_patterns.md#route-access-roles--permissions-per-path) and [integrations/navigation.md](../integrations/navigation.md)).

**Buttons and menus (same permissions as routes):** route rules only affect navigation. In widgets, use `ref.watch(boilerplateAuthSnapshotProvider)` and e.g. `auth.permissions.contains('orders:read')`, or `RouteAccessRequirement.satisfiedBy` so UI matches the router. Details: [integrations/auth.md](../integrations/auth.md#permissions-in-ui).

### 6e. Maintenance mode or forced upgrade (custom redirect)

**File:** `shell/router/boilerplate_redirect_provider.dart`

Replace the `null` provider with a real redirect:

```dart
final boilerplateCustomRedirectProvider = Provider<GoRouterRedirect?>(
  (ref) {
    return (BuildContext context, GoRouterState state) {
      // Drive from remote config, feature flags, or a build define — not a literal.
      const bool maintenance = false;
      if (maintenance && state.matchedLocation != '/maintenance') {
        return '/maintenance';
      }
      return null; // fall through to auth + RBAC
    };
  },
);
```

You must register a `/maintenance` route (or your path) in the router tree.

### 6f. Deep links (`app_links`)

**Files:** `shell/deep_link/deep_link_listener.dart` (wraps the router), `shell/deep_link/boilerplate_initial_app_link.dart` (cold-start URI from `loadBoilerplateStartupOverrides()`), `config/boilerplate_auth_config.dart` — **`kBoilerplateEnableAppLinks`**.

When **`kBoilerplateEnableAppLinks`** is **`true`**, the listener applies the **initial** URI after the first frame, then **`AppLinks().uriLinkStream`** for subsequent opens. URIs are mapped to a **`GoRouter`** location with **`mapAppLinkToLocation`** (customize for your host / scheme).

**Try it:** unit tests in **`apps/emp_ai_boilerplate_app/test/deep_link_mapping_test.dart`** show expected paths for `https://…` and custom schemes.

**More:** [platform/troubleshooting.md](../platform/troubleshooting.md) (deep links / platforms). [integrations/shell_and_patterns.md](../integrations/shell_and_patterns.md) (router).

### 6g. Add a mini-app from **another repo** or a **WebView** URL

**In-repo** mini-apps: **`miniapps_registry.yaml`** → **`melos run generate:miniapps`** (see [miniapps.md](../engineering/miniapps.md)).

**External** (separate Git repo / package) or **hosted WebView** (URL only): follow **[miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md)** end-to-end. Short version:

1. Add the package to the host **`pubspec.yaml`** (`path:` or `git:`).
2. In that package, ship **`lib/<package_name>_miniapp_registration.dart`** with the exact getter name the doc specifies.
3. In **`miniapp_host_catalog.dart`**, spread **`...thatPackageRegistrations`** into **`kHostMiniAppsCatalog`** (do **not** hand-edit **`miniapp_catalog.g.dart`**).

**Remote allow-list** (optional): set **`MINIAPPS_REGISTRY_URL`** to JSON your backend serves (shape: [fixtures/miniapps_registry.json](../fixtures/miniapps_registry.json)). Empty URL → stub / local-only behavior (good for CI). **`MINIAPPS_REGISTRY_USE_STUB=true`** forces the stub. Details: [dart_defines.md](../platform/dart_defines.md), [miniapps.md](../engineering/miniapps.md).

<a id="gs-7"></a>

---

## 7. What to change before **shipping** (checklist)

**Workspace (once per machine / clone)**

- `dart pub get` at repo root
- `dart run melos bootstrap`
- `dart run melos run generate:miniapps`
- `flutter run` in `apps/emp_ai_boilerplate_app`
- `melos run analyze:all` and `test:boilerplate`

**Product identity**

- Display name (section 5a) + **§3** environment catalog for titles/URLs
- Android `applicationId` + iOS bundle id (stores / deep links)

**Product behavior**

- **`boilerplate_environment_catalog.dart`** — all flavors point at **your** APIs and IdP (not template samples)
- `boilerplate_auth_config.dart` — demo vs `empAiAuth`
- `host_mode.dart` — how the app is hosted
- `API_BASE_URL` / `FLAVOR` for each build variant (CI matches **§4**)
- `boilerplate_route_access.dart` — real RBAC rules
- `miniapps_registry.yaml` — only **in-repo** mini-apps you ship; then `generate:miniapps`
- **`miniapp_host_catalog.dart`** — **`kHostMiniAppsCatalog`** lists everything the hub can show (in-repo merge + external + WebView); see **§6g**
- **`MINIAPPS_REGISTRY_URL`** (and optional stub flag) if you use server-driven mini-app visibility — [dart_defines.md](../platform/dart_defines.md)
- Token / Dio, auth bootstrap, optional local `AUTH_*` / host profile overrides ([integrations/environment.md](../integrations/environment.md), [integrations/auth.md](../integrations/auth.md))
- **`platform/feature_flags/boilerplate_feature_flags.dart`** — keys and defaults match what you ship (mini-app gates, experiments); see [integrations/feature_flags.md](../integrations/feature_flags.md#feature-flags)

<a id="gs-8"></a>

---

## 8. Optional later (not required to run locally)

| Topic                                                                     | Doc                                                                                                               |
| ------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Mixpanel / Firebase                                                       | [HOST_SERVICES.md](../platform/HOST_SERVICES.md)                                                                  |
| Push / local notifications                                                | [HOST_SERVICES.md](../platform/HOST_SERVICES.md)                                                                  |
| Deep links                                                                | [integrations/navigation.md](../integrations/navigation.md), [troubleshooting.md](../platform/troubleshooting.md) |
| Auth + API without defines every run (`AUTH_*` file, host profile tricks) | [integrations/environment.md](../integrations/environment.md)                                                     |
| New feature module (in-repo)                                              | [miniapps.md](../engineering/miniapps.md)                                                                         |
| External package / submodule / WebView mini-app                           | [miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md)                                 |
| Host folder map (shell vs platform)                                       | [host_structure.md](../engineering/host_structure.md)                                                             |
| Design / white-label                                                      | [design_system.md](../design/design_system.md)                                                                    |

### Optional: Figma ZIP metadata

To read `meta.json` from a downloaded `.fig` (ZIP shell only):

```bash
dart run melos run extract:fig-meta -- "/absolute/path/to/file.fig"
```

This does not import full design tokens; see repository [README.md](../../README.md) “Figma tokens” for the recommended Variables → JSON → Dart flow.

<a id="gs-9"></a>

---

## 9. Where to look next (short map)

| Read                                                                              | When                                                                                   |
| --------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [engineering/README.md](../engineering/README.md)                                 | **Start here** for host + mini-app engineering (four links)                            |
| [host_structure.md](../engineering/host_structure.md)                             | Shell vs platform vs mini-apps, one diagram                                            |
| [navigation.md](../integrations/navigation.md)                                    | Routes, redirects, **main-shell menu** (`boilerplate_shell_nav_config.dart`), file map |
| [README.md](../README.md#integrations-hub)                                        | Integrations hub + deep-dive index                                                     |
| [architecture.md](../engineering/architecture.md)                                 | `domain` / `data` / `presentation`                                                     |
| [miniapps.md](../engineering/miniapps.md)                                         | `create:miniapp`, registry, remote gate                                                |
| [miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md) | Package / WebView onboarding                                                           |
| [emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md)            | Auth package clone/patch                                                               |

Repository overview: [README.md](../../README.md). Documentation index: [docs/README.md](../README.md).
