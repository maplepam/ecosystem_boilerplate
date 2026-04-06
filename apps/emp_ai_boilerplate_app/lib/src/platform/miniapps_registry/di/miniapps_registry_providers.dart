import 'package:emp_ai_boilerplate_app/src/network/boilerplate_api_client.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/datasources/miniapps_registry_remote_datasource_http.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/datasources/miniapps_registry_remote_datasource_stub.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/miniapps_remote_registry_repository_impl.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full URL for `GET` returning JSON like `docs/fixtures/miniapps_registry.json`.
///
/// **REPLACE:** wire from flavor catalog or remote config in production.
///
/// When **empty** (default): [MiniappsRegistryRemoteDataSourceStub] — no network (CI/tests safe).
///
/// **Smoke test (parse intentionally fails):** `--dart-define=MINIAPPS_REGISTRY_URL=https://httpbin.org/json`
const String kMiniappsRegistryUrlFromEnvironment = String.fromEnvironment(
  'MINIAPPS_REGISTRY_URL',
  defaultValue: '',
);

/// Force stub even when [kMiniappsRegistryUrlFromEnvironment] is set (widget tests, offline CI).
const bool kMiniappsRegistryUseStub = bool.fromEnvironment(
  'MINIAPPS_REGISTRY_USE_STUB',
  defaultValue: false,
);

/// Domain repository for [MiniAppGate].
///
/// **Override** in tests with a fake [MiniappsRemoteRegistryRepository].
final miniappsRemoteRegistryRepositoryProvider =
    Provider<MiniappsRemoteRegistryRepository>(
  (Ref ref) {
    if (kMiniappsRegistryUseStub) {
      return MiniappsRemoteRegistryRepositoryImpl(
        remoteDataSource: const MiniappsRegistryRemoteDataSourceStub(),
      );
    }
    final String trimmed = kMiniappsRegistryUrlFromEnvironment.trim();
    if (trimmed.isEmpty) {
      return MiniappsRemoteRegistryRepositoryImpl(
        remoteDataSource: const MiniappsRegistryRemoteDataSourceStub(),
      );
    }
    return MiniappsRemoteRegistryRepositoryImpl(
      remoteDataSource: MiniappsRegistryRemoteDataSourceHttp(
        dio: ref.watch(boilerplateDioProvider),
        registryUrl: trimmed,
      ),
    );
  },
);
