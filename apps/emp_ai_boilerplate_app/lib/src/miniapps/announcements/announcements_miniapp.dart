import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/screens/announcement_detail_screen.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/screens/announcements_home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Company-wide announcements surface (own tab in the super-app shell).
final class AnnouncementsMiniApp extends MiniApp with MiniAppAlwaysOn {
  AnnouncementsMiniApp();

  @override
  String get id => 'announcements';

  @override
  String get displayName => 'Announcements';

  @override
  String get entryLocation => '/announcements/home';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) =>
              const AnnouncementsHomeScreen(),
        ),
        GoRoute(
          path: 'detail/:id',
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id'] ?? '';
            return AnnouncementDetailScreen(announcementId: id);
          },
        ),
      ];
}
