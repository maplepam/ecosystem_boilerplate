import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/resources/presentation/resources_home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Knowledge / links module (emapta-style second product slice).
final class ResourcesMiniApp extends MiniApp with MiniAppAlwaysOn {
  ResourcesMiniApp();

  @override
  String get id => 'resources';

  @override
  String get displayName => 'Resources';

  @override
  String get entryLocation => '/resources/home';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) =>
              const ResourcesHomeScreen(),
        ),
      ];
}
