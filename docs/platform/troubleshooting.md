# Troubleshooting

Common issues when cloning, bootstrapping, or running **`emp_ai_boilerplate_app`**. **“Which doc should I read?”** → [faq.md](../onboarding/faq.md). Full onboarding: [getting_started.md](../onboarding/getting_started.md).

## `melos bootstrap` / `flutter pub get` fails (submodules / path deps)

- **Initialize submodules first:** **`git submodule update --init --recursive`** (or clone with **`--recurse-submodules`**). Empty **`packages/ecosystem-platform`** (or auth/DS) breaks **`path:`** resolution in the host app.
- Submodules use **SSH** URLs by default (**GitHub** + **Bitbucket**). Configure **`ssh-agent`** (or switch **`.gitmodules`** to HTTPS + credentials). See [integrations/emp_ai_auth_dependency.md](../integrations/emp_ai_auth_dependency.md) and [ci_cd.md](ci_cd.md#github-actions-in-this-repo).
- After fixing access, run **`dart run melos bootstrap`** again from the repo root.

## Analyzer: red squiggles under `packages/ecosystem-platform` (or auth / DS)

The boilerplate root **`analysis_options.yaml`** **excludes** **`packages/ecosystem-platform/**`**, **`packages/emp_ai_auth/**`**, and **`packages/emp_ai_ds/**`**. Those trees are separate repos; they are not **`pub get`**’d as part of this workspace’s Melos scope, so analyzing them from the parent project produces false **“Target of URI doesn’t exist”** errors.

- To work on **platform** code: **`cd packages/ecosystem-platform && dart run melos bootstrap`**, then analyze there or open that folder as its own IDE window.
- To verify the **host app** only: **`cd apps/emp_ai_boilerplate_app && flutter analyze`** (or **`dart run melos run analyze:all`** from the repo root).

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
