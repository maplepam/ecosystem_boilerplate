import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/datasources/miniapps_registry_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';

/// No network; `enabledIds == null` (catalog not restricted by server).
///
/// **Tests:** prefer this or a fake [MiniappsRegistryRemoteDataSource].
final class MiniappsRegistryRemoteDataSourceStub
    implements MiniappsRegistryRemoteDataSource {
  const MiniappsRegistryRemoteDataSourceStub();

  @override
  Future<MiniappsRemoteRegistrySnapshot> fetchEnabledMiniApps() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return const MiniappsRemoteRegistrySnapshot();
  }
}
