# Adopting the boilerplate for your product

Use this after you **clone or fork** [getting_started.md](getting_started.md) so the repo is clearly _yours_, not the demo shell.

## Replace “demo” auth with real sign-in

1. Configure **`emp_ai_auth`** — default: [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart); optional define-only bootstrap: **`AUTH_*`** when **`AUTH_CLIENT_ID`** is set — see [`emp_ai_auth_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart) and [`boilerplate_auth_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_auth_config.dart).
2. Fill [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart) (or use **`AUTH_*`** only) per [environment](../integrations/environment.md) / [README — hub](../README.md#integrations-hub).
3. Keep `emp_ai_auth` in `pubspec.yaml` unless you are **replacing** the entire IdP stack — then remove the dependency and swap `auth/` session + bootstrap wiring for your SDK (see [auth](../integrations/auth.md)).

## Remove or shrink demo-only UI

| Goal                     | What to change                                                                                                                                                                                                                                                                                                                                       |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hide the Samples tab** | Set `samplesMiniAppEnabled: false` in [`BoilerplateFeatureFlags`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart) or remove `SamplesMiniApp` from the catalog in [`miniapps_registry.yaml`](../../apps/emp_ai_boilerplate_app/miniapps_registry.yaml), then `dart run melos run generate:miniapps`. |
| **Drop demo login**      | After switching to `empAiAuth`, users use real `EmpAuth().login`; remove copy-only flows in [`login_screen.dart`](../../apps/emp_ai_boilerplate_app/lib/src/screens/login_screen.dart) if you no longer need them.                                                                                                                                   |
| **Demo RBAC claims**     | Replace rules in [`boilerplate_route_access.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_route_access.dart) and align `AuthSnapshot` roles/permissions with your IdP.                                                                                                                                                         |

## Rename and ship

Follow [getting_started.md](getting_started.md) (product name, bundle ids, **§3** catalog, **§4** platforms).

## HTTP parity with the main **emapta** app

The **emapta** codebase often uses `NetworkService.get` + `EnvInfo` base URLs (see `FetchDomainDataSourceImpl` in `lib/src/core/services/fetch_domain_service/data/datasource/fetch_domain_datasource.dart` in the emapta repo). In this boilerplate, the same **clean-architecture** slot is `SamplesRemoteDataSource` → **repository** → **notifier** (or **`cached_query`** in other mini-apps); the transport is `Dio` from `boilerplateDioProvider` ([`boilerplate_api_client.dart`](../../apps/emp_ai_boilerplate_app/lib/src/network/boilerplate_api_client.dart)).

- **Fake / offline:** default `SamplesRemoteDataSourceImpl` (in-memory string).
- **Real GET:** enable `--dart-define=SAMPLES_HTTP_DEMO=true` to use [`SamplesRemoteDataSourceHttp`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/samples/data/datasources/samples_remote_datasource_http.dart) against a public JSON endpoint (swap the URL for your API path when ready).

## Related docs

- [README.md](../README.md#integrations-hub) — integrations hub (auth, flags, network, analytics).
- [dart_defines.md](../platform/dart_defines.md) — `FLAVOR` + toggles; [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json).
- [ci_cd.md](../platform/ci_cd.md) — Bitbucket / Bitrise / web + mobile.
- [integrations/extending_tooling.md](../integrations/extending_tooling.md) — adding a new SDK or vendor.
- [miniapps.md](../engineering/miniapps.md) — new mini-apps and registry.
