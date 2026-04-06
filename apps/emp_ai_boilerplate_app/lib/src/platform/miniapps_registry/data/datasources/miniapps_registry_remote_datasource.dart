import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';

/// IO boundary for remote mini-app allow-list (HTTP, gRPC, etc.).
abstract interface class MiniappsRegistryRemoteDataSource {
  Future<MiniappsRemoteRegistrySnapshot> fetchEnabledMiniApps();
}
