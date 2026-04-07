# Adopting the boilerplate for your product

Use this after you **clone or fork** [getting_started.md](getting_started.md) so the repo is clearly _yours_, not the template shell.

## Wire real auth (`emp_ai_auth`)

The sample [`login_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/screens/login_screen.dart) already uses **`EmpAuth().login`** when auth is configured, or a short **“not configured”** message when the flavor catalog / **`AUTH_*`** defines are missing — there is **no separate “demo login”** path to remove.

1. Configure **`emp_ai_auth`** — default: [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart); optional define-only bootstrap: **`AUTH_*`** when **`AUTH_CLIENT_ID`** is set — see [`emp_ai_auth_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart) and [`boilerplate_auth_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_auth_config.dart).
2. Fill [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart) (or use **`AUTH_*`** only) per [environment](../integrations/environment.md) / [README — hub](../README.md#integrations-hub).
3. Keep `emp_ai_auth` in `pubspec.yaml` unless you are **replacing** the entire IdP stack — then remove the dependency and swap `auth/` session + bootstrap wiring for your SDK (see [auth](../integrations/auth.md)).

## Remove or shrink template-only UI

| Goal | What to change |
|------|----------------|
| **Hide the Samples mini-app** | Set `samplesMiniAppEnabled: false` in [`BoilerplateFeatureFlags`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart) or remove `SamplesMiniApp` from [`miniapps_registry.yaml`](../../apps/emp_ai_boilerplate_app/miniapps_registry.yaml), then `dart run melos run generate:miniapps`. |
| **Template RBAC / route rules** | Replace rules in [`boilerplate_route_access.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart) and align `AuthSnapshot` roles/permissions with your IdP. |

## Rename and ship

Follow [getting_started.md](getting_started.md) (product name, bundle ids, **§3** catalog, **§4** platforms).

## HTTP: from samples to a real API

If you are porting patterns from another internal app, map **remote calls** to the same **clean-architecture** slots used here: **data source** → **repository** → **notifier** (or **`cached_query`** where appropriate), with **`Dio`** from `boilerplateDioProvider` ([`boilerplate_api_client.dart`](../../apps/emp_ai_boilerplate_app/lib/src/network/boilerplate_api_client.dart)).

- **Fake / offline:** default `SamplesRemoteDataSourceImpl` (in-memory string).
- **Real GET:** enable `--dart-define=SAMPLES_HTTP_DEMO=true` to use [`SamplesRemoteDataSourceHttp`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/samples/data/datasources/samples_remote_datasource_http.dart) against a public JSON endpoint (swap the URL for your API path when ready).

## Related docs

- [README.md](../README.md#integrations-hub) — integrations hub (auth, flags, network, analytics).
- [dart_defines.md](../platform/dart_defines.md) — `FLAVOR` + toggles; [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json).
- [ci_cd.md](../platform/ci_cd.md) — Bitbucket / Bitrise / web + mobile.
- [engineering/contributing.md — Adding SDKs](../engineering/contributing.md#adding-sdks-and-integrations) — new vendor SDKs.
- [miniapps.md](../engineering/miniapps.md) — new mini-apps and registry.
