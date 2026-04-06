import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/screens/announcements_home_screen.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/resources/presentation/resources_home_screen.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/samples_home_screen.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_paths.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_widget_catalog.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_scaffold.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/wide_hub_split.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/wide_widget_catalog_split.dart';
import 'package:emp_ai_boilerplate_app/src/screens/main_shell_home_screen.dart';
import 'package:emp_ai_boilerplate_app/src/screens/theme_settings_screen.dart';
import 'package:emp_ai_boilerplate_app/src/screens/widget_catalog_wide_placeholder.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Route names for deep links and `context.goNamed`.
abstract final class BoilerplateShellRouteNames {
  const BoilerplateShellRouteNames._();

  static const String home = 'shell_home';
  static const String theme = 'shell_theme';
  static const String widgets = 'shell_widgets';
  static const String widgetDetail = 'shell_widget_detail';
  static const String hubSamples = 'shell_hub_samples';
  static const String hubResources = 'shell_hub_resources';
  static const String hubAnnouncements = 'shell_hub_announcements';
}

/// Shared shell: overview, components catalog, theme — used by main mini-app,
/// standalone host, and embedded host trees.
///
/// Catalog: nested `widgets` → `widgets/:catalogId` so wide layouts can show
/// master–detail via [WideWidgetCatalogSplit].
List<RouteBase> boilerplateShellRoutes() {
  return <RouteBase>[
    ShellRoute(
      builder: (
        BuildContext context,
        GoRouterState state,
        Widget child,
      ) {
        return BoilerplateShellScaffold(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          name: BoilerplateShellRouteNames.home,
          builder: (BuildContext context, GoRouterState state) =>
              const MainShellHomeScreen(),
        ),
        GoRoute(
          path: 'theme',
          name: BoilerplateShellRouteNames.theme,
          builder: (BuildContext context, GoRouterState state) =>
              const ThemeSettingsScreen(),
        ),
        ShellRoute(
          builder: (
            BuildContext context,
            GoRouterState state,
            Widget child,
          ) {
            return WideHubSplit(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'hub',
              redirect: (BuildContext context, GoRouterState state) {
                final String p = state.uri.path;
                final String base = BoilerplateShellPaths.hub;
                if (p == base || p == '$base/') {
                  return BoilerplateShellPaths.hubSamples;
                }
                return null;
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'samples',
                  name: BoilerplateShellRouteNames.hubSamples,
                  builder: (BuildContext context, GoRouterState state) =>
                      const SamplesHomeScreen(),
                ),
                GoRoute(
                  path: 'resources',
                  name: BoilerplateShellRouteNames.hubResources,
                  builder: (BuildContext context, GoRouterState state) =>
                      const ResourcesHomeScreen(),
                ),
                GoRoute(
                  path: 'announcements',
                  name: BoilerplateShellRouteNames.hubAnnouncements,
                  builder: (BuildContext context, GoRouterState state) =>
                      const AnnouncementsHomeScreen(),
                ),
              ],
            ),
          ],
        ),
        ShellRoute(
          builder: (
            BuildContext context,
            GoRouterState state,
            Widget child,
          ) {
            return WideWidgetCatalogSplit(child: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'widgets',
              name: BoilerplateShellRouteNames.widgets,
              builder: (BuildContext context, GoRouterState state) {
                if (MediaQuery.sizeOf(context).width >=
                    WideWidgetCatalogSplit.breakpointWidth) {
                  return const WidgetCatalogWidePlaceholder();
                }
                return NorthstarWidgetLibraryListPage(
                  entries: boilerplateWidgetCatalogAllEntries(),
                  onOpenEntry: (WidgetCatalogEntry e) {
                    GoRouter.of(context).go(
                      BoilerplateShellPaths.widgetDetail(e.id),
                    );
                  },
                );
              },
              routes: <RouteBase>[
                GoRoute(
                  path: ':catalogId',
                  name: BoilerplateShellRouteNames.widgetDetail,
                  builder: (BuildContext context, GoRouterState state) {
                    final String id = state.pathParameters['catalogId']!;
                    final WidgetCatalogEntry? entry =
                        findBoilerplateWidgetCatalogEntry(id);
                    if (entry == null) {
                      return _widgetCatalogUnknownIdScaffold(context, id);
                    }
                    return NorthstarWidgetLibraryDetailPage(
                      entry: entry,
                      onBack: () => GoRouter.of(context)
                          .go(BoilerplateShellPaths.widgets),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}

Widget _widgetCatalogUnknownIdScaffold(BuildContext context, String id) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back to list',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => GoRouter.of(context).go(BoilerplateShellPaths.widgets),
      ),
      title: const Text('Component'),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(NorthstarSpacing.space24),
        child: Text(
          'We could not find “$id”. Use the back control to return to the list.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}
