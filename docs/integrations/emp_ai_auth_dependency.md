# Consuming `emp_ai_auth`

Tactical reference for **`pubspec.yaml`**, **SSH**, and the **BOM**. For **repository roles**, **package list**, and **governance**, read **[repositories_overview.md](../engineering/repositories_overview.md)** first.

**Bumping platform:** every file to touch in this repo (plus **emp_ai_auth** on Bitbucket) is listed in **[platform_bump_checklist.md](../meta/platform_bump_checklist.md)**.

The host app depends on **`emp_ai_auth`** as a **Git** dependency (separate remote from **ecosystem-platform**). The branch you pin (e.g. **`ecosystem_boilerplate`**) should declare **`emp_ai_ds`** via **Git** (e.g. **`ref: myemapta_main`**) and **`emp_ai_core`** from **ecosystem-platform** at the **same SHA** as the host — no post-clone `pubspec` patching.

## Bill of materials

Pin and document **both** refs in one place:

- **Platform** (`emp_ai_foundation`, `emp_ai_core`, `emp_ai_ds_*`, `emp_ai_app_shell`) → [`ecosystem-platform`](https://github.com/maplepam/ecosystem-platform) (SSH: `git@github.com:maplepam/ecosystem-platform.git`).
- **Auth** → Bitbucket `emp-ai-flutter-auth` (branch e.g. `ecosystem_boilerplate`).
- **Legacy DS** (transitive via auth’s `emp_ai_ds`) → documented in the same BOM for reproducibility.

Canonical file in this repo: **[`docs/meta/platform_bom.yaml`](../meta/platform_bom.yaml)** (forks edit URLs/refs there; header comments describe drift checks).

## `pubspec.yaml` shape (two Git URLs)

```yaml
dependencies:
  emp_ai_app_shell:
    git:
      url: git@github.com:maplepam/ecosystem-platform.git
      path: packages/emp_ai_app_shell
      ref: fa051d9bbb71a8dc196c6984aab189e6d33f7e0e
  # …same url + ref for other platform packages…
  emp_ai_auth:
    git:
      url: git@bitbucket.org:empowerteams/emp-ai-flutter-auth.git
      ref: 2b521403765a135d5dbf67d36c9e55ddf3b016f1
```

Adjust **`ref`** values to tags or SHAs for release builds.

**Platform monorepo:** Prefer a **full commit SHA** (same value on every `emp_ai_*` Git dependency) instead of only **`ref: main`**. Otherwise Pub can fail to unify transitive **`path:`** dependencies between packages checked out from the same repo (e.g. **`emp_ai_ds_widgets`** depending on **`../emp_ai_ds_northstar`**). After you push new platform commits, bump **all** platform **`ref`s** together and update the BOM.

## Local setup

1. **`dart pub get`** at the repo root (Melos).
2. **`dart run melos bootstrap`** — runs **`flutter pub get`** under **`apps/**`** so Git dependencies resolve.
3. **SSH:** your machine needs access to **GitHub** (platform) and **Bitbucket** (auth + transitive **`emp_ai_ds`**). HTTPS + app password is an alternative if you switch URLs to HTTPS.

### When the auth **branch** moves forward

`pubspec.lock` records a **`resolved-ref`** for **`emp_ai_auth`**. After the Bitbucket branch gains new commits (e.g. **`emp_ai_core`** pin updated), refresh with:

```bash
cd apps/emp_ai_boilerplate_app
flutter pub upgrade emp_ai_auth
```

Then re-run **`dart run melos bootstrap`** from the repo root and commit the updated **`pubspec.lock`**.

## Alternative: auth inside the platform monorepo

If your org moves **`emp_ai_auth`** into **`ecosystem-platform`**, drop the second URL and depend on **`path: packages/emp_ai_auth`** from the same **`ref`** as the other platform packages — still record **one** platform ref in the BOM.

## Local overrides

Use **`apps/emp_ai_boilerplate_app/pubspec_overrides.yaml`** (gitignored) for machine-specific **`path:`** overrides — see **`pubspec_overrides.yaml.example`**.
