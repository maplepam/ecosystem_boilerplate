# Extending the host: new tools and SDKs

This is the **recommended flow** when you add a vendor SDK (analytics, crash reporting, remote feature flags, maps, payments, etc.).

## Principles

1. **Contracts live in `emp_ai_foundation`** (or a small dedicated package) when the abstraction is shared across apps.
2. **Implementations live in the host app** under **`lib/src/platform/<capability>/`** for host-wide services (analytics, flags, push), or **`lib/src/integrations/<system>/`** for shared adapters to a specific backend/SDK used by multiple mini-apps. Generic one-off Riverpod glue may stay under **`lib/src/providers/`**.
3. **Domain / mini-apps** depend on **interfaces** or **Riverpod providers** — not on `Firebase.initialize`, `Mixpanel.init`, or Split SDK types directly.

## Concrete steps

1. **Add the package** to `apps/emp_ai_boilerplate_app/pubspec.yaml` (or a shared package if multiple apps ship).
2. **Create or reuse** an interface in `emp_ai_foundation` (e.g. `AnalyticsSink`, `CrashReportingSink`, `FeatureFlagSource`) when one exists.
3. **Implement** the adapter in `lib/src/platform/<name>/` (host-wide) or `lib/src/integrations/<name>/` (shared vertical adapter).
4. **Register** a `Provider` in the same folder or `lib/src/providers/`, or call from `boilerplate_startup_overrides.dart`, so **one place** turns the SDK on (often via `--dart-define` or flavor).
5. **Document** in [docs/README.md — integrations hub](../README.md#integrations-hub) (short bullet in the **Related docs** table, or a new section) and, if the write-up is long, add a file under **`docs/integrations/`** and link it from the hub and [docs/README.md](../README.md).

## What already exists in this repo

| Concern | Where to look |
|---------|----------------|
| Analytics | [analytics_mixpanel.md](analytics_mixpanel.md), [analytics_firebase.md](analytics_firebase.md), [HOST_SERVICES.md](../platform/HOST_SERVICES.md) |
| Crash / logs | [`observability_providers.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/observability_providers.dart), [HOST_SERVICES.md](../platform/HOST_SERVICES.md) |
| Feature flags (read) | [`boilerplate_feature_flags.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/feature_flags/boilerplate_feature_flags.dart), [feature_flags.md](feature_flags.md) |
| Notifications | [HOST_SERVICES.md](../platform/HOST_SERVICES.md) |

## Anti-patterns

- Importing vendor SDKs from **`domain/`** or **mini-app `domain/`**.
- Calling **`Firebase.initializeApp`** from `main()` without a **single** guarded host module (hard to test and disable).

For **architecture** boundaries, see [architecture.md](../engineering/architecture.md).
