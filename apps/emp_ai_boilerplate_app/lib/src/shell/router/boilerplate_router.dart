import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/auth_navigation_refresh.dart';
import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart';
import 'package:emp_ai_boilerplate_app/src/platform/miniapps_registry/mini_app_gate.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_redirect_provider.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_shell_routes.dart';
import 'package:emp_ai_boilerplate_app/src/screens/login_screen.dart';
import 'package:emp_ai_boilerplate_app/src/screens/unauthorized_screen.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_dev_routes.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Toggle [kBoilerplateHostMode] in `host_mode.dart`.
final boilerplateGoRouterProvider = Provider<GoRouter>((ref) {
  final GoRouterRedirect redirect = ref.watch(boilerplateGoRouterRedirectProvider);
  final Listenable authRefresh =
      ref.watch(authNavigationRefreshListenableProvider);
  late final GoRouter router;
  switch (kBoilerplateHostMode) {
    case AppHostMode.embeddedMiniApp:
      router = CoreGoRouterFactory.create(
        CoreRouterConfig(
          mode: AppHostMode.embeddedMiniApp,
          pathPrefix: kEmbeddedPathPrefix,
          routes: _embeddedRoutes,
          initialLocationOverride: '/$kEmbeddedPathPrefix/home',
          redirect: redirect,
          refreshListenable: authRefresh,
        ),
      );
      break;
    case AppHostMode.superApp:
      final MiniAppGate gate = ref.watch(miniAppGateProvider);
      final List<MiniApp> apps = gate.enabledMiniApps;
      final GoRoute hubRoute = GoRoute(
        path: '/hub',
        builder: (BuildContext context, GoRouterState state) =>
            SuperAppHubPage(miniApps: apps),
      );
      final List<RouteBase> inner = kSuperAppUseStatefulShell
          ? MiniAppRouteFactory.buildTreeWithStatefulShell(
              miniApps: apps,
              hubRoute: hubRoute,
              showMiniAppRail: kSuperAppShowMiniAppRail,
            )
          : MiniAppRouteFactory.buildTree(
              miniApps: apps,
              hubRoute: hubRoute,
            );
      final List<RouteBase> routes = <RouteBase>[
        ...boilerplateTopLevelAuthAndDevRoutes(),
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
        ...inner,
      ];
      router = CoreGoRouterFactory.create(
        CoreRouterConfig(
          mode: AppHostMode.superApp,
          routes: routes,
          refreshListenable: Listenable.merge(<Listenable>[
            gate,
            authRefresh,
          ]),
          initialLocationOverride: '/',
          redirect: redirect,
        ),
      );
      break;
    case AppHostMode.standaloneMiniApp:
      router = CoreGoRouterFactory.create(
        CoreRouterConfig(
          mode: AppHostMode.standaloneMiniApp,
          routes: <RouteBase>[
            ...boilerplateTopLevelAuthAndDevRoutes(),
            ..._standaloneSingleRoutes,
          ],
          initialLocationOverride: '/home',
          redirect: redirect,
          refreshListenable: authRefresh,
        ),
      );
      break;
  }
  ref.onDispose(router.dispose);
  return router;
});

List<RouteBase> boilerplateTopLevelAuthAndDevRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: '/unauthorized',
      builder: (BuildContext context, GoRouterState state) =>
          const UnauthorizedScreen(),
    ),
    ...boilerplateTopLevelDevRoutes(),
  ];
}

final List<RouteBase> _embeddedRoutes = <RouteBase>[
  GoRoute(
    path: 'login',
    builder: (BuildContext context, GoRouterState state) =>
        const LoginScreen(),
  ),
  GoRoute(
    path: 'unauthorized',
    builder: (BuildContext context, GoRouterState state) =>
        const UnauthorizedScreen(),
  ),
  ...boilerplateShellRoutes(),
  ...boilerplateEmbeddedDevRoutes(),
];

final List<RouteBase> _standaloneSingleRoutes = <RouteBase>[
  ...boilerplateShellRoutes(),
];
