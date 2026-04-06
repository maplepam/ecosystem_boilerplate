# First day: run the boilerplate

Minimal commands from a fresh clone. For **why** each step exists, fork vs clone, **§3** catalog, **§4** platforms, and snippets, use [getting_started.md](getting_started.md).

## From repository root

```bash
dart pub get
dart run melos bootstrap
dart run melos run generate:miniapps
```

## Run the host app

```bash
cd apps/emp_ai_boilerplate_app
flutter run
```

Optional: copy [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json) to **`config/build_defines.json`** (gitignored), then:

```bash
flutter run --dart-define-from-file=config/build_defines.json
```

## Same checks as CI

From repo root:

```bash
dart run melos run analyze:all
dart run melos run test:boilerplate
```

GitHub Actions runs bootstrap, regenerates the mini-app catalog, analyzes, and tests — see [ci_cd.md](../platform/ci_cd.md#github-actions-in-this-repo).

## Next

- Replace template env: [getting_started.md §3](getting_started.md#gs-3) → **`boilerplate_environment_catalog.dart`**
- Integrations hub: [docs README — integrations hub](../README.md#integrations-hub)
- Stuck: [troubleshooting.md](../platform/troubleshooting.md)
