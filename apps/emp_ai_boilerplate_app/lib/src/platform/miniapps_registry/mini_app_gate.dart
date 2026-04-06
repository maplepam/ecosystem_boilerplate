import 'dart:async';

import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/miniapp_host_catalog.dart';
import 'package:emp_ai_boilerplate_app/src/platform/feature_flags/feature_flag_provider.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/di/miniapps_registry_providers.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_repository.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/domain/miniapps_remote_registry_snapshot.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves which mini-apps are on after optional **remote registry** + feature flags.
/// Wired to [GoRouter.refreshListenable] so route trees stay in sync.
final class MiniAppGate extends ChangeNotifier {
  MiniAppGate({
    required FeatureFlagSource flags,
    List<MiniApp>? allApps,
    MiniappsRemoteRegistryRepository? remoteRegistry,
  })  : _flags = flags,
        _all = allApps ?? kHostMiniAppsCatalog,
        _remoteRegistry = remoteRegistry,
        _enabled = List<MiniApp>.from(allApps ?? kHostMiniAppsCatalog) {
    unawaited(_resolve());
  }

  final FeatureFlagSource _flags;
  final List<MiniApp> _all;
  final MiniappsRemoteRegistryRepository? _remoteRegistry;
  List<MiniApp> _enabled;

  List<MiniApp> get enabledMiniApps => _enabled;

  Future<void> refresh() => _resolve();

  Future<void> _resolve() async {
    List<MiniApp> candidates = _all;
    final MiniappsRemoteRegistryRepository? repo = _remoteRegistry;
    if (repo != null) {
      try {
        final MiniappsRemoteRegistrySnapshot remote =
            await repo.fetchEnabledMiniApps();
        final Set<String>? ids = remote.enabledIds;
        if (ids != null && ids.isNotEmpty) {
          candidates = _all
              .where((MiniApp a) => ids.contains(a.id))
              .toList(growable: false);
        }
      } on Object {
        candidates = _all;
      }
    }

    final List<MiniApp> filtered =
        await filterMiniAppsByFeatureFlags(candidates, _flags);
    final List<MiniApp> next = filtered.isEmpty ? _all : filtered;
    if (_sameById(_enabled, next)) {
      return;
    }
    _enabled = next;
    notifyListeners();
  }

  bool _sameById(List<MiniApp> a, List<MiniApp> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) {
        return false;
      }
    }
    return true;
  }
}

final miniAppGateProvider = ChangeNotifierProvider<MiniAppGate>(
  (ref) => MiniAppGate(
    flags: ref.watch(featureFlagSourceProvider),
    remoteRegistry: ref.watch(miniappsRemoteRegistryRepositoryProvider),
  ),
);
