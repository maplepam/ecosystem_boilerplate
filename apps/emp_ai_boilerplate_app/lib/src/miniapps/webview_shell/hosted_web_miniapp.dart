import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/webview_shell/hosted_web_view_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// **Web-only** mini-app: one route that loads [initialUrl] in a [WebViewWidget].
///
/// Register in [kHostMiniAppsCatalog] when the partner has **no** Dart package — only a URL.
/// For remote allow-list, [id] must appear in `enabled_miniapp_ids` from the registry API.
///
/// **REPLACE** security (cookies, headers, navigation delegate, allowed hosts) before production.
final class HostedWebMiniApp extends MiniApp with MiniAppAlwaysOn {
  HostedWebMiniApp({
    required this.id,
    required this.displayName,
    required this.initialUrl,
    this.routePath = 'home',
  });

  @override
  final String id;

  @override
  final String displayName;

  /// First page to load inside the WebView.
  final Uri initialUrl;

  /// Path segment under `/$id/` (default `home` → `/partner_x/home`).
  final String routePath;

  @override
  String get entryLocation => '/$id/$routePath';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: routePath,
          name: '${id}_$routePath',
          builder: (BuildContext context, GoRouterState state) =>
              HostedWebViewScreen(uri: initialUrl),
        ),
      ];
}
