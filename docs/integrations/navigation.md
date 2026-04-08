# Navigation & routing (GoRouter)

Practical guide for **adding routes**, **calling navigation**, **redirects**, and **what to avoid**. The host uses `**go_router`** plus `**emp_ai_core**`’s `**CoreGoRouterFactory**` and `**emp_ai_app_shell**`’s `**MiniAppRouteFactory**`.

**Related:** [shell_and_patterns.md](shell_and_patterns.md) (RBAC types, Riverpod), [miniapps.md](../engineering/miniapps.md) (new mini-app scaffold), [miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md) (external package + `MiniApp` contract, host merge), [auth.md](auth.md) (login, `authNavigationRefreshListenableProvider`). **Super-app vs main shell:** [§ below](#super-app-and-main-shell).

---

## Simple guide (read this first)

The app uses one **router** (GoRouter). It decides **which screen** opens for each URL and **who must be logged in** to see it.

### 1. Editing the host after a fork

The **host app** (`apps/emp_ai_boilerplate_app`) is where product teams change routes and rules.

Think in **three bands**:


| Band                       | Plain English                                                                | Examples                                                                                                                                                                                                                                                             |
| -------------------------- | ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Safe to change**         | Your product; edit freely.                                                   | `host_mode.dart`, `boilerplate_route_access.dart`, `boilerplate_public_paths.dart`, shell routes/paths/**nav config** (`boilerplate_shell_nav_config.dart`) / scaffold, `miniapps_registry.yaml`, folders under `lib/src/miniapps/`, custom redirect in `boilerplate_redirect_provider.dart`, `boilerplate_dev_routes.dart` |
| **Add, don’t replace**     | Use what the packages already give you; **add** rules or mini-apps.          | New `RouteAccessRule`s, new `MiniApp` classes, optional `boilerplateCustomRedirectProvider`                                                                                                                                                                          |
| **Watch on upstream pull** | Boilerplate maintainers may edit the **same** files when they ship features. | `boilerplate_router.dart`, full redirect chain in `boilerplate_redirect_provider.dart`, `boilerplate_landing_auth_redirect.dart`, `pubspec.yaml`                                                                                                                     |


**One rule:** do **not** edit `**miniapp_catalog.g.dart`**. Change `**miniapps_registry.yaml**`, then run `**dart run melos run generate:miniapps**`.

### 2. When you `git pull` boilerplate updates

1. Expect conflicts sometimes in the **“watch”** files above.
2. Run `**dart run melos bootstrap`** and `**dart run melos run generate:miniapps**`.
3. Run `**dart analyze**` and click through **login → home → one deep link**.

### 3. Packages vs your app (one glance)


| Lives in **packages** (`emp_ai_core`, …)                   | Lives in **your host app**                                                         |
| ---------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Router **factory**, **RBAC redirect helper**, shared types | **Actual URLs**, **menu**, **who can open which path**, **landing/login** behavior |


**Auth:** `**emp_ai_auth`** does login/tokens; **your app** chooses IdP URLs and client ids (catalog / defines).

---

## Mental model


| Layer                | What it is                                                                                                                                                                                        |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Router**           | Single `**GoRouter`** from `[boilerplateGoRouterProvider](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_router.dart)`, built differently per `**AppHostMode**` (`host_mode.dart`). |
| **Top-level routes** | Landing, `/login`, `/unauthorized`, dev tools, and (super-app) `/` + `/hub` + merged **mini-app** trees.                                                                                          |
| **Main shell**       | Shared **Overview / theme / widget catalog / Hub** under a `**ShellRoute`** — same tree for super-app (`**/main/...**`), standalone (`**/home**`, …), embedded (`**/<prefix>/...**`).             |
| **Mini-apps**        | Each `**MiniApp`** contributes a `**List<RouteBase>**`; the shell mounts them under `**/<miniAppId>/...**` (e.g. `**/samples/demo**`).                                                            |
| **Redirects**        | A **chain**: landing/auth → optional custom (maintenance) → **RBAC + auth** ([`createRouteAccessRedirect`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_core/lib/src/router/route_access_redirect.dart)).                |


Paths **change with host mode**. Prefer `**[BoilerplateShellPaths](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_paths.dart)`** for main-shell URLs instead of hard-coding `**/main/...**`.

<a id="super-app-and-main-shell"></a>

## Super-app shell vs main shell (Northstar)

How the boilerplate layers **outer** super-app chrome (mini-app branches) and **inner** product chrome (Overview, Components, Hub, …), and how to **customize** shell behavior. Host config: [`host_mode.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart).

