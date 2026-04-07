# Network (Dio)

**`emp_ai_core`** exposes `NetworkStackConfig` and **`HostNetwork.createDio`** (normalized base URL, debug logging).

**Host client** [`boilerplate_api_client.dart`](../../apps/emp_ai_boilerplate_app/lib/src/network/boilerplate_api_client.dart) builds **`boilerplateDioProvider`** with:

1. **`BoilerplateAuthHeaderInterceptor`** — `Authorization: Bearer` from **`TokenRefreshAdapter.fetchStoredCredentials`** (local read only; **no** refresh before send).
2. **`TokenRefreshInterceptor`** — on **401**, refresh via **`CoreTokenRefreshService`** and retry.

There is **no** proactive “refresh before every request” interceptor so **GoRouter navigation** and showing the next screen are not held up on the token endpoint; expired access tokens are handled when the API returns **401**.

**Data layer** only: remote datasources use Dio; inject the same **`Provider<Dio>`** the host configures when possible.

**Real GET example:** [`SamplesRemoteDataSourceHttp`](../../apps/emp_ai_boilerplate_app/lib/src/miniapps/samples/data/datasources/samples_remote_datasource_http.dart) — enable with **`--dart-define=SAMPLES_HTTP_DEMO=true`** (see [adopting_the_boilerplate.md](../onboarding/adopting_the_boilerplate.md)). Map your existing **service / env** types to the same **data source → repository → notifier** flow and **`boilerplateDioProvider`**.

**Rule:** no `Dio` in `domain/` or in widgets.

**Base URL / flavors:** [environment.md](environment.md). **Auth & token refresh:** [auth.md](auth.md). **Network stack overview:** [HOST_SERVICES.md](../platform/HOST_SERVICES.md).

---

[← Docs home — integrations hub](../README.md#integrations-hub)
