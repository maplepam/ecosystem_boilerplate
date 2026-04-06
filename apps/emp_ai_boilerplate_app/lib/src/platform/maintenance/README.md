# Maintenance mode (placeholder)

Add here when you need a **global** maintenance experience:

- A small **domain** contract (e.g. `MaintenanceModePort` / `Future<bool> shouldBlockApp>`).
- A **data** implementation that calls your ops API or reads remote config.
- **Presentation**: full-screen or banner widget; wire a redirect in `boilerplateCustomRedirectProvider` (see [navigation.md](../../../../../../docs/integrations/navigation.md)) **before** auth/RBAC so users see a clear message.

Keep product mini-app code out of this folder; only **host-level** policy belongs in `platform/maintenance/`.
