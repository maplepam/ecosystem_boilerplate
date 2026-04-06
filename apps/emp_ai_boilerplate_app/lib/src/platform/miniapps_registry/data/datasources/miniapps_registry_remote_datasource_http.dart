import 'package:dio/dio.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/datasources/miniapps_registry_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/dtos/miniapps_registry_response_dto.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';
import 'package:flutter/foundation.dart';

/// **HTTP** registry: `GET [registryUrl]` → JSON parsed by [MiniappsRegistryResponseDto].
///
/// ---
/// **REPLACE for production**
/// - [registryUrl]: your BFF, e.g. `https://api.mycompany.com/v1/me/miniapps` (often includes auth
///   headers — add a Dio interceptor or pass a dedicated `Dio` with baseUrl).
/// - [MiniappsRegistryResponseDto]: field names / nesting for your real payload.
/// - Error policy: today any failure → `enabledIds: null` (no server filter). You may want to
///   **block** or **retry** instead — implement in a wrapper or override [fetchEnabledMiniApps].
///
/// ---
/// **Sample JSON** (also at repo `docs/fixtures/miniapps_registry.json`):
/// `{ "enabled_miniapp_ids": ["main", "announcements", "resources", "samples"] }`
///
/// **Local dev:** serve that file with a static server and set
/// `--dart-define=MINIAPPS_REGISTRY_URL=http://127.0.0.1:8080/miniapps_registry.json`
///
/// **Smoke test (no valid DTO):** `https://httpbin.org/json` — request succeeds, parse returns
/// null shape → falls back to `MiniappsRemoteRegistrySnapshot()` (no remote restriction).
/// ---
final class MiniappsRegistryRemoteDataSourceHttp
    implements MiniappsRegistryRemoteDataSource {
  MiniappsRegistryRemoteDataSourceHttp({
    required Dio dio,
    required this.registryUrl,
  }) : _dio = dio;

  final Dio _dio;

  /// **Full URL** (not joined with host [Dio.options.baseUrl]) so the registry can live on another
  /// origin than your main API. **REPLACE** with env / flavor if needed.
  final String registryUrl;

  @override
  Future<MiniappsRemoteRegistrySnapshot> fetchEnabledMiniApps() async {
    try {
      final Response<Object?> response = await _dio.get<Object?>(registryUrl);
      final Object? data = response.data;
      if (data is String) {
        // **REPLACE:** if your API returns a JSON string body, decode here (import dart:convert).
        return const MiniappsRemoteRegistrySnapshot();
      }
      final MiniappsRegistryResponseDto? dto =
          MiniappsRegistryResponseDto.tryParse(data);
      if (dto == null) {
        if (kDebugMode) {
          debugPrint(
            'MiniappsRegistryRemoteDataSourceHttp: body did not match '
            '${MiniappsRegistryResponseDto.kEnabledMiniappIdsKey} — ignoring remote filter.',
          );
        }
        return const MiniappsRemoteRegistrySnapshot();
      }
      return dto.toSnapshot();
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('MiniappsRegistryRemoteDataSourceHttp: $e\n$st');
      }
      return const MiniappsRemoteRegistrySnapshot();
    }
  }
}
