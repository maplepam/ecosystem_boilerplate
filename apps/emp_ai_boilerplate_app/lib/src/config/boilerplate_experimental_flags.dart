/// `--dart-define=SAMPLES_CACHED_QUERY=true` — Samples welcome line uses
/// [cached_query] ([QueryBuilder]) instead of [SamplesWelcomeNotifier].
const bool kSamplesWelcomeUseCachedQuery = bool.fromEnvironment(
  'SAMPLES_CACHED_QUERY',
  defaultValue: false,
);

/// When true, [SamplesRemoteDataSourceHttp] loads copy from a public JSON API
/// via [boilerplateDioProvider] (real GET). When false, the fake in-memory datasource
/// runs (default for tests / offline).
const bool kSamplesUseHttpRemoteDemo = bool.fromEnvironment(
  'SAMPLES_HTTP_DEMO',
  defaultValue: false,
);

/// Initialize Firebase (core + messaging/analytics) when true. Requires
/// platform config (`flutterfire configure`, `google-services.json`, etc.).
const bool kBoilerplateEnableFirebase = bool.fromEnvironment(
  'ENABLE_FIREBASE',
  defaultValue: false,
);

/// Mixpanel project token; when non-empty, [Mixpanel.init] runs at startup.
/// Set via `--dart-define` or `--dart-define-from-file` (see `config/build_defines.example.json`).
const String kBoilerplateMixpanelToken = String.fromEnvironment(
  'MIXPANEL_TOKEN',
  defaultValue: '',
);

/// Use [FlutterLocalNotificationsPlugin] for [LocalNotificationPort].
const bool kBoilerplateEnableLocalNotifications = bool.fromEnvironment(
  'ENABLE_LOCAL_NOTIFICATIONS',
  defaultValue: false,
);

/// Use Firebase Cloud Messaging for [PushNotificationPort] (needs Firebase).
const bool kBoilerplateEnableFcm = bool.fromEnvironment(
  'ENABLE_FCM',
  defaultValue: false,
);
