import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_paths.dart';
import 'package:emp_ai_boilerplate_app/src/theme/acme_brand_tokens.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Design-system and widget-catalog routes shared by super-app / standalone.
List<RouteBase> boilerplateTopLevelDevRoutes() {
  return <RouteBase>[
    GoRoute(
      path: '/dev/ds',
      builder: (BuildContext context, GoRouterState state) =>
          NorthstarDesignSystemShowcasePage(
        lightTokens: AcmeBrandTokens.light,
        darkTokens: AcmeBrandTokens.dark,
      ),
    ),
    GoRoute(
      path: '/dev/widgets',
      redirect: (BuildContext context, GoRouterState state) =>
          BoilerplateShellPaths.widgets,
    ),
  ];
}

/// Nested under [CoreGoRouterFactory] embedded prefix (e.g. `/demo/...`).
List<RouteBase> boilerplateEmbeddedDevRoutes() {
  return <RouteBase>[
    GoRoute(
      path: 'dev',
      routes: <RouteBase>[
        GoRoute(
          path: 'ds',
          builder: (BuildContext context, GoRouterState state) =>
              NorthstarDesignSystemShowcasePage(
            lightTokens: AcmeBrandTokens.light,
            darkTokens: AcmeBrandTokens.dark,
          ),
        ),
        GoRoute(
          path: 'widgets',
          redirect: (BuildContext context, GoRouterState state) =>
              BoilerplateShellPaths.widgets,
        ),
      ],
    ),
  ];
}
