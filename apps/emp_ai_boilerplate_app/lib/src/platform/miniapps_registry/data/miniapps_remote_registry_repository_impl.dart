import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/data/datasources/miniapps_registry_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_repository.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';

/// **Data** implementation — delegates to [MiniappsRegistryRemoteDataSource].
///
/// **REPLACE:** add caching, ETag, offline policy, or map errors to [AppFailure] here if your
/// host standardizes on that (foundation).
final class MiniappsRemoteRegistryRepositoryImpl
    implements MiniappsRemoteRegistryRepository {
  MiniappsRemoteRegistryRepositoryImpl({
    required MiniappsRegistryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MiniappsRegistryRemoteDataSource _remoteDataSource;

  @override
  Future<MiniappsRemoteRegistrySnapshot> fetchEnabledMiniApps() =>
      _remoteDataSource.fetchEnabledMiniApps();
}
