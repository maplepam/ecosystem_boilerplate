# Feature flags

Compile-time and host-level feature toggles without calling vendors from **`domain/`**.

**Contract:** [`FeatureFlagSource`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_foundation/lib/src/feature_flags/feature_flag_source.dart) in **`emp_ai_foundation`** — async **`isEnabled(String key)`** and optional **`treatment(String key)`**.

**Host registration:** [`feature_flag_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/feature_flag_provider.dart) exposes **`featureFlagSourceProvider`**. The default implementation is **[`BoilerplateFeatureFlags`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart)** (compile-time defaults for demos).

<a id="feature-flags"></a>

## Add a flag (boilerplate pattern)

1. **Pick a stable string key** (e.g. `miniapp_orders_enabled`). Use the same key everywhere you read the flag. Prefer constants in `BoilerplateFeatureFlagKeys` / `BoilerplateFeatureFlagTreatments` in [`boilerplate_feature_flags.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart).
2. **Boolean flags:** add a **`final bool`** field + branch in **`isEnabled`** (see **`samples_show_extras_button`** in the same file).
3. **Non-boolean / multi-variant flags:** store a **string** (or JSON) and return it from **`treatment(String key)`** — e.g. **`samples_dashboard_layout`** with values **`compact` | `full` | `experimental`**. Parse in UI (`switch (layout) { ... }`) or map to an enum in **`presentation/providers`**.
4. **Read from UI / presentation (sync, typed):** use **`ref.watch(boilerplateFeatureFlagsProvider)`**:

   ```dart
   final BoilerplateFeatureFlags flags = ref.watch(boilerplateFeatureFlagsProvider);

   if (flags.samplesShowExtrasButton) {
     // ...
   }

   final String layout = flags.samplesDashboardLayout;
   switch (layout) {
     case 'compact':
       break;
     case 'full':
       break;
     default:
       break;
   }
   ```

5. **Read via `FeatureFlagSource` (async, generic keys):** use **`featureFlagSourceProvider`** when you need **`await`** (e.g. future remote config):

   ```dart
   final FeatureFlagSource source = ref.read(featureFlagSourceProvider);
   final bool on = await source.isEnabled(BoilerplateFeatureFlagKeys.samplesShowExtrasButton);
   final String? variant = await source.treatment(BoilerplateFeatureFlagKeys.samplesDashboardLayout);
   ```

6. **Mini-app gating:** set **`MiniApp.requiredFeatureFlagKey`** to the same string; **[`MiniAppGate`](../../apps/emp_ai_boilerplate_app/lib/src/platform/miniapps_registry/mini_app_gate.dart)** calls **[`filterMiniAppsByFeatureFlags`](https://github.com/maplepam/ecosystem-platform/blob/main/packages/emp_ai_app_shell/lib/src/mini_app_feature_filter.dart)** so hub tabs respect flags. Use **`MiniAppAlwaysOn`** only for demos ([miniapps.md](../engineering/miniapps.md)).

**Defaults:** today they are **constructor defaults** on **`BoilerplateFeatureFlags`** (and **`boilerplateFeatureFlagsProvider`**). To “change defaults,” edit those fields or override **`boilerplateFeatureFlagsProvider`** / **`featureFlagSourceProvider`** in tests / **`ProviderScope`**.

**Rule:** do not call Split (or any vendor) from **`domain/`**; keep **`FeatureFlagSource`** behind providers in **`presentation`** or host **`lib/src/providers/`**.

**Live examples:** Samples screen shows a **Chip** for **`samples_dashboard_layout`** (treatment) and conditionally **`Extra action (feature flag)`** when **`samples_show_extras_button`** is true.

---

[← Docs home — integrations hub](../README.md#integrations-hub)
