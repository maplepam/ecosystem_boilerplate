# Onboarding external mini-apps (package, submodule, WebView)

This is the **only** supported pattern. Teams **must** follow the syntax below; the super-app **must** integrate only through **`kHostMiniAppsCatalog`**.

**Contract:** every onboarded module is a [`MiniApp`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app.dart) from **`emp_ai_app_shell`**, mounted under **`/${MiniApp.id}/`** ([`MiniAppRouteFactory`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app_route_factory.dart)).

**Host merge file (do not bypass):** [`miniapp_host_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/miniapp_host_catalog.dart) exports **`kHostMiniAppsCatalog`**. [`MiniAppGate`](../../apps/emp_ai_boilerplate_app/lib/src/platform/miniapps_registry/mini_app_gate.dart) and the router use that list. **`miniapp_catalog.g.dart`** stays codegen-only; you **append** external apps here.

---

## A. External Dart mini-app (separate repo or submodule as a package)

### A.1 What the mini-app team **must** ship

1. **A Dart package** (e.g. repo root with `pubspec.yaml`, `lib/`). Submodule layout **must** place it under the monorepo at **`packages/<package_name>/`** (or another path referenced by `path:`).

2. **Minimum `pubspec.yaml` dependencies** (versions **must** match the host’s `go_router` / SDK major lines):

```yaml
name: acme_leave
description: Acme leave management mini-app for the super-app host.
publish_to: none

environment:
  sdk: ">=3.0.5 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  go_router: ^13.2.5
  emp_ai_app_shell:
    git:
      url: git@github.com:maplepam/ecosystem-platform.git
      path: packages/emp_ai_app_shell
      ref: fa051d9bbb71a8dc196c6984aab189e6d33f7e0e
```

**REPLACE** `url` / `ref` with the **same** ecosystem-platform pin as your host (see [`docs/meta/platform_bom.yaml`](../meta/platform_bom.yaml)), or a **path:** override for local development only.

3. **Exactly one registration library** with this **file name**:

`lib/<package_name>_miniapp_registration.dart`

Example for package `acme_leave` → **`lib/acme_leave_miniapp_registration.dart`**.

That file **must** expose **exactly** this API (names are mandatory so hosts integrate uniformly):

```dart
import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';

import 'acme_leave_miniapp.dart';

/// Host imports this file and spreads this list into [kHostMiniAppsCatalog].
List<MiniApp> get acmeLeaveMiniappRegistrations => <MiniApp>[
      AcmeLeaveMiniApp(),
    ];
```

**Rules:**

- The getter name is **`<camelCasePackageName>MiniappRegistrations`** (package `acme_leave` → `acmeLeaveMiniappRegistrations`).
- It returns a **non-empty** `List<MiniApp>` (even for a single app).
- Every element is a **`MiniApp`** (see §A.2).

4. **The `MiniApp` implementation** in the same package (e.g. `lib/acme_leave_miniapp.dart`) **must** satisfy:

```dart
import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class AcmeLeaveMiniApp extends MiniApp {
  AcmeLeaveMiniApp();

  @override
  String get id => 'acme_leave';

  @override
  String get displayName => 'Leave';

  /// Full path to the default child route: `/` + [id] + `/` + first segment.
  /// Example: id `acme_leave`, first route path `home` → `/acme_leave/home`.
  @override
  String get entryLocation => '/acme_leave/home';

  /// **REPLACE** with your feature-flag key, or use `with MiniAppAlwaysOn` instead of overriding.
  @override
  String? get requiredFeatureFlagKey => null;

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: 'home',
          name: 'acme_leave_home',
          builder: (BuildContext context, GoRouterState state) =>
              const Placeholder(), // REPLACE with your root screen
        ),
      ];
}
```

**Always-on variant (no flag):**

```dart
final class AcmeLeaveMiniApp extends MiniApp with MiniAppAlwaysOn {
  // ...
  // omit requiredFeatureFlagKey
}
```

**Hard rules:**

- **`id`:** lowercase, `[a-z0-9_]+`, stable forever (remote registry + analytics use it).
- **`routes`:** only **child** segments; the host mounts them under **`/$id/`**. Paths **must not** start with `/`.
- **`entryLocation`:** **absolute** app path, **must** equal `/$id/<firstRoutePath>` for the default tab.

---

### A.2 Submodule (Git) — exact host steps

From the **monorepo root** (`ecosystem_boilerplate/`):

```bash
git submodule add <git@github.com:org/acme_leave.git> packages/acme_leave
git submodule update --init --recursive
```

In **`apps/emp_ai_boilerplate_app/pubspec.yaml`:**

```yaml
dependencies:
  acme_leave:
    path: ../../packages/acme_leave
