import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_drawer_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_navigation_drawer.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarNavigationDrawerCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_navigation_drawer',
    title: 'NorthstarNavigationDrawer',
    description:
        'Slide-out drawer: flat routes, nested [ExpansionTile] groups, '
        'or arbitrary custom rows (version footer, toggles). Compose '
        'entries in the host app — this package stays presentation-only.',
    code: '''
  Scaffold(
    drawer: NorthstarNavigationDrawer(
      header: DrawerHeader(
  child: Text('My app'),
      ),
      entries: [
  NorthstarDrawerRouteEntry(
    location: '/main/home',
    label: 'Home',
    icon: Icons.home_outlined,
  ),
  NorthstarDrawerExpansionEntry(
    label: 'Modules',
    icon: Icons.apps_outlined,
    children: [
      NorthstarDrawerRouteEntry(
        location: '/samples/demo',
        label: 'Samples',
        icon: Icons.science_outlined,
      ),
    ],
  ),
  NorthstarDrawerCustomEntry(
    builder: (context) => const ListTile(
      title: Text('v0.1.0'),
      dense: true,
    ),
  ),
      ],
    ),
    body: ...,
  )
  ''',
    preview: (BuildContext context) {
      return Align(
        alignment: Alignment.topCenter,
        child: Material(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          elevation: 1,
          child: SizedBox(
            width: 360,
            height: 420,
            child: Scaffold(
              appBar: AppBar(title: const Text('Preview')),
              drawer: NorthstarNavigationDrawer(
                header: DrawerHeader(
                  margin: EdgeInsets.zero,
                  child: Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                closeOnNavigate: false,
                onNavigate: (BuildContext c, String loc) =>
                    catalogPreviewSnack(c, 'Drawer: $loc'),
                entries: <NorthstarDrawerEntry>[
                  const NorthstarDrawerRouteEntry(
                    location: '/a',
                    label: 'Route row',
                    icon: Icons.navigation_outlined,
                  ),
                  const NorthstarDrawerExpansionEntry(
                    label: 'Expandable',
                    icon: Icons.folder_outlined,
                    initiallyExpanded: true,
                    children: <NorthstarDrawerEntry>[
                      NorthstarDrawerRouteEntry(
                        location: '/b',
                        label: 'Child route',
                      ),
                    ],
                  ),
                  NorthstarDrawerCustomEntry(
                    builder: _navigationDrawerCatalogVersionTile,
                  ),
                ],
              ),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(NorthstarSpacing.space16),
                  child: Text(
                    'Open the menu (☰) to try routes and expansion.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _navigationDrawerCatalogVersionTile(BuildContext context) {
  return ListTile(
    dense: true,
    title: Text(
      'Custom row (not a route)',
      style: Theme.of(context).textTheme.bodySmall,
    ),
    subtitle: const Text('e.g. build number'),
  );
}
