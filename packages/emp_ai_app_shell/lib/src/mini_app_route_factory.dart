import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'mini_app.dart';
import 'super_app_stateful_shell_scaffold.dart';

/// How [MiniApp] routes are combined with the host router.
enum MiniAppMountStrategy {
  /// `/auth/login`, `/rewards/cart`, … — each mini-app owns a top-level
  /// segment. Avoids path clashes between teams.
  nestedUnderId,

  /// All [MiniApp.routes] flattened at the root of the route tree (same as the
  /// sample `...expand((a) => a.routes)` pattern). Only safe if paths are
  /// namespaced inside each mini-app.
  flat,
}

abstract final class MiniAppRouteFactory {
  const MiniAppRouteFactory._();

  /// Hub route at `/` plus mini-app branches.
  static List<RouteBase> buildTree({
    required List<MiniApp> miniApps,
    required GoRoute hubRoute,
    MiniAppMountStrategy strategy = MiniAppMountStrategy.nestedUnderId,
  }) {
    return <RouteBase>[
      hubRoute,
      ...mergeMiniApps(miniApps, strategy: strategy),
    ];
  }

  static List<RouteBase> mergeMiniApps(
    List<MiniApp> miniApps, {
    MiniAppMountStrategy strategy = MiniAppMountStrategy.nestedUnderId,
  }) {
    switch (strategy) {
      case MiniAppMountStrategy.nestedUnderId:
        return miniApps
            .map(
              (MiniApp a) => GoRoute(
                path: '/${a.id}',
                name: a.id,
                redirect: (context, state) {
                  final String p = state.uri.path;
                  final String base = '/${a.id}';
                  if (p == base || p == '$base/') {
                    return a.entryLocation;
                  }
                  return null;
                },
                routes: a.routes,
              ),
            )
            .toList(growable: false);
      case MiniAppMountStrategy.flat:
        return miniApps.expand((MiniApp a) => a.routes).toList(growable: false);
    }
  }

  /// One [StatefulShellBranch] per mini-app (persistent tab stacks).
  static List<StatefulShellBranch> shellBranchesFor(
    List<MiniApp> miniApps,
  ) {
    return miniApps
        .map(
          (MiniApp a) => StatefulShellBranch(
            routes: <RouteBase>[
              _goRouteForMiniAppRoot(a),
            ],
          ),
        )
        .toList(growable: false);
  }

  static GoRoute _goRouteForMiniAppRoot(MiniApp a) {
    return GoRoute(
      path: '/${a.id}',
      name: a.id,
      redirect: (context, state) {
        final String p = state.uri.path;
        final String base = '/${a.id}';
        if (p == base || p == '$base/') {
          return a.entryLocation;
        }
        return null;
      },
      routes: a.routes,
    );
  }

  /// Hub at `/` plus [StatefulShellRoute.indexedStack] for all [miniApps].
  ///
  /// [showMiniAppRail] controls [SuperAppStatefulShellScaffold.showMiniAppRail].
  static List<RouteBase> buildTreeWithStatefulShell({
    required List<MiniApp> miniApps,
    required GoRoute hubRoute,
    bool showMiniAppRail = true,
  }) {
    return <RouteBase>[
      hubRoute,
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return SuperAppStatefulShellScaffold(
            navigationShell: navigationShell,
            miniApps: miniApps,
            showMiniAppRail: showMiniAppRail,
          );
        },
        branches: shellBranchesFor(miniApps),
      ),
    ];
  }
}
