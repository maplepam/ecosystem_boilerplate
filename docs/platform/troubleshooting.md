# Troubleshooting

Common issues when cloning, bootstrapping, or running **`emp_ai_boilerplate_app`**. Onboarding narrative: [getting_started.md](../onboarding/getting_started.md).

## `melos bootstrap` / `emp_ai_auth` clone fails

- **`emp_ai_auth`** is filled by a **pre-hook** that clones from Git. Private Bitbucket (or similar) needs **credentials** on the machine running bootstrap (SSH agent, HTTPS + app password, or CI secret). See [integrations/emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md).
- After fixing Git access, run **`dart run melos bootstrap`** again from the repo root.

## `generate:miniapps` / missing routes / hub empty

- Any change to **`miniapps_registry.yaml`** requires:

  ```bash
  dart run melos run generate:miniapps
  ```

- CI runs the generator explicitly so drift is caught; see [ci_cd.md](ci_cd.md#github-actions-in-this-repo).

## `build_defines.json` / defines ignored

- Boolean keys must be the strings **`"true"`** or **`"false"`** (not raw JSON booleans) for **`--dart-define-from-file`**. See [dart_defines.md](dart_defines.md).
- Run **`flutter run`** from **`apps/emp_ai_boilerplate_app`** when using a relative path to **`config/build_defines.json`**.

## Firebase / analytics not showing events

- **`ENABLE_FIREBASE=true`** alone is not enough: you need **`Firebase.initializeApp()`** to succeed (FlutterFire / **`google-services.json`** / **`GoogleService-Info.plist`** / **`firebase_options.dart`**). If init fails, **`Firebase.apps`** stays empty and the Firebase sink is skipped. See [integrations/analytics_firebase.md](../integrations/analytics_firebase.md).
- **Mixpanel** only needs a non-empty **`MIXPANEL_TOKEN`** — [integrations/analytics_mixpanel.md](../integrations/analytics_mixpanel.md).

## Web + OAuth / CORS

- With **`empAiAuth`**, the IdP must allow your **redirect URI** and **CORS** for your dev origin (e.g. `localhost` and port). Details: [getting_started.md §4 Web](../onboarding/getting_started.md#gs-4).

## Deep links not navigating

- **`kBoilerplateEnableAppLinks`** in **`boilerplate_auth_config.dart`** must be **`true`** (default in the sample).
- **`mapAppLinkToLocation`** may need customization for your scheme/host. Examples: **`test/deep_link_mapping_test.dart`** in the app package; onboarding §6f: [getting_started.md](../onboarding/getting_started.md#gs-6) (subsection **6f**).

## Analyze / test failures only in CI

- Ensure **`dart run melos bootstrap`** and **`dart run melos run generate:miniapps`** ran locally the same way as CI (see [ci_cd.md](ci_cd.md)).
