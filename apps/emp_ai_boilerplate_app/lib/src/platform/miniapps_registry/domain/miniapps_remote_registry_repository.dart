import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';

/// Host use-case: load which mini-app ids the backend allows for this principal.
///
/// Implemented in **data** (`MiniappsRemoteRegistryRepositoryImpl` + datasources).
abstract interface class MiniappsRemoteRegistryRepository {
  Future<MiniappsRemoteRegistrySnapshot> fetchEnabledMiniApps();
}