```

Then run **`flutter pub get`** from `apps/emp_ai_boilerplate_app/`.

---

### A.3 Super-app integration (mandatory edits)

1. **`pubspec.yaml`** — add `path:` or `git:` dependency as above.

2. **`lib/src/miniapps/miniapp_host_catalog.dart`** — add **import** + **spread**:

```dart
import 'package:acme_leave/acme_leave_miniapp_registration.dart';

List<MiniApp> get kHostMiniAppsCatalog => <MiniApp>[
      ...kAllMiniApps,
      ...acmeLeaveMiniappRegistrations,
    ];
```

3. **`miniapps_registry.yaml` / codegen** — **optional** for external-only apps; if the mini-app is **not** in YAML, it still appears in the hub **if** it is in **`kHostMiniAppsCatalog`**. If you use codegen for docs only, keep YAML in sync with **`id`** for humans.

4. **Remote registry API** — if used, include this **`id`** in `enabled_miniapp_ids` (see [`docs/fixtures/miniapps_registry.json`](../fixtures/miniapps_registry.json)).

5. **RBAC** — add route prefixes in **`config/boilerplate_route_access.dart`** for `/acme_leave` (or your id) if the area is authenticated.

**Do not** register the same `MiniApp` in both codegen and external list twice (duplicate `id` breaks hub/router).

---

## B. WebView-only mini-app (no partner Dart code in this repo)

Use this when the product is **only** a URL inside the shell.

### B.1 What the super-app **must** do

1. Ensure **`webview_flutter`** is in the host **`pubspec.yaml`** (already added in the boilerplate).

2. Edit **`lib/src/miniapps/miniapp_host_catalog.dart`** — import and append **one** [`HostedWebMiniApp`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/webview_shell/hosted_web_miniapp.dart):

```dart
import 'package:emp_ai_boilerplate_app/src/miniapps/webview_shell/hosted_web_miniapp.dart';

List<MiniApp> get kHostMiniAppsCatalog => <MiniApp>[
      ...kAllMiniApps,
      HostedWebMiniApp(
        id: 'partner_portal',
        displayName: 'Partner portal',
        initialUrl: Uri.parse('https://partner.example.com/app/'),
      ),
    ];
```

**REPLACE** `id`, `displayName`, `initialUrl`. Optional: `routePath` (default `'home'` → `/partner_portal/home`).

3. **Security (mandatory before production):** edit [`hosted_web_view_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/webview_shell/hosted_web_view_screen.dart) — add navigation delegate, HTTPS allow-list, auth cookies, or switch to **`flutter_inappwebview`** if your security model requires it.

4. **Remote registry / RBAC** — same as §A.3 steps 4–5 using **`partner_portal`** (or your `id`).

**There is no separate package** for WebView-only partners unless you **choose** to wrap `HostedWebMiniApp` in another repo; the supported default is **host-only** registration as above.

---

## C. Extracting an in-repo mini-app into its own repository

1. Create a new package repo with the same layout as §A.1 (`<package_name>_miniapp_registration.dart` + `MiniApp` class + `emp_ai_app_shell` + `go_router`).

2. Move `lib/src/miniapps/<id>/` implementation into `packages/<package_name>/lib/` (keep `data` / `domain` / `presentation` inside the package).

3. Remove the old **`MiniApp`** class and routes from the host `miniapps/` tree; remove its entry from **`miniapps_registry.yaml`** and run **`melos run generate:miniapps`**.

4. Add the package per §A.2–A.3 and **`...<camelCase>MiniappRegistrations`** in **`kHostMiniAppsCatalog`**.

5. Version the package; pin the host to a compatible range.

---

## Navigation: host (boilerplate / super-app) vs mini-app routes

