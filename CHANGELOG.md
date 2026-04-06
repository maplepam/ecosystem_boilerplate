# Changelog

All notable changes to this **monorepo** are recorded here. It is the **single** changelog for the workspace (packages under `packages/` and the host app under `apps/`). Individual packages may add their own `CHANGELOG.md` only if you **publish** them separately to pub.

The format is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- Root **landing** route (`/`), **protected** main dashboard and mini-apps; unauthenticated users are sent to the landing page with an optional `continue` query, then **Sign in** uses **emp_ai_auth** (emapta-style) by default.
- **Announcements** mini-app (`/announcements`) and **Resources** mini-app (`/resources`) as emapta-shaped examples.
- Full **announcements** slice: layered folders (`domain/entities`, `presentation/di`, `presentation/notifiers`, `screens`, `widgets`); **per-network-call** notifiers (list load, detail load family, mark-read); **POST** to emapta **announcement-bl** V2 (`/announcement/published/list`, `/announcement/published/detail`) via host `Dio`, base URL from flavor `announcementServiceBaseUrl` or `ANNOUNCEMENT_SERVICE_BASE_URL`; **SharedPreferences** read-state; DS catalog widgets: `NorthstarSearchField`, `NorthstarFilterChipStrip`, `NorthstarTriStateBody`. See [announcements_miniapp_layout.md](docs/engineering/announcements_miniapp_layout.md).
- Widget tests use **`boilerplateAuthenticatedTestOverrides()`** ([`test/support/boilerplate_auth_test_overrides.dart`](apps/emp_ai_boilerplate_app/test/support/boilerplate_auth_test_overrides.dart)) instead of a separate demo auth backend.

### Changed

- Host **`boilerplateDioProvider`**: removed **proactive** pre-request refresh interceptor so **navigation** does not wait on the token endpoint; **`BoilerplateAuthHeaderInterceptor`** + **`TokenRefreshInterceptor`** (401 → refresh + retry) only. See [network.md](docs/integrations/network.md).
- Removed **`emp_ai_auth_local_dev_wiring.dart`**; auth bootstrap uses only **`AUTH_*`** defines (when **`AUTH_CLIENT_ID`** is set) or the **[flavor catalog](apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)**. Docs: [environment.md](docs/integrations/environment.md), [auth.md](docs/integrations/auth.md).
- Token refresh wiring: **`emp_ai_auth_token_refresh_providers.dart`** exposes **`empAiAuthTokenRefreshAdapterProvider`**, **`coreTokenRefreshServiceProvider`**, **`empAiAuthTokenRefreshInterceptorProvider`**; removed unused **`BoilerplateTokenRefreshService`** / **`boilerplateTokenRefreshServiceProvider`** (no callers). **`authSessionReaderProvider`** is defined next to **`EmpAiAuthSessionReader`** in **`emp_ai_auth_session_reader.dart`** (deleted **`auth_session_reader_provider.dart`**).
- Official host Dio: **`boilerplate_api_client.dart`** / **`boilerplateDioProvider`** (renamed from demo): bearer header + **`TokenRefreshInterceptor`** for **401** refresh + retry (see newer **Changed** note on proactive removal above).
- **Announcements** list/detail use **`cached_query`** (`InfiniteQuery` on mobile, paged `Query` on web, per-id detail `Query`); explicit **`cached_query`** dependency; pagination (infinite scroll vs page size + prev/next); repository methods renamed to **`loadPublishedAnnouncementsPage`** / **`loadPublishedAnnouncementById`**.
- **Announcements** UI text/surfaces prefer **`emp_ai_ds_northstar`** (`NorthstarTextRole`, `NorthstarColorTokens`).
- **`emp_ai_ds_widgets`** widget catalog: searchable **Northstar typography (text roles)** panel (`NorthstarTypographyCatalogPanel`).

- **`/samples` is public** (no sign-in, no `read:samples` route gate); landing redirect allowlist includes `/samples`. Example **`AuthSnapshot`** permissions (e.g. `read:samples`) remain documented for in-app gates.
- Default auth backend is **`empAiAuth`** (was `demo`); use **[flavor catalog](apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)** or optional **`AUTH_*`** defines for Keycloak ([environment.md](docs/integrations/environment.md)).
- Super-app **hub** moved from `/` to **`/hub`** (authenticated).

### Migration

- Run `dart run melos run generate:miniapps` after pulling.
- Local **web** dev with Keycloak: set **`redirectUrlWeb`** / **`authClientIdWeb`** (and identity base) in the flavor catalog for your environment, or pass matching **`AUTH_*`** defines / define file for your origin.
- **Widget / integration tests**: use `boilerplateAuthenticatedTestOverrides()` when the flow must behave as signed-in without Keycloak (`melos run test:boilerplate` / CI run plain `flutter test`).
