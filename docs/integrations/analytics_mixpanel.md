# Analytics: Mixpanel

Send product analytics through the shared **`AnalyticsSink`** contract; the host registers **`MixpanelAnalyticsSink`** when **`MIXPANEL_TOKEN`** is non-empty.

**Defines & JSON:** [../platform/dart_defines.md](../platform/dart_defines.md), [`build_defines.example.json`](../../apps/emp_ai_boilerplate_app/config/build_defines.example.json). **Firebase (second vendor):** [analytics_firebase.md](analytics_firebase.md). **Sink composition:** [../platform/HOST_SERVICES.md](../platform/HOST_SERVICES.md).

## Setup

1. Copy your **project token** from Mixpanel project settings.
2. Pass it at build/run time:
   - **`--dart-define=MIXPANEL_TOKEN=your_token`**, or
   - **`apps/emp_ai_boilerplate_app/config/build_defines.json`**: `"MIXPANEL_TOKEN": "your_token"` and  
     `flutter run --dart-define-from-file=config/build_defines.json`.
3. Leave **`ENABLE_FIREBASE`** `false` if you only use Mixpanel. No `google-services` / `GoogleService-Info.plist` required.

At startup, [`boilerplate_analytics_backends_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/boilerplate_analytics_backends_provider.dart) calls **`Mixpanel.init`** and adds **`MixpanelAnalyticsSink`**. Init failures are ignored in tests / missing plugins.

## Track, identify, and reset (recommended)

Use the **composed** provider so **`VERBOSE_LOGS`** debug printing stays in the same pipeline as remote sinks:

```dart
import 'package:emp_ai_boilerplate_app/src/platform/analytics/observability_providers.dart';

// Event → Mixpanel.track under the hood (see MixpanelAnalyticsSink)
ref.read(analyticsSinkProvider).track(
  'order_submitted',
  <String, Object?>{'order_id': orderId, 'currency': 'USD'},
);

await ref.read(analyticsSinkProvider).identify(
  userId,
  traits: <String, Object?>{'plan': 'pro'},
);

await ref.read(analyticsSinkProvider).reset();
```

**`identify`** maps to Mixpanel **`identify`** plus **People** `set` for each trait. **`setUserProperty`** maps to **`getPeople().set`**.

## Mixpanel-only sink (tests or overrides)

If you construct **`MixpanelAnalyticsSink`** yourself (e.g. in a test override), you still implement **`AnalyticsSink`**: **`track`**, **`identify`**, **`reset`**, **`setUserProperty`** — see [`mixpanel_analytics_sink.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/mixpanel_analytics_sink.dart).

## Sync call sites (no verbose sink)

Token refresh and similar code use **`boilerplateAnalyticsSinkProvider`** ([`boilerplate_analytics_backends_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/boilerplate_analytics_backends_provider.dart)) so **`track`** hits **remote** sinks only (or **`DebugPrintAnalyticsSink`** while the `FutureProvider` is still loading).

## Rules

- Do **not** import **`mixpanel_flutter`** from **`domain/`** or mini-app **`domain/`**; keep calls behind **`AnalyticsSink`** / providers.

---

[← Docs home — integrations hub](../README.md#integrations-hub)
