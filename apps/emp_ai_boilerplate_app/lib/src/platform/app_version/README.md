# App version / force upgrade (placeholder)

Add here when you need **version policy** separate from store updates:

- Read **minimum supported version** from remote config or your BFF.
- Expose a Riverpod provider consumed by **`boilerplateCustomRedirectProvider`** or a root overlay.
- Optionally reuse `platform/feature_flags/` or a dedicated datasource under `platform/app_version/data/`.

Mini-apps should **not** own global force-upgrade logic; keep it in this **platform** slice.
