# Environment: flavor catalog, host profile, defines

**Single source of truth** for API / IdP hosts per build flavor, optional **`API_BASE_URL`** / **`AUTH_*`** overrides, and CI define patterns.

**Auth bootstrap & login flow:** [auth.md](auth.md). **Toggles** (`FLAVOR`, `VERBOSE_LOGS`, …): [../platform/dart_defines.md](../platform/dart_defines.md).

<a id="flavor-catalog-emapta-style"></a>

## Flavor catalog (emapta-style env)

**Template defaults:** values in [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart) are **placeholders** so a fresh clone builds. After you **fork or clone** into your product repo, **re-populate** every flavor row (API, identity, titles, mobile/web OAuth client ids and redirects) for your environments. See [getting_started.md](../onboarding/getting_started.md) — **Replace template environment values**.

The host mirrors **`emapta/lib/src/main/app_env.dart`** + **`EnvInfo.initialize(environment)`**:

| emapta                                                                | ecosystem boilerplate                                                                                                                                                                                               |
| --------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AppEnvironment` enum + maps per env                                  | [`AppBuildFlavor`](../../packages/emp_ai_core/lib/src/environment/app_build_flavor.dart) + [`BoilerplateEnvironmentCatalog`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart) |
| `main_dev.dart` / `main_prod.dart` → `mainCommon(AppEnvironment.xxx)` | Single entrypoint; flavor from **`--dart-define=FLAVOR`** (`development`, `staging`, `prod`, …) via [`AppBuildFlavorParser`](../../packages/emp_ai_core/lib/src/environment/app_build_flavor.dart)                  |
| `EnvInfo` getters for API, identity, titles                           | [`BoilerplateFlavorEndpoints`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart): `apiBaseUrl`, `identityBaseUrl`, app title, mobile/web client ids + redirects                |

**Wiring**

- **[`application_host_profile_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/application_host_profile_provider.dart)** — `flavorId` + `apiBaseUrl` from catalog; non-empty **`API_BASE_URL`** define **overrides** only the API base (typical for CI).
- **[`boilerplateDisplayTitleProvider`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_flavor_providers.dart)** — [`MaterialApp.title`](../../apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_app.dart).
- **[`emp_ai_auth_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart)** — when **`AUTH_CLIENT_ID`** is unset, uses the catalog for Keycloak URLs + client id + redirect (**mobile vs web** via `kIsWeb`); when set, uses **`AUTH_*`** defines only ([advanced](#auth-dart-defines-advanced)).

Treat the committed catalog as a **starting point** only; replace it entirely for your product. Keep **secrets** out of the catalog.

**Optional:** add `lib/main_staging.dart` that only calls `main()` after a **wrapper** exporting a different default `FLAVOR` is **not** how Dart defines work — instead use **`--target`** with a tiny `main_prod.dart` that sets nothing (defines come from CI) or duplicate `main` with the same code; emapta uses **`flutter build ios --target lib/src/main/main_$FLAVOR.dart`** so each file calls `mainCommon(AppEnvironment.xxx)` **without** relying on `FLAVOR` define. You can do the same here by reading a **const** flavor in that entrypoint and passing it into a shared `void runBoilerplate(AppBuildFlavor flavor)` if you want **zero** `FLAVOR` define on iOS flavors.

<a id="host-profile-overrides-api-url-verbose-logs"></a>

## Host profile overrides (API URL, verbose logs)

**Source of truth for API / IdP hosts:** [`boilerplate_environment_catalog.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/boilerplate_environment_catalog.dart), selected by **`--dart-define=FLAVOR`**.

