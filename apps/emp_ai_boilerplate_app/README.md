# emp_ai_boilerplate_app

Host app for the ecosystem workspace: super-app shell, mini-apps, Northstar theming, Dio, and optional `emp_ai_auth`.

See **[ecosystem_boilerplate/README.md](../../README.md)** for Melos commands, registry generation, and CI.

**Orientation:** open **[`lib/src/README.md`](lib/src/README.md)** first, then the canonical **[`docs/engineering/host_structure.md`](../../docs/engineering/host_structure.md)** for the full diagram and rules.

**Notable paths**

- `lib/src/config/host_mode.dart` — `AppHostMode`, `kSuperAppUseStatefulShell`
- `lib/src/shell/` — auth, `GoRouter`, shell scaffold, hub, deep links ([`shell/README.md`](lib/src/shell/README.md))
- `lib/src/platform/` — feature flags, analytics, notifications, `MiniAppGate`, Firebase bootstrap ([`platform/README.md`](lib/src/platform/README.md))
- `lib/src/miniapps/` — product mini-apps; `miniapp_host_catalog.dart` → **`kHostMiniAppsCatalog`** (codegen `kAllMiniApps` + external / WebView)
- `lib/src/miniapps/samples/` — clean architecture example (domain / data / presentation)

**Layout guide:** [docs/engineering/host_structure.md](../../docs/engineering/host_structure.md)