### Two layers

| Layer | Responsibility | Primary files |
|--------|----------------|---------------|
| **Super-app shell** | Hosts one `StatefulNavigationShell` branch per registered `MiniApp` (main shell, announcements, resources, samples, …). Can show an **Apps** rail + (on narrow) a bottom bar **or** hide that chrome entirely. | [`super_app_stateful_shell_scaffold.dart`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/super_app_stateful_shell_scaffold.dart), [`mini_app_route_factory.dart`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app_route_factory.dart) |
| **Main shell (Northstar)** | Inside the **main** mini-app only: left nav / drawer / bottom bar driven by **`boilerplateShellNavConfigProvider`**; narrow **segmented** sibling switch in **`WideHubSplit`** reads the same config. | **`boilerplate_shell_nav_config.dart`**, `boilerplate_shell_scaffold.dart`, `boilerplate_shell_routes.dart`, `wide_hub_split.dart` |

Example paths: `/main/home`, `/main/hub/samples`, `/announcements/home`, `/samples/demo`.

### Wide layout (breakpoint ≥ `kSuperAppShellWideBreakpoint`)

The **side rail** runs **full height** (within `SafeArea`). The **strip with the page title** (Overview, Components, …) sits only in the **content column** to the right of the rail — it does **not** span above the rail. Narrow layouts use `AppBar` / bottom nav or drawer instead.

### Flags in `host_mode.dart`

- **`kBoilerplateHostMode`** — `superApp` vs `standaloneMiniApp` vs `embeddedMiniApp` (path prefix for embedded).
- **`kSuperAppUseStatefulShell`** — `true`: `StatefulShellRoute.indexedStack` so each mini-app keeps its own stack. `false`: flat `GoRoute` list from `MiniAppRouteFactory.buildTree` (no indexed shell).
- **`kSuperAppShowMiniAppRail`** — `false` (**default in boilerplate**): hides the outer **Apps** rail and the mini-app **bottom** `NavigationBar`. Users rely on **main shell + Hub** (and deep links). Set to `true` for the classic multi-column “Apps” UI.

Wiring: `boilerplate_router.dart` passes `showMiniAppRail: kSuperAppShowMiniAppRail` into `MiniAppRouteFactory.buildTreeWithStatefulShell`.

**Narrow layout:** When the outer rail is hidden, `BoilerplateShellScaffold` can use its own bottom `NavigationBar` for Overview / Components / Look & feel / Hub (see `avoidBottomBarStack` in `boilerplate_shell_scaffold.dart`).

### `BoilerplateShellPaths`, Hub, and direct mini-app URLs

Use **`context.go` / `context.push`** with stable paths from **`BoilerplateShellPaths`** (`boilerplate_shell_paths.dart`):

- Main shell: `BoilerplateShellPaths.home`, `.widgets`, `.theme`, `.hubSamples`, `.hubResources`, `.hubAnnouncements`, `.widgetDetail(id)`, `.designSystemShowcase`
- Paths adapt to host mode (`/main/...` in super-app, `/...` in standalone, `/demo/...` embedded).

**Hub:** `/main/hub` redirects to `/main/hub/samples`; sub-routes `hub/resources`, `hub/announcements` mirror standalone mini-apps inside `WideHubSplit`.

