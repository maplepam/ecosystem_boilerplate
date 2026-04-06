# `shell/` — router, scaffold, auth, deep links

The super-app **frame** shared by all mini-apps: `GoRouter`, shell UI, hub, `emp_ai_auth` wiring, app links.

**Main-shell menu (side rail / drawer / bottom bar / narrow Hub segments):** [`navigation/boilerplate_shell_nav_config.dart`](navigation/boilerplate_shell_nav_config.dart) — list of **`ShellNavTopLeaf`** / **`ShellNavTopParent`** entries; override **`boilerplateShellNavConfigProvider`** to customize. Parents **expand/collapse only**; **`ShellNavLeaf.location`** must match real `GoRouter` paths (use **`boilerplate_shell_paths.dart`**).

**`navigation/` layout**

| Kind                    | Files                                                                                                                                                  |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Config + resolution** | `boilerplate_shell_nav_config.dart`, `boilerplate_shell_paths.dart`, `boilerplate_widget_catalog.dart`, `boilerplate_host_widget_catalog_entries.dart` |
| **Shell state (no UI)** | `shell_nav_expansion.dart` — parent open/closed coordination for the scaffold                                                                          |
| **Small helpers**       | `shell_nav_bottom_destinations.dart`, `wide_hub_split.dart`, `wide_widget_catalog_split.dart`                                                          |
| **Reusable shell UI**   | `navigation/widgets/` — `ShellWebSideNav`, `ShellSideNavTile`, `ShellNavRailBranding`, `ShellMobileDrawerNav`, `ShellDrawerParentSection`              |
| **Screen assembly**     | `boilerplate_shell_scaffold.dart` — wires Riverpod, `GoRouter`, and the widgets above                                                                  |

Shared **design-system** widgets stay in **`emp_ai_ds_widgets`**; host-only chrome used by the shell lives here so the catalog can reference the same implementations.

**Full map + diagram:** [`docs/engineering/host_structure.md`](../../../../../docs/engineering/host_structure.md) · **Routes + config how-to:** [`docs/integrations/navigation.md`](../../../../../docs/integrations/navigation.md)
