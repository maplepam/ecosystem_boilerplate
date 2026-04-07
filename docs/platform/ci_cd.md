# CI/CD: Bitbucket Pipelines, Bitrise, web + mobile

This boilerplate does **not** ship a full `bitbucket-pipelines.yml` for your product repo — your org’s secrets and signing differ. This page describes **typical multi-flavor** patterns (Bitbucket, Bitrise, vault-injected defines) you can mirror in your pipeline.

**Getting started (human steps):** [getting_started.md](../onboarding/getting_started.md) — **§2** (local `build_defines.json`) and **§4.5** (CI pointer). **Toggles / `FLAVOR`:** [dart_defines.md](dart_defines.md). **Catalog & optional `API_BASE_URL` / `AUTH_*`:** [integrations/environment.md](../integrations/environment.md). **Template:** [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json).

---

## Local development

Use this when you want **one file** instead of many **`--dart-define=`** flags on every `flutter run` / `flutter build`.

1. `cd apps/emp_ai_boilerplate_app`
2. `cp config/build_defines.example.json config/build_defines.json`
3. Edit **`config/build_defines.json`** (gitignored — do not commit secrets).
4. Run with:
   ```bash
   flutter run --dart-define-from-file=config/build_defines.json
   ```
5. For a specific device or web:
   ```bash
   flutter run -d chrome --dart-define-from-file=config/build_defines.json
   flutter run -d ios --dart-define-from-file=config/build_defines.json
   flutter run -d android --dart-define-from-file=config/build_defines.json
   ```

**Release-style builds (local):** pass the same flag:

```bash
flutter build web --release --dart-define-from-file=config/build_defines.json
flutter build apk --release --dart-define-from-file=config/build_defines.json
flutter build ipa --release --dart-define-from-file=config/build_defines.json
```

Boolean values in JSON must be the strings **`"true"`** or **`"false"`** (see [dart_defines.md](dart_defines.md)).

---

## CI (Bitbucket Pipelines, Bitrise, or any runner)

**Goal:** the build machine never commits secrets; it **writes** a JSON file in the job workspace, then runs Flutter with **`--dart-define-from-file`**.

### Where the values come from (not from Git)

The repository only carries **templates** (e.g. [`build_defines.example.json`](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json)) — placeholders, not production secrets. **CI does not read secrets from a committed file.**

**Bitbucket Cloud**

| Mechanism | Where to set it | What happens at build time |
|-----------|-----------------|----------------------------|
| **Repository variables** | *Repository settings → Repository variables* | Each variable becomes an **environment variable** in the pipeline container (`$MIXPANEL_TOKEN`, `$AUTH_CLIENT_ID`, …). Your `script:` uses shell substitution to pass them into JSON or `--dart-define=`. |
| **Secured variables** | Same screen, checkbox **Secured** | Values are **masked in logs** and are not exposed to forks the same way as open vars — check Bitbucket docs for fork/PR behavior. |
| **Deployment variables** | *Deployments* → choose **environment** (e.g. staging / production) | Lets the **same** `bitbucket-pipelines.yml` use different values per deployment target. |

So: **you enter real tokens and URLs in Bitbucket’s UI (or API) once**; the pipeline **injects** them when the job runs. The Flutter command only sees the result as **compile-time defines** after your script builds the JSON or the flag list.

**Bitrise:** same idea — **Secrets** become env vars in the workflow; a Script step writes `build_defines.ci.json` or passes `--dart-define=` using those names.

### 1. Store secrets in the CI vault

- **Bitbucket:** Repository / deployment **variables** (mark sensitive vars as **secured**).
- **Bitrise:** **Secrets** env vars.

### 2. Generate `build_defines.json` in a script step