**Direct mini-app URLs:** e.g. `context.go('/announcements/home')` — `StatefulNavigationShell` switches branch when the location matches another mini-app.

### Customizing the main shell (inner nav)

1. **Menu** — [`boilerplate_shell_nav_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_nav_config.dart): **`defaultBoilerplateShellNavItems()`** or override **`boilerplateShellNavConfigProvider`**. **`ShellNavTopLeaf`** vs **`ShellNavTopParent`** + **`ShellNavLeaf`**; **parent rows never `go()`** — only leaves navigate. Details: **Main shell side navigation (configurable)** below.
2. **Routes** — Extend **`boilerplate_shell_routes.dart`** and **`BoilerplateShellPaths`** so each **`ShellNavLeaf.location`** matches a real **`GoRoute`**.
3. **Home cards** — [`MainShellHomeScreen`](../../apps/emp_ai_boilerplate_app/lib/src/screens/main_shell_home_screen.dart) (often replaced with a product landing page).
4. **Narrow Hub segments** — **`WideHubSplit.breakpointWidth`** in [`wide_hub_split.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/wide_hub_split.dart).
5. **Chrome** (gradient header, copy, rail width, footer) — [`boilerplate_shell_scaffold.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_scaffold.dart).

### Customizing the super-app shell (`emp_ai_app_shell`)

- Prefer **`kSuperAppShowMiniAppRail`** in the host before forking layout.
- **`SuperAppStatefulShellScaffold`** accepts `showMiniAppRail` (defaults `true` for other consumers).

### Shell layout troubleshooting

- **Side nav overflow** — Rail animates 72→280px; labels render only above **`_kMinWidthForExpandedLabels`**; tiles use `ClipRect` + `TextOverflow.ellipsis`.
- **Double app bars** — Hub embeds mini-app screens that may ship their own `AppBar`; consider an embed flag per screen if you need one bar.

---

## File map (where to look)


| File                                                                                                                                | Role                                                                                                                                 |
| ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `[host_mode.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart)`                                                 | `**kBoilerplateHostMode**`, `**kSuperAppUseStatefulShell**`, `**kSuperAppShowMiniAppRail**`, embedded prefix.                        |
| `[boilerplate_router.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_router.dart)`                               | `**boilerplateGoRouterProvider**`: composes **top-level** routes + `**CoreGoRouterFactory`**.                                        |
| `[boilerplate_shell_routes.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_shell_routes.dart)`                   | `**boilerplateShellRoutes()**` — main shell `**GoRoute**` / `**ShellRoute**` tree + `**BoilerplateShellRouteNames**`.                |
| `[boilerplate_shell_paths.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_paths.dart)`                 | **Stable path helpers** (`home`, `hubSamples`, `widgetDetail(id)`, …) per host mode.                                                 |
| `[boilerplate_shell_nav_config.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_nav_config.dart)`       | **Configurable main-shell menu:** ordered list of **leaves** (`ShellNavTopLeaf`) and **parents** (`ShellNavTopParent` with children). Drives side rail, drawer, bottom bar selection, app bar titles, and narrow Hub segment picker (via `shellNavParentOwningPath`). Override **`boilerplateShellNavConfigProvider`** to customize without editing scaffold lists by hand. |
| `[boilerplate_shell_scaffold.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_scaffold.dart)`           | Composes wide/narrow shell: Riverpod, `GoRouter`, app bar. **Menu UI** lives under `navigation/widgets/`; **parent expand/collapse state** in `shell_nav_expansion.dart`. |
| `navigation/widgets/*.dart` | Reusable shell chrome: **`ShellWebSideNav`**, **`ShellSideNavTile`**, **`ShellNavRailBranding`**, **`ShellMobileDrawerNav`**, **`ShellDrawerParentSection`**. Listed in the **Components** catalog via **`boilerplate_host_widget_catalog_entries.dart`**. |
| `[shell_nav_expansion.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/shell_nav_expansion.dart)` | **`ShellNavExpansionCoordinator`** — which `ShellNavParent` rows are open; no widgets. |
| `[boilerplate_widget_catalog.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_widget_catalog.dart)` | **`boilerplateWidgetCatalogAllEntries()`** = DS **`builtInEntries()`** + host shell entries; **`findBoilerplateWidgetCatalogEntry`**. |
| `[wide_hub_split.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/wide_hub_split.dart)`                                   | Narrow-width **segmented** switch between siblings under the **same** `ShellNavParent` (reads config + current path). No hardcoded Hub segment names. |
| `[miniapps/*/*_miniapp.dart](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/)`                                                  | Per–mini-app `**MiniApp`** subclass: `**routes**`, `**entryLocation**`, optional feature flag.                                       |
| `[miniapps_registry.yaml](../../apps/emp_ai_boilerplate_app/miniapps_registry.yaml)` + generated catalog                            | Which mini-apps exist; run `**dart run melos run generate:miniapps**` after changes.                                                 |
| `[boilerplate_redirect_provider.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_redirect_provider.dart)`         | `**boilerplateGoRouterRedirectProvider**`, `**boilerplateCustomRedirectProvider**`, `**routeAccessRedirectConfigProvider**`.         |
| `[boilerplate_landing_auth_redirect.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_landing_auth_redirect.dart)` | Super-app **landing vs login** and `**?redirect=`** (unauthenticated).                                                               |
| `[boilerplate_public_paths.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_public_paths.dart)`                   | Prefixes that **skip** RBAC enforcement (login, unauthorized, `/`, `/samples`, dev).                                                 |
| `[boilerplate_route_access.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart)`                   | `**routeAccessPolicyProvider`**, `**authLoginPathProvider**`, `**authUnauthorizedPathProvider**`, `**authDefaultHomePathProvider**`. |
| `[auth_navigation_refresh.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/token_refresh/auth_navigation_refresh.dart)`         | `**authNavigationRefreshListenableProvider**` — triggers redirect re-run after login/logout.                                         |
| `[boilerplate_dev_routes.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_dev_routes.dart)`                       | Dev-only top-level routes.                                                                                                           |


---

## How to add a route

### A. New screen inside the **main shell** (Overview / Hub / catalog)

1. Add a `**GoRoute`** (or nest under existing `**ShellRoute**`) in `[boilerplate_shell_routes.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_shell_routes.dart)`. Use a `**name**` if you need `**goNamed**` / deep links.
2. Add a **getter** on `[BoilerplateShellPaths](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_paths.dart)` for any path you will `**go`** to from code.
3. Register the screen in **[`boilerplate_shell_nav_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_nav_config.dart)** (or override **`boilerplateShellNavConfigProvider`**): add a **`ShellNavTopLeaf`** for a top-level destination, or a **`ShellNavLeaf`** under an existing **`ShellNavTopParent`** for a grouped area. Each leaf’s **`location`** must match the real **`GoRouter`** location (use **`BoilerplateShellPaths`** getters). **Parent rows do not call `go`** — they only expand/collapse; navigation happens when the user taps a **child** leaf. See **Main shell side navigation (configurable)** below.
4. If the route should be **gated by auth/roles**, add or extend a `**RouteAccessRule`** in `[boilerplate_route_access.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart)` (prefix must match the **full** location, e.g. `**/main/...`** in super-app). If it must be reachable **without** sign-in, add the prefix to `[boilerplate_public_paths.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_public_paths.dart)` **or** use a `**RouteAccessRule`** with `**RouteAccessRequirement()**` (public).