Use a **single** [`GoRouter`](https://pub.dev/documentation/go_router/latest/go_router/GoRouter-class.html) tree assembled by the host. Where you navigate from (**shell**, **hub**, or **inside a mini-app**) depends on [`AppHostMode`](../../apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart) and how routes were merged.

### Host modes (where shell vs mini-apps live)

| Mode | Router assembly | Typical “main” UI |
|------|-----------------|-------------------|
| **`standaloneMiniApp`** | [`boilerplateShellRoutes()`](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_shell_routes.dart) at the **root** | Hub under `main/hub/...`, catalog under `widgets`, etc. |
| **`embeddedMiniApp`** | Same shell routes, mounted under a **path prefix** (`kEmbeddedPathPrefix`) | Same screens, URLs prefixed (e.g. for embedding). |
| **`superApp`** | [`MiniAppRouteFactory.buildTree`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app_route_factory.dart) **or** `buildTreeWithStatefulShell` **plus** `/hub` | Hub page lists apps; each [`MiniApp`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app.dart) is a **top-level branch** `/${MiniApp.id}/...`. |

Source of truth: [`boilerplateGoRouterProvider`](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_router.dart).

### Mini-app internal routes (all Dart packages: A and C)

- Each [`MiniApp`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app.dart) exposes **`routes`** as **child** [`RouteBase`](https://pub.dev/documentation/go_router/latest/go_router/RouteBase-class.html) list segments only (no leading `/`).
- The host mounts them under **`/${id}/`** with [`MiniAppMountStrategy.nestedUnderId`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app_route_factory.dart) (default).
- **`entryLocation`** must be the **full** path to the default screen, e.g. `/acme_leave/home`.
- **Inside the mini-app**, prefer:
  - **Relative** child routes in `GoRoute(path: 'detail', ...)` under a parent, and `context.push('detail', extra: …)` / `go` to logical children; or
  - **Absolute** paths when crossing subtrees: `context.go('/${MiniApp.id}/other')` (hard-code `id` or inject a base path constant).

**Do not** assume the hub path (`/main/hub/...`) exists in **superApp** mode — that tree is different from **standalone** / **embedded**.

### Scenario A — External Dart mini-app (package / submodule)

| From | Use |
|------|-----|
| Host shell / another mini-app → this app | **`context.go(entryLocation)`** or **`context.go('/<id>/<segment>')`** with the registered **`id`**. |
| Inside this mini-app → deeper screen | **`context.push`** relative to current branch, or **`goNamed`** if you register **`name:`** on [`GoRoute`](https://pub.dev/documentation/go_router/latest/go_router/GoRoute-class.html)s. |
| Mini-app → host-only feature (e.g. theme) | Only valid if that route exists in the **current** host mode; use the **full** path (e.g. standalone: `/main/theme`). |

### Scenario B — WebView-only mini-app

- Flutter **`GoRouter`** usually exposes **one** (or few) shell routes for the WebView screen (e.g. `/partner_portal/home`).
- **In-app navigation** is **WebView history / URL**, not **`GoRouter`** child routes, unless you add extra `GoRoute`s for native chrome.
- **Deep links**: map to the host `GoRoute` that owns the WebView, then pass query/path into the WebView load API.

### Scenario C — In-repo mini-app extracted to a package

- Same contract as **A**: `MiniApp` + `nestedUnderId` + **`entryLocation`**.
- Update **any** hard-coded paths in the extracted code from old host-relative URLs to **`/<id>/...`** (or inject a `Uri` base from the host).

### Mixing super-app rail + standalone-style hub (mental model)

- **SuperApp**: “Product switcher” lives in [`SuperAppStatefulShellScaffold`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/super_app_stateful_shell_scaffold.dart) / hub; each product is **`/$id/*`**.
- **Standalone / embedded**: “Hub” tabs (Samples / Resources / Announcements) are **shell** routes in [`boilerplateShellRoutes`](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_shell_routes.dart), not separate `MiniApp` branches unless you also register them in `kHostMiniAppsCatalog`.

When adding a **new** onboarded mini-app, decide explicitly:

1. **Shell-only** (no `MiniApp`): add `GoRoute`s under the existing shell (good for first-party features tightly coupled to the boilerplate UI).
2. **`MiniApp`**: register in **`kHostMiniAppsCatalog`** and use **`/$id/`** (good for team ownership, feature flags, super-app rail).
3. **Hybrid**: keep thin shell `GoRoute`s that **embed** or **redirect** into `/$id/...` if you need both hub placement and `MiniApp` lifecycle.

Document the choice in your mini-app README so integrators know which **`context.go`** paths are stable.

---

## Related

- [miniapps.md](miniapps.md) — YAML codegen, flags, remote registry HTTP
- [host_structure.md](host_structure.md) — `miniapps/` vs `platform/miniapps_registry`
