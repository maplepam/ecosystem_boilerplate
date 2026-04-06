# Analytics: Firebase Analytics

Send events through **`AnalyticsSink`**; the host adds **`FirebaseAnalyticsSink`** when **`ENABLE_FIREBASE=true`** and **`Firebase.initializeApp()`** has succeeded.

**Defines:** [../platform/dart_defines.md](../platform/dart_defines.md). **Mixpanel (second vendor):** [analytics_mixpanel.md](analytics_mixpanel.md). **Bootstrap:** [`boilerplate_firebase_bootstrap.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/firebase/boilerplate_firebase_bootstrap.dart).

## Setup

1. Register the app in the Firebase console and run **`flutterfire configure`** (or add **`google-services.json`** (Android), **`GoogleService-Info.plist`** (iOS), and **`firebase_options.dart`** manually — [FlutterFire](https://firebase.flutter.dev/) docs).
2. Set **`ENABLE_FIREBASE=true`** (CLI or JSON **`"true"`**). **`bootstrapBoilerplateFirebaseIfEnabled()`** runs **`Firebase.initializeApp()`** inside [`loadBoilerplateStartupOverrides()`](../../apps/emp_ai_boilerplate_app/lib/src/app/boilerplate_startup_overrides.dart) **before** `runApp`.
3. Leave **`MIXPANEL_TOKEN`** empty if you only use Firebase.

Until native config exists, init may no-op; the app still runs, but **`Firebase.apps`** stays empty and the Firebase sink is **not** added.

## Track, identify, and reset (recommended)

Same **`analyticsSinkProvider`** as Mixpanel — events fan out to **every** registered sink when you use both vendors:

```dart
import 'package:emp_ai_boilerplate_app/src/platform/analytics/observability_providers.dart';

// → FirebaseAnalytics.logEvent (names/parameters sanitized — see below)
ref.read(analyticsSinkProvider).track(
  'Order Submitted',
  <String, Object?>{'order_id': orderId},
);

await ref.read(analyticsSinkProvider).identify(
  userId,
  traits: <String, Object?>{'plan': 'pro'},
);

await ref.read(analyticsSinkProvider).reset();
```

**Firebase-specific behavior** ([`firebase_analytics_sink.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/firebase_analytics_sink.dart)):

- **Event names** are lowercased; non-alphanumeric characters become **`_`**; max length **40**; names starting with **`firebase_`** get a prefix.
- **Parameters** must be **`String`**, **`num`**, or **`bool`** (other types are stringified).
- **`identify`** uses **`setUserId`**; traits map to **`setUserProperty`** with Firebase naming rules (invalid keys are dropped).

## Sync call sites

Use **`boilerplateAnalyticsSinkProvider`** when you cannot use the full composed sink (same as Mixpanel doc): [`boilerplate_analytics_backends_provider.dart`](../../apps/emp_ai_boilerplate_app/lib/src/platform/analytics/boilerplate_analytics_backends_provider.dart).

## Rules

- Do **not** import **`firebase_analytics`** from **`domain/`**; use **`AnalyticsSink`** / providers.

---

[← Docs home — integrations hub](../README.md#integrations-hub)