#### Main shell side navigation (configurable)

| Piece | Where / what |
| ----- | ------------- |
| **Data model** | **`ShellNavLeaf`**: `location`, `label`, `IconData`, optional `appBarTitle` (defaults to `label`). **`ShellNavParent`**: stable string **`id`**, `label`, `icon`, `children` (`List<ShellNavLeaf>`). **`ShellNavItem`**: either **`ShellNavTopLeaf`** (one routable tile) or **`ShellNavTopParent`** (folder). |
| **Default tree** | **`defaultBoilerplateShellNavItems()`** in the same file — copy or compose from it in a custom provider. |
| **Provider** | **`boilerplateShellNavConfigProvider`** → `Provider<List<ShellNavItem>>`. Override in **`ProviderScope(overrides: …)`** for tests, flavors, or a product-specific menu without forking the scaffold. |
| **Path matching** | **`ShellNavLeaf.matchesPath`** treats the current URI path as active if it equals **`location`** or starts with **`location/`** — keep leaf locations **aligned** with your `GoRoute` paths. |
| **Chrome that consumes it** | **`BoilerplateShellScaffold`** (wide rail, drawer, bottom **`NavigationBar`**), **`shellNavSelectedIndex`**, **`shellNavAppBarTitle`** (widget-catalog detail still uses **`shellNavWidgetDetailTitle`**). **`WideHubSplit`** picks the **`ShellNavParent`** that **`containsPath`** and builds a **`SegmentedButton`** from that parent’s **`children`** when the viewport is narrow **and** the parent has **more than one** child. |
| **Mobile bottom bar + parent** | Tapping a **parent** destination opens the **drawer** and expands that parent so the user picks a **child** (parents still do not **`go`**). |
| **Scaffold file** | Edit **`boilerplate_shell_scaffold.dart`** only for **layout / branding** (e.g. “Starter shell” card, footer tip, hover width) — not for duplicating menu entries. |

