# Host services: analytics, network, notifications, cache

How the boilerplate expects **host apps** to wire cross-cutting services without locking you to one vendor.

**Toggles:** [`dart_defines.md`](dart_defines.md) (`MIXPANEL_TOKEN`, **`ENABLE_FIREBASE`**, …). **Catalog / optional API & auth defines:** [README.md — integrations hub](../README.md#integrations-hub). Template: [`build_defines.example.json`](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json). **CI:** [ci_cd.md](ci_cd.md).

## Analytics

**Step-by-step:** [Mixpanel](../integrations/analytics_mixpanel.md), [Firebase](../integrations/analytics_firebase.md), or [hub summary](../README.md#analytics-mixpanel-and-firebase).

- **Contract:** `AnalyticsSink` in `emp_ai_foundation` (`track`, `identify`, `reset`, `setUserProperty`).
- **Multi-vendor:** `CompositeAnalyticsSink` forwards to a list of sinks (e.g. Mixpanel + Firebase Analytics).
- **Defaults:** `analyticsSinkProvider` composes `DebugPrintAnalyticsSink` when `VERBOSE_LOGS` / `ApplicationHostProfile.enableVerboseLogs` is true, plus optional remote sinks (see below). With no flags and no verbose logs, behavior is `NoOpAnalyticsSink`.
- **Built-in host wiring (still optional):**
  - `--dart-define=MIXPANEL_TOKEN=...` — loads `MixpanelAnalyticsSink` via `boilerplateRemoteAnalyticsSinksProvider` (init failures are ignored in tests / missing plugin).
  - `--dart-define=ENABLE_FIREBASE=true` — `loadBoilerplateStartupOverrides()` calls `Firebase.initializeApp()` (swallowed if native config is missing), then adds `FirebaseAnalyticsSink`.
- **Sync fan-out for non-async code:** `boilerplateAnalyticsSinkProvider` resolves the current **`CompositeAnalyticsSink`** (or **`DebugPrintAnalyticsSink`** while remote sinks load). Token refresh adapters use this for **`trackError` / `handleSuccess`** without awaiting **`boilerplateRemoteAnalyticsSinksProvider`**.
- **Further customization:** override `analyticsSinkProvider` or `boilerplateRemoteAnalyticsSinksProvider` the same way as before:

```dart
ProviderScope(
  overrides: [
    analyticsSinkProvider.overrideWithValue(
      CompositeAnalyticsSink(<AnalyticsSink>[
        const DebugPrintAnalyticsSink(),
        MixpanelAnalyticsSink(...), // your thin wrapper
        FirebaseAnalyticsSink(...),
      ]),
    ),
  ],
  child: const BoilerplateApp(),
);
```

Keep `emp_ai_foundation` free of Mixpanel/Firebase dependencies so core packages stay lightweight.

**External mini-app packages** (separate repo) should use **`AnalyticsSink`** from **`emp_ai_foundation`**, expose a **`Provider<AnalyticsSink>`** defaulting to **`NoOpAnalyticsSink`**, and rely on the host to **`override`** it to **`analyticsSinkProvider`** at **`ProviderScope`** — see [miniapp_packages_and_extract.md §A.4](../engineering/miniapp_packages_and_extract.md).

## Network

- **`NetworkStackConfig`** — timeouts, interceptors, optional `LogInterceptor` in debug.
- **`HostNetwork.createDio`** — normalizes `baseUrl` (no trailing slash) and returns a configured `Dio`.
- Map **per-flavor** base URLs in the host using `ApplicationHostProfile` + `AppBuildFlavorParser`, or hard-coded tables like the legacy `EnvInfo` pattern in the main app.
- **Token refresh (host):** `boilerplateDioProvider` registers **`BoilerplateAuthHeaderInterceptor`** then **`TokenRefreshInterceptor`** from `emp_ai_auth` (refresh on **401** + retry), backed by **`coreTokenRefreshServiceProvider`** and a host **`TokenRefreshAdapter`**. Details: [auth.md](../integrations/auth.md), [network.md](../integrations/network.md).
- **Samples HTTP demo:** `--dart-define=SAMPLES_HTTP_DEMO=true` switches the Samples mini-app remote datasource to a real **`Dio.get`** ([`SamplesRemoteDataSourceHttp`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/samples/data/datasources/samples_remote_datasource_http.dart)); default is offline fake. See [adopting_the_boilerplate.md](../onboarding/adopting_the_boilerplate.md).

## Notifications (opt-in)

- **Contracts:** `LocalNotificationPort`, `PushNotificationPort` + `NoOp*` implementations.
- **Providers:** `localNotificationPortProvider`, `pushNotificationPortProvider` in [`notification_providers.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/notifications/notification_providers.dart).
- **Dart-defines (default off):**
  - `ENABLE_LOCAL_NOTIFICATIONS=true` — `FlutterLocalNotificationsPort` (ignored on **web**).
  - `ENABLE_FCM=true` — `FirebasePushNotificationPort` (requires `ENABLE_FIREBASE=true` and successful `Firebase.initializeApp`; iOS/Android need push entitlements and config).
- **Opt in:** override the providers if you need custom channels, background handlers, or backend token upload (see `registerToken` hook on `PushNotificationPort`).

## Server state: cached_query

- **Init:** `CachedQuery.instance.config(...)` runs in `loadBoilerplateStartupOverrides()` (see `apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_startup_overrides.dart`).
- **Samples mini-app** uses the Riverpod notifier + repository path by default so widget tests stay timer-free. **`--dart-define=SAMPLES_CACHED_QUERY=true`** switches the welcome UI to `QueryBuilder` + `samplesWelcomeQueryProvider` for a full `cached_query` demo (expect async timers; use `pumpAndSettle` or isolate in integration tests).
- **Optional Flutter lifecycle:** call `CachedQuery.instance.configFlutter(...)` instead of `config` when you want refetch-on-resume / connectivity (see package docs for `neverCheckConnection` in tests).
- **Docs:** [cached_query](https://pub.dev/packages/cached_query), [cached_query_flutter](https://pub.dev/packages/cached_query_flutter).

```dart
final welcomeQuery = Query<String>(
  key: 'welcome',
  queryFn: () async => dio.get('/welcome').then((r) => r.data as String),
);
// In UI: QueryBuilder<QueryStatus<String>>(query: welcomeQuery, builder: ...)
```

## User theme accent

- **State:** `userAccentSeedNotifierProvider` persists an optional seed color; `BoilerplateApp` passes it to `NorthstarBranding.seedColor`.
- **UX:** home shell includes sample buttons (default / blue / teal) for manual testing.
