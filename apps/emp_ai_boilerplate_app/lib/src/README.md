# `lib/src` — start here

This folder is the **host app** source. Roles are split so a super-app can grow without one giant tree:

| Area | Path | In one sentence |
|------|------|----------------|
| **Bootstrap** | `app/`, `config/` | `runApp`, flavors, RBAC tables |
| **Frame** | `shell/` | Router, scaffold, hub, auth, deep links; main-shell **menu** in `shell/navigation/boilerplate_shell_nav_config.dart` |
| **Host services** | `platform/` | Flags, analytics, push, mini-app gate |
| **Products** | `miniapps/` | Leave, T&A, announcements, …; merge list **`kHostMiniAppsCatalog`** in `miniapp_host_catalog.dart` |
| **Shared adapters** | `integrations/`, `network/` | Reused HTTP/SDK glue, host `Dio` |
| **Misc glue** | `providers/`, `screens/`, `theme/` | Prefs, login/landing, theming |

**Read order:** **[`docs/engineering/README.md`](../../../../docs/engineering/README.md)** (four links) → **[`docs/engineering/host_structure.md`](../../../../docs/engineering/host_structure.md)** (full diagram + tables).