Start from the same keys as [build_defines.example.json](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json). **Add** **`API_BASE_URL`** and/or **`AUTH_*`** only for [CI API override / define-only auth](../integrations/environment.md#auth-dart-defines-advanced) — see [integrations/environment.md](../integrations/environment.md).

```bash
cd apps/emp_ai_boilerplate_app
cat > build_defines.ci.json <<EOF
{
  "FLAVOR": "production",
  "VERBOSE_LOGS": "false",
  "SAMPLES_CACHED_QUERY": "false",
  "SAMPLES_HTTP_DEMO": "false",
  "ENABLE_FIREBASE": "false",
  "MIXPANEL_TOKEN": "${MIXPANEL_TOKEN}",
  "ENABLE_LOCAL_NOTIFICATIONS": "false",
  "ENABLE_FCM": "false"
}
EOF
```

Use your pipeline’s syntax for env substitution (`$VAR` in bash; escape JSON if values contain quotes). Alternatively **`jq`** or a small script that reads vault vars and emits valid JSON.

### 3. Run Flutter build

```bash
flutter pub get
flutter build apk --release --dart-define-from-file=build_defines.ci.json
```

Same pattern for **`flutter build web`**, **`flutter build ipa`**, etc. **Web** artifact: deploy **`build/web`**. **iOS:** add your usual codesign / export steps after **`flutter build ipa`**.

### 4. Bitbucket sketch (YAML)

```yaml
pipelines:
  default:
    - step:
        name: Build Android
        script:
          - cd apps/emp_ai_boilerplate_app
          - flutter pub get
          # … generate build_defines.ci.json from secured variables …
          - flutter build apk --release --dart-define-from-file=build_defines.ci.json
```

### 5. Bitrise sketch

- **Script** step: generate **`build_defines.ci.json`** from **Bitrise Secrets** (same as above).
- **Flutter Build** step: **`flutter build`** with **`--dart-define-from-file=`** pointing at that file.

---

## Principles

1. **Compile-time configuration** — `FLAVOR`, toggles (`VERBOSE_LOGS`, Samples, Mixpanel, …), and optionally **`API_BASE_URL`** / **`AUTH_*`** are passed as **`--dart-define=...`** or **`--dart-define-from-file=...`**. See [dart_defines.md](dart_defines.md) vs [integrations/environment.md](../integrations/environment.md) for what belongs in the catalog vs overrides.
2. **Secrets in the CI vault** — pipeline injects values → JSON file or env exports → Flutter build command (same idea as a **`setenv.sh`**-style script).
3. **Web vs mobile** — same JSON for all targets where possible; **iOS** adds signing / export options outside Flutter.

---

<a id="github-actions-in-this-repo"></a>

## GitHub Actions in this repo

This workspace ships [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) as a **reference** pipeline (Ubuntu, Flutter stable):

1. **`actions/checkout@v4`** with **`submodules: recursive`**, then **`dart pub get`** and **`dart run melos bootstrap`** — same order as local (submodules first). Configure **SSH** so Actions can **fetch** submodules from **GitHub** (`ecosystem-platform`) and **Bitbucket** (`emp_ai_auth`, **`emp_ai_ds`**). This repo expects **`BITBUCKET_SSH_PRIVATE_KEY`** and **`GITHUB_SSH_PRIVATE_KEY`** (see [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)).
2. **`dart run tool/generate_miniapps.dart`** — verifies the generated mini-app catalog matches the registry (catches forgotten **`generate:miniapps`** after editing **`miniapps_registry.yaml`**).
3. **`dart run melos exec … flutter analyze .`** — every package with a **`lib/`** directory.
4. **`flutter test`** in **`apps/emp_ai_boilerplate_app`**.

For Bitbucket / Bitrise secret injection and **`build_defines.ci.json`**, use the sections above; mirror the **same steps** your org uses in other hosts.

### GitHub Pages (Flutter web)

This repo includes [`.github/workflows/deploy-github-pages.yml`](../../.github/workflows/deploy-github-pages.yml). On each push to **`main`** it runs **`flutter build web --release`** for **`apps/emp_ai_boilerplate_app`** and publishes the **`build/web`** output via **GitHub Actions** (official **Pages** deployment).

**Enable once in the repository:** *Settings → Pages → Build and deployment → Source:* select **GitHub Actions** (not “Deploy from a branch”).

**Base path:** the workflow sets **`BASE_HREF`** to **`/ecosystem_boilerplate/`** so assets load correctly at **`https://<owner>.github.io/ecosystem_boilerplate/`**. If you **rename the repository**, edit **`BASE_HREF`** in that workflow to match **`/<new-repo-name>/`** (must start and end with **`/`**).

The Pages build does **not** pass **`--dart-define-from-file`**; it relies on the same compile-time defaults as a plain **`flutter build web`**. For a production site with secrets, generate a CI JSON in the workflow (see above) and add **`--dart-define-from-file=…`** to the **`flutter build web`** step.

---

## Reference pipelines

- In mature internal apps, look for **`bitbucket-pipelines.yml`**, **`setenv.sh`**, and **`build_ipa.sh`** (or equivalents) — copy the **structure** (secret injection → Flutter build), not file paths.

## See also

- [dart_defines.md](dart_defines.md) — `FLAVOR` + host toggles.
- [integrations/environment.md](../integrations/environment.md) — flavor catalog, optional **`API_BASE_URL`** / **`AUTH_*`**.
- [getting_started.md](../onboarding/getting_started.md) — §2 local file, §4 platforms.
