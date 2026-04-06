# Super-app shell & main shell (Northstar)

How the boilerplate layers **outer** super-app chrome (mini-app branches) and **inner** product chrome (Overview, Components, Hub, …), how to **navigate** between them, and how to **customize** behavior.

**Related:** [miniapps.md](miniapps.md), [navigation.md](../integrations/navigation.md) (routes, `go` / `push`, redirects), [shell_and_patterns.md](../integrations/shell_and_patterns.md), host config in `apps/emp_ai_boilerplate_app/lib/src/config/host_mode.dart`.

## Two layers (mental model)

| Layer | Responsibility | Primary files |
|--------|----------------|---------------|
| **Super-app shell** | Hosts one `StatefulNavigationShell` branch per registered `MiniApp` (main shell, announcements, resources, samples, …). Can show an **Apps** rail + (on narrow) a bottom bar **or** hide that chrome entirely. | `packages/emp_ai_app_shell/lib/src/super_app_stateful_shell_scaffold.dart`, `mini_app_route_factory.dart` |
| **Main shell (Northstar)** | Inside the **main** mini-app only: left nav / drawer / bottom bar driven by **`boilerplateShellNavConfigProvider`** (`boilerplate_shell_nav_config.dart`); narrow **segmented** sibling switch in **`WideHubSplit`** reads the same config. | **`boilerplate_shell_nav_config.dart`**, `boilerplate_shell_scaffold.dart`, `boilerplate_shell_routes.dart`, `wide_hub_split.dart` |

Routes still live under each mini-app’s prefix, e.g. `/main/home`, `/main/hub/samples`, `/announcements/home`, `/samples/demo`.

### Wide layout (breakpoint ≥ `kSuperAppShellWideBreakpoint`)

The **side rail** runs **full height** (within `SafeArea`). The **strip with the page title** (Overview, Components, …) sits only in the **content column** to the right of the rail — it does **not** span above the rail. Narrow layouts use `AppBar` / bottom nav or drawer instead.

## Flags in `host_mode.dart`

- **`kBoilerplateHostMode`** — `superApp` vs `standaloneMiniApp` vs `embeddedMiniApp` (path prefix for embedded).
- **`kSuperAppUseStatefulShell`** — `true`: `StatefulShellRoute.indexedStack` so each mini-app keeps its own stack. `false`: flat `GoRoute` list from `MiniAppRouteFactory.buildTree` (no indexed shell).
- **`kSuperAppShowMiniAppRail`** — `false` (**default in boilerplate**): hides the outer **Apps** rail and the mini-app **bottom** `NavigationBar`. Users rely on **main shell + Hub** (and deep links) instead of switching tabs on the far left. Set to `true` to restore the classic multi-column “Apps” UI.

Wiring: `boilerplate_router.dart` passes `showMiniAppRail: kSuperAppShowMiniAppRail` into `MiniAppRouteFactory.buildTreeWithStatefulShell`.

**Narrow layout note:** When the outer rail is hidden, `BoilerplateShellScaffold` can use its own bottom `NavigationBar` for Overview / Components / Look & feel / Hub (see `avoidBottomBarStack` in `boilerplate_shell_scaffold.dart`).

## Navigating in code

Use **`GoRouter`** (or `context.go` / `context.push`) with stable paths from **`BoilerplateShellPaths`** (`boilerplate_shell_paths.dart`):

- Main shell: `BoilerplateShellPaths.home`, `.widgets`, `.theme`, `.hubSamples`, `.hubResources`, `.hubAnnouncements`, `.widgetDetail(id)`, `.designSystemShowcase`
- Paths adapt to host mode (`/main/...` in super-app, `/...` in standalone, `/demo/...` embedded).

**Hub (embedded mini-apps inside main shell):** `/main/hub` redirects to `/main/hub/samples`; sub-routes `hub/resources`, `hub/announcements` show the same screens as the standalone mini-apps but inside `WideHubSplit`.

**Direct mini-app URLs (no Hub):** e.g. `context.go('/announcements/home')`, `context.go('/samples/demo')` — still valid; `StatefulNavigationShell` switches branch when the location matches another mini-app.

## Customizing the main shell (inner nav)

1. **Menu order, labels, icons, grouping** — Edit or replace **`[boilerplate_shell_nav_config.dart](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_nav_config.dart)`**: adjust **`defaultBoilerplateShellNavItems()`**, or override **`boilerplateShellNavConfigProvider`** (e.g. in `ProviderScope`) to return your own `List<ShellNavItem>`. Use **`ShellNavTopLeaf`** for a single destination; use **`ShellNavTopParent`** + **`ShellNavLeaf`** children for a folder. **Parent rows never navigate** — they only expand/collapse (wide rail / drawer) or open the drawer (mobile bottom bar); **`go()` runs only for leaves**.
2. **Routes** — Still extend **`boilerplate_shell_routes.dart`** and **`BoilerplateShellPaths`** so every **`ShellNavLeaf.location`** matches a real **`GoRoute`**.
3. **Default home cards** — Edit [`MainShellHomeScreen`](../../apps/emp_ai_boilerplate_app/lib/src/screens/main_shell_home_screen.dart) (teams often replace this with a product landing page).
4. **Narrow Hub-style segments** — Labels and targets come from the **`ShellNavParent`** that owns the current path (**`shellNavParentOwningPath`**). To change breakpoint width, edit **`WideHubSplit.breakpointWidth`** in [`wide_hub_split.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/wide_hub_split.dart) (segment **content** stays config-driven).
5. **Chrome only** — Gradient header, “Starter shell” copy, hover rail width, footer tip: [`boilerplate_shell_scaffold.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/navigation/boilerplate_shell_scaffold.dart).

**Details and tables:** [navigation.md](../integrations/navigation.md) → file map + **Main shell side navigation (configurable)**.

## Customizing the super-app shell (package)

- **Toggle outer chrome** — Prefer `kSuperAppShowMiniAppRail` in the host; do not fork unless you need different layout rules.
- **Change scaffold behavior** — `SuperAppStatefulShellScaffold` in `emp_ai_app_shell`; optional `showMiniAppRail` parameter (defaults to `true` for other consumers).

## Troubleshooting

- **Overflow in the side nav** — On hover, rail **width animates** (72→280) while `expanded` is `true` immediately; labels, gradient header, and footer tip only render once rail width ≥ **`_kMinWidthForExpandedLabels`** (~184px) so `_SideNavTile` rows never run in a too-narrow rail. `_SideNavTile` uses `ClipRect` + `TextOverflow.ellipsis` for the label row.
- **Double app bars** — Hub embeds full mini-app screens that may include their own `AppBar`; consider an `embedInShell`-style flag on those screens later if you want a single bar.