### B. New **mini-app** (separate product area, own URL prefix)

1. Run `**dart run melos run create:miniapp -- your_id`** — see [miniapps.md](../engineering/miniapps.md).
2. Implement `**routes**` on your `**MiniApp**` class (paths are **relative** to the mini-app mount, e.g. `**demo`** → `**/samples/demo**` when `**id**` is `**samples**`).
3. Set `**entryLocation**` to the default URL for that app.
4. Run `**dart run melos run generate:miniapps**` after registry changes.
5. Add `**RouteAccessRule**` entries for `**/<yourMiniAppId>**` if the default **unmatched** policy is not what you want (see current rules for `**/announcements`**, `**/resources**`, `**/samples**`).

**External / separate-repo package** (team ships a Dart package with its own `**MiniApp**` and routes): follow the **two-party contract**, registration file name, and host merge steps in [miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md). Those routes are merged in **`AppHostMode.superApp`** via **`kHostMiniAppsCatalog`** and **`MiniAppRouteFactory`**; **standalone** / **embedded** hosts do not mount **`MiniApp.routes`** unless you extend the host router (same doc — **Host mode vs route merge**).

### C. **Top-level** route (alongside `/login`, landing, …)

- Prefer **not** to fork `**boilerplate_router.dart`** lightly: append to `**boilerplateTopLevelAuthAndDevRoutes()**` or the `**routes**` list in the `**switch (kBoilerplateHostMode)**` branch that matches your case.
- If the path must be **public**, extend `**boilerplatePublicPathsProvider`** in `[boilerplate_public_paths.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_public_paths.dart)`.

---

## Calling navigation (`go` / `push` / `pop`)

Use `**go_router**` extensions on `**BuildContext**` or `**GoRouter.of(context)**`.


| API                                                | When to use                                                                                                           |
| -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `**context.go(location)**`                         | Replace the current stack (typical **tab** or **shell** switch). Prefer `**BoilerplateShellPaths.*`** for main shell. |
| `**context.push(location)**`                       | Push a **detail** or **modal** route onto the stack; use `**context.pop()`** (or `**Navigator.pop**`) to return.      |
| `**context.goNamed(name, pathParameters: {...})**` | Stable **named** routes — names are defined on `**GoRoute`** (see `**BoilerplateShellRouteNames**`).                  |
| `**context.pop()**`                                | Pop the current route when you used `**push**`.                                                                       |


