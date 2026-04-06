# `--dart-define` keys (host toggles & flavor)

This page lists **only** compile-time flags that are **not** your product’s API / IdP matrix. **Single source of truth for hosts, OAuth client ids, and redirects:** [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart) — selected by **`FLAVOR`**.

Pass flags at **`flutter run`**, **`flutter build`**, or **`--dart-define-from-file=`** (template: [`build_defines.example.json`](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json)).

```bash
flutter run --dart-define=FLAVOR=staging --dart-define=VERBOSE_LOGS=true
```

**Optional overrides** (`API_BASE_URL`, full **`AUTH_*`** set for define-only bootstrap) are **advanced** and documented in [integrations/environment.md](../integrations/environment.md) — **Host profile overrides** and **AUTH bootstrap** — so env config stays in one narrative.

---

## `FLAVOR` (select catalog row)

| Key | Type | Default | Role |
|-----|------|---------|------|
| **`FLAVOR`** | string | `development` | Maps to [`AppBuildFlavor`](../../packages/emp_ai_core/lib/src/environment/app_build_flavor.dart) and thus **[`BoilerplateEnvironmentCatalog`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)** (`dev`, `qa`, `staging`, `prod`, …). |

---

## Logging

| Key | Type | Default | Role |
|-----|------|---------|------|
| **`VERBOSE_LOGS`** | bool | `false` | Verbose logging / debug analytics ([`application_host_profile_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/application_host_profile_provider.dart)). |

---

## Samples / demos

| Key | Type | Default | Role |
|-----|------|---------|------|
| **`SAMPLES_CACHED_QUERY`** | bool | `false` | Samples welcome uses **`cached_query`** ([`boilerplate_experimental_flags.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_experimental_flags.dart)). |
| **`SAMPLES_HTTP_DEMO`** | bool | `false` | Real **`Dio.get`** for Samples ([`SamplesRemoteDataSourceHttp`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/samples/data/datasources/samples_remote_datasource_http.dart)). |

---

## Optional services (host)

| Key | Type | Default | Role |
|-----|------|---------|------|
| **`ENABLE_FIREBASE`** | bool | `false` | Firebase init + analytics ([../integrations/analytics_firebase.md](../integrations/analytics_firebase.md)). |
| **`MIXPANEL_TOKEN`** | string | `''` | Non-empty → Mixpanel ([../integrations/analytics_mixpanel.md](../integrations/analytics_mixpanel.md)). |
| **`ENABLE_LOCAL_NOTIFICATIONS`** | bool | `false` | Local notification port. |
| **`ENABLE_FCM`** | bool | `false` | FCM push (needs Firebase). |
| **`MINIAPPS_REGISTRY_URL`** | string | `''` | Non-empty → **HTTP** `GET` for remote mini-app allow-list ([`miniapps_registry_providers.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/miniapps_registry/di/miniapps_registry_providers.dart), shape in [`docs/fixtures/miniapps_registry.json`](../fixtures/miniapps_registry.json)). Empty → **stub** (no network). |
| **`MINIAPPS_REGISTRY_USE_STUB`** | bool | `false` | `true` → always use stub registry (tests / offline CI) even if **`MINIAPPS_REGISTRY_URL`** is set. |

---

## Not `dart-define`

- **API base URL, identity URLs, client ids, redirects, titles** — **[flavor catalog](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart)** (plus optional **`API_BASE_URL`** / **`AUTH_*`** overrides — [integrations/environment.md](../integrations/environment.md)).
- **Feature flags** — [`BoilerplateFeatureFlags`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart) defaults / providers.
- **`kBoilerplateEnableAppLinks`** — [`boilerplate_auth_config.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_auth_config.dart) (deep links; auth is always `emp_ai_auth`).

---

## Related

- [README.md](../README.md#integrations-hub) — integrations hub; **catalog / defines:** [integrations/environment.md](../integrations/environment.md).
- [ci_cd.md](ci_cd.md) — Bitbucket / Bitrise, **`build_defines.json`**.
