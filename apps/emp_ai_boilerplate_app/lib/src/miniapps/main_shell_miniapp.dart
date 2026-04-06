import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_shell_routes.dart';
import 'package:go_router/go_router.dart';

/// Host shell content: demo dashboard, widget catalog, and theme lab.
final class MainShellMiniApp extends MiniApp with MiniAppAlwaysOn {
  MainShellMiniApp();

  @override
  String get id => 'main';

  @override
  String get displayName => 'Main shell';

  @override
  String get entryLocation => '/main/home';

  @override
  List<RouteBase> get routes => boilerplateShellRoutes();
}