**Path parameters:** declare `**path: 'widgets/:catalogId'`** and read `**state.pathParameters['catalogId']!**` in the `**builder**` (see widget catalog in `**boilerplate_shell_routes.dart**`).

**Query parameters:** read `**state.uri.queryParameters`**; for post-login return URLs the landing redirect uses `**?redirect=**` (`[boilerplate_landing_auth_redirect.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_landing_auth_redirect.dart)`).

---

## Redirects (global)

Execution order is `**chainGoRouterRedirects**` in `[boilerplate_redirect_provider.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_redirect_provider.dart)`:

1. `**boilerplateLandingAuthRedirectProvider**` — super-app landing/login vs authenticated home and `**?redirect=**`.
2. `**boilerplateCustomRedirectProvider**` — set this to a `**GoRouterRedirect**` for **maintenance**, **force upgrade**, etc.; return `**null`** to continue.
3. `**createRouteAccessRedirect**` — **auth + RBAC** using `**routeAccessPolicyProvider`** and `**authSessionReaderProvider**`.

**Route-local `redirect`:** You can set `**redirect:`** on a `**GoRoute**` (e.g. `**/hub**` → `**hub/samples**`) inside `**boilerplate_shell_routes.dart**`.

**After login or logout:** the app uses `**authNavigationRefreshListenableProvider`** so **GoRouter** refreshes and re-runs the global redirect chain — do not bypass this for auth flows ([auth.md](auth.md)).

---

## Do’s

