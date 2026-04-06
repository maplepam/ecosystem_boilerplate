import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_drawer_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_scaffold_with_drawer.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarScaffoldWithDrawerCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_scaffold_with_drawer',
    title: 'NorthstarScaffoldWithDrawer',
    description:
        'Shell scaffold with [AppBar], openable drawer, and optional FAB. '
        'Same entry model as [NorthstarNavigationDrawer].',
    code: '''
  NorthstarScaffoldWithDrawer(
    appBarTitle: const Text('Workspace'),
    drawerHeader: DrawerHeader(child: Text('Brand')),
    entries: [
      NorthstarDrawerRouteEntry(
  location: '/main/home',
  label: 'Home',
  icon: Icons.home_outlined,
      ),
    ],
    body: const Center(child: Text('Page')),
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
            child: NorthstarScaffoldWithDrawer(
              appBarTitle: const Text('Workspace'),
              drawerHeader: DrawerHeader(
                margin: EdgeInsets.zero,
                child: Text(
                  'Brand',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              closeDrawerOnNavigate: false,
              onDrawerNavigate: (BuildContext c, String loc) =>
                  catalogPreviewSnack(c, 'Drawer navigate: $loc'),
              entries: const <NorthstarDrawerEntry>[
                NorthstarDrawerRouteEntry(
                  location: '/x',
                  label: 'Home',
                  icon: Icons.home_outlined,
                ),
                NorthstarDrawerRouteEntry(
                  location: '/x/settings',
                  label: 'Settings',
                  icon: Icons.settings_outlined,
                ),
              ],
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(NorthstarSpacing.space16),
                  child: Text(
                    'Open the menu (☰) in the app bar to try the drawer.',
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