- **`VERBOSE_LOGS`** — `bool.fromEnvironment` — see [dart_defines.md](../platform/dart_defines.md).
- **`API_BASE_URL`** (optional advanced override) — when **non-empty**, overrides **only** the catalog’s REST API base ([`application_host_profile_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/application_host_profile_provider.dart)). Use for CI pointing at a specific API; normal product URLs stay in the catalog.

Extra options (white-label, one-off):

1. **Override `applicationHostProfileProvider`** in **`ProviderScope`** ([`boilerplate_startup_overrides.dart`](../../apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_startup_overrides.dart)).
2. **IDE / define file** — e.g.:

   ```text
   --dart-define=FLAVOR=staging --dart-define=API_BASE_URL=https://custom.example.com
   ```

   ```bash
   flutter run --dart-define-from-file=config/build_defines.json
   ```

<a id="auth-dart-defines-advanced"></a>

## Advanced: `AUTH_*` `--dart-define`s (optional)

**Default path:** leave **`AUTH_CLIENT_ID`** unset — [`emp_ai_auth_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart) uses the **[flavor catalog](#flavor-catalog-emapta-style)** for Keycloak URLs and client id.

**Define-only bootstrap** (rare): if **`AUTH_CLIENT_ID`** is **non-empty**, bootstrap reads **only** defines for that init (not the catalog): **`AUTH_CLIENT_SECRET`**, **`AUTH_KC_AUTHENTICATION_URL`**, **`AUTH_KC_AUTHORIZATION_URL`**, **`AUTH_KC_USER_URL`**, optional **`AUTH_REDIRECT_URL`**, **`AUTH_LOGOUT_URL`**. Implementations: [`emp_ai_auth_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart). Prefer the catalog for a single matrix unless CI forces define-only auth.

## CI/CD: Bitbucket / GitHub Actions — `.env` vs `--dart-define`

**Step-by-step for Bitbucket / Bitrise / web + mobile (emapta-style):** [../platform/ci_cd.md](../platform/ci_cd.md).

**Many keys at once:** copy [`build_defines.example.json`](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json) to **`config/build_defines.json`** (gitignored), fill values, then `flutter run --dart-define-from-file=config/build_defines.json` from the app directory. Most teams **do not** commit secrets; CI generates the JSON from vault variables.

**Common patterns (mobile + web)**

1. **Pipeline secured variables** (Bitbucket repository variables, GitHub Actions secrets) → a step writes `setenv.sh` or exports vars → build script runs:

   ```bash
   flutter build apk --release --dart-define-from-file=build_defines.ci.json
   ```

   (Or a few flags: `flutter build apk --release --dart-define=FLAVOR=production`. Add **`API_BASE_URL`** / **`AUTH_*`** only for [advanced overrides](#host-profile-overrides-api-url-verbose-logs) / [define-only auth](#auth-dart-defines-advanced).)

   Your **emapta** repo uses this style: **`setenv.sh`** artifacts and **`source setenv.sh`** before Flutter (`bitbucket-pipelines.yml`), then iOS may use **`flutter build ios --flavor $FLAVOR --target lib/src/main/main_$FLAVOR.dart`** (see `emapta/.bitbucket/scripts/build_ipa.sh` in the main app repo).

2. **`--dart-define-from-file=`** — CI or local dev uses one JSON file (see [`build_defines.example.json`](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json)); generate it from secured variables in a **masked** step, then pass it to `flutter build` / `flutter run` (Flutter 3.16+).

**Recommendation:** keep **API and IdP URLs** in the **[flavor catalog](#flavor-catalog-emapta-style)**. Use **`API_BASE_URL`** / **`AUTH_*`** defines only for CI overrides or [advanced auth](#auth-dart-defines-advanced); keep secrets in the vault and inject at build time.

**Web:** same `flutter build web --dart-define=...`; hosting (Firebase, S3) does not replace Flutter compile-time defines — they must be present at **`build`** time.

**Local `flutter run` without `AUTH_*`:** edit the **[flavor catalog](#flavor-catalog-emapta-style)** row for your environment (client ids, identity base URL, redirects). For many keys or CI-only secrets, use **`--dart-define-from-file`** ([above](#host-profile-overrides-api-url-verbose-logs)) or [define-only auth](#auth-dart-defines-advanced).

## Host profile (`ApplicationHostProfile`) — summary

- Contract: **`emp_ai_foundation`** — `flavorId`, optional `apiBaseUrl`, `enableVerboseLogs`.
- Default: **[flavor catalog](#flavor-catalog-emapta-style)** + optional **`API_BASE_URL`** / **`VERBOSE_LOGS`** defines ([`application_host_profile_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/config/application_host_profile_provider.dart)).
- Override: **`applicationHostProfileProvider`** or **`ProviderScope` overrides**.

---

[← Docs home — integrations hub](../README.md#integrations-hub)