- **Do** use `**BoilerplateShellPaths`** (or mini-app **absolute** paths like `**/samples/demo`**) from UI code instead of string literals that assume one host mode.
- **Do** add **RBAC rules** when you introduce **new authenticated subtrees**; align **longest-prefix** rules with how **`normalizePath`** works ([`RouteAccessPolicy`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_core/lib/src/router/route_access_policy.dart)).
- **Do** mirror **router rules** in **widgets** when hiding buttons (same permissions) — [auth.md — Permissions in UI](auth.md#permissions-in-ui).
- **Do** use `**authLoginPathProvider`** / `**authDefaultHomePathProvider**` when sending users to login or home (`[boilerplate_route_access.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart)`).
- **Do** run `**generate:miniapps`** after `**miniapps_registry.yaml**` changes.

## Don’ts

- **Don’t** navigate **inside** `**domain/`** — keep routing in **presentation** / widgets / notifiers that already have `**BuildContext`** or `**GoRouter**`.
- **Don’t** rely only on **UI hiding** for security; **redirects** enforce route access, **backend** enforces APIs.
- **Don’t** forget **public paths** for routes that must work **unauthenticated** (marketing, public samples, dev) — otherwise the **access redirect** will send users to **login**.
- **Don’t** hard-code `**/main`** if you ship **standalone** or **embedded** builds; `**BoilerplateShellPaths`** encodes the difference.
- **Don’t** bypass `**MiniAppGate`** for feature-flagged apps — deep links should respect the same gates ([feature_flags.md](feature_flags.md)).

---

## After fork: ownership, upstream pulls, and packages

Use this when you **clone/fork** the monorepo, **pull boilerplate updates**, or decide **what belongs in shared packages** vs the host app.

### Backbone today (reuse across teams — prefer **not** to fork)


| Package                 | Navigation / auth role                                                                                                                                                                                                                                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `**emp_ai_core`**       | `**AppHostMode**`, `**CoreGoRouterFactory**` + `**CoreRouterConfig**` (prefix + `GoRouter` wiring), `**RouteAccessPolicy**` / `**RouteAccessRule**` / `**createRouteAccessRedirect**`, `**chainGoRouterRedirects**`. This is already the **shared spine** for host-mode rules and RBAC redirects. |
| `**emp_ai_app_shell`**  | `**MiniApp**`, `**MiniAppRouteFactory**` (flat + **StatefulShell** trees), hub/scaffold integration patterns used by the host.                                                                                                                                                                    |
| `**emp_ai_foundation`** | `**AuthSessionReader**`, `**AuthSnapshot**` — contracts the redirect layer reads (no `go_router` in domain).                                                                                                                                                                                      |
| `**emp_ai_auth**`       | `**EmpAuth**`, login UI, token/session implementation; host **bootstraps** credentials via `[emp_ai_auth_bootstrap.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart)`.                                                                                   |


The **boilerplate app** supplies **concrete routes**, **policy rows** (`/main`, `/announcements`, …), **path helpers**, and **product-specific** landing/login redirect — that is intentional so each product can diverge without forking core.

### Configure freely (typical product fork — low upstream conflict)

These are **meant** to become *yours*: replace demo paths, titles, and rules as your product grows.


| Area                       | Files / artifacts                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Environment & IdP**      | `[boilerplate_environment_catalog.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)`, auth bootstrap (see [environment.md](environment.md), [auth.md](auth.md)).                                                                                                                                                                                                                                                                |
| **Host mode**              | `[host_mode.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart)`.                                                                                                                                                                                                                                                                                                                                                                                       |
| **RBAC matrix**            | `[boilerplate_route_access.dart](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart)` — rules, login/unauthorized/home **paths** per mode.                                                                                                                                                                                                                                                                                                     |
| **Public routes**          | `[boilerplate_public_paths.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_public_paths.dart)`.                                                                                                                                                                                                                                                                                                                                                         |
| **Main shell UX + routes** | **`[boilerplate_shell_nav_config.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_nav_config.dart)`** (**menu tree** + **`boilerplateShellNavConfigProvider`**), `[boilerplate_shell_routes.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_shell_routes.dart)`, `[boilerplate_shell_paths.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_paths.dart)`, `[boilerplate_shell_scaffold.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_scaffold.dart)` (chrome), `[wide_hub_split.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/wide_hub_split.dart)` (narrow segments). |
| **Mini-apps**              | `[miniapps_registry.yaml](../../apps/emp_ai_boilerplate_app/miniapps_registry.yaml)`, `lib/src/miniapps/<your_app>/`, generated catalog (**regenerate**, don’t hand-edit `**miniapp_catalog.g.dart`**).                                                                                                                                                                                                                                                                    |
| **Custom global redirect** | `[boilerplate_redirect_provider.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_redirect_provider.dart)` — usually only `**boilerplateCustomRedirectProvider`**.                                                                                                                                                                                                                                                                                        |
| **Dev-only routes**        | `[boilerplate_dev_routes.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_dev_routes.dart)` (strip or gate for release builds if you want).                                                                                                                                                                                                                                                                                                              |


### Extend patterns; avoid copy-paste duplicating core


| Concern                       | Guidance                                                                                                                                                                                                              |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **New route access behavior** | Add `**RouteAccessRule`** entries or adjust `**RouteAccessUnmatched**` using `**emp_ai_core**` types — don’t reimplement redirect logic in widgets.                                                                   |
| **New mini-app**              | Subclass `**MiniApp`** and register in YAML — use `**MiniAppGate**` / flags ([feature_flags.md](feature_flags.md)).                                                                                                   |
| **Landing / marketing flow**  | Prefer editing `[boilerplate_landing_auth_redirect.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_landing_auth_redirect.dart)` and **public paths** over forking `**createRouteAccessRedirect`**. |


### High merge-churn — review on every upstream pull

When you `**git pull**` / merge from boilerplate `**main**`, **diff these intentionally** — upstream may add routes, flags, or redirect steps:


| File                                                                                                                                | Why                                                                      |
| ----------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| `[boilerplate_router.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_router.dart)`                               | Central **composition** of top-level routes + `**CoreGoRouterFactory`**. |
| `[boilerplate_redirect_provider.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_redirect_provider.dart)`         | Redirect **chain** order and providers.                                  |
| `[boilerplate_landing_auth_redirect.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/router/boilerplate_landing_auth_redirect.dart)` | Super-app landing behavior.                                              |
| `**pubspec.yaml`** (app + packages)                                                                                                 | New `**emp_ai_***` APIs or `**go_router**` constraints.                  |


**Practical git workflow:** keep product-specific edits in **focused commits** (e.g. “Our RBAC”, “Our shell nav”) so you can `**git merge`** upstream and resolve conflicts in those files without mixing them with unrelated changes. If you maintain a **long-lived fork**, consider a thin `**// CUSTOM:`** section in `boilerplate_router.dart` only if upstream documents a stable extension point — otherwise prefer **adding** routes via your own modules and **importing** them into the router file to minimize conflict surface.

### Contributing improvements upstream

Good candidates for `**emp_ai_core`** / `**emp_ai_app_shell**` PRs:

- **New generic helpers** (e.g. extra `**GoRouterRedirect` combinators**, safer prefix utilities) with **no product-specific paths**.
- **Tests** for `**CoreGoRouterFactory`** or `**createRouteAccessRedirect**` edge cases.
- **MiniApp shell** behavior that **multiple hosts** need (behind a flag or optional parameter).

Keep **out** of shared packages: your `**/orders`**, `**/main/hub/...**` strings, **Keycloak**-specific assumptions, and **Figma**-specific shell layout — those stay in the **host** or a **private** package.

**Auth:** bootstrap and **flavor catalog** stay host-specific; generic `**EmpAuth.initialize`** contracts or **token refresh** hooks belong in `**emp_ai_auth`** with a changelog and version bump.

### Shared navigation in `emp_ai_core` vs the host

**Already in `emp_ai_core`:** host-mode-aware `**GoRouter`** construction and **policy-driven** auth redirects.

**Usually stays in the host:** concrete `**GoRoute` trees**, **shell scaffolds**, **BoilerplateShellPaths**-style helpers (rename per product), and **landing** UX — they churn per brand and would bloat core with demo-only routes.

**New small package** (e.g. `**emp_ai_navigation`** or a private `**acme_host_shell**`): only when **several internal apps** share the **same** shell + path helpers; avoid putting that in `**emp_ai_core`** unless it is truly **org-wide** and stable.

---

## Quick reference: super-app URLs (default)


| Area                            | Example path                              |
| ------------------------------- | ----------------------------------------- |
| Landing (unauthenticated entry) | `/`                                       |
| Login                           | `/login`                                  |
| Main shell home                 | `/main/home`                              |
| Hub samples                     | `/main/hub/samples`                       |
| Standalone mini-app             | `/samples/demo`, `/announcements/home`, … |


**Standalone** mode drops the `**/main`** prefix for the shell (`**/home**`, …). **Embedded** mode prefixes with `**/<kEmbeddedPathPrefix>/`**.

---

## Further reading

- [shell_and_patterns.md](shell_and_patterns.md) — `**AppResult**`, design system, redirect overview.  
- [miniapps.md](../engineering/miniapps.md) — **codegen**, **feature flags**, **MiniAppGate**.  
- [miniapp_packages_and_extract.md](../engineering/miniapp_packages_and_extract.md) — **external repos**, registration API, **super-app vs standalone** route merge.  
- [getting_started.md — §6](../onboarding/getting_started.md#gs-6) — copy-paste examples (host mode, RBAC, custom redirect, deep links).  
- [platform/troubleshooting.md](../platform/troubleshooting.md) — deep links / platforms.

[← Docs home — integrations hub](../README.md#integrations-hub)