import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_drawer_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_navigation_drawer.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarDrawerEntryModelCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_drawer_entry_model',
    title: 'NorthstarDrawerEntry (data)',
    description:
        'Sealed hierarchy for drawer rows — keep navigation shape in the '
        'host as plain data: [NorthstarDrawerRouteEntry] (goRouter path), '
        '[NorthstarDrawerExpansionEntry] (nested routes or more groups), '
        '[NorthstarDrawerCustomEntry] (version, toggles, non-route UI). '
        'Defined in northstar_drawer_entry.dart.',
    code: '''
  // Route row → ListTile + context.go(location)
  const NorthstarDrawerRouteEntry(
    location: '/settings',
    label: 'Settings',
    icon: Icons.settings_outlined,
  );
  
  // Expandable section
  const NorthstarDrawerExpansionEntry(
    label: 'Admin',
    icon: Icons.admin_panel_settings_outlined,
    children: [
      NorthstarDrawerRouteEntry(
  location: '/admin/users',
  label: 'Users',
      ),
    ],
  );
  
  // Custom (no navigation)
  NorthstarDrawerCustomEntry(
    builder: (context) => ListTile(
      dense: true,
      title: Text('v1.2.3', style: Theme.of(context).textTheme.labelSmall),
    ),
  );
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
              appBar: AppBar(title: const Text('Entry shapes')),
              drawer: NorthstarNavigationDrawer(
                header: DrawerHeader(
                  margin: EdgeInsets.zero,
                  child: Text(
                    'Route · expansion · custom',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                closeOnNavigate: false,
                onNavigate: (BuildContext c, String loc) =>
                    catalogPreviewSnack(c, 'Entry model drawer: $loc'),
                entries: <NorthstarDrawerEntry>[
                  const NorthstarDrawerRouteEntry(
                    location: '/settings',
                    label: 'NorthstarDrawerRouteEntry',
                    icon: Icons.link,
                  ),
                  const NorthstarDrawerExpansionEntry(
                    label: 'NorthstarDrawerExpansionEntry',
                    icon: Icons.folder_outlined,
                    initiallyExpanded: true,
                    children: <NorthstarDrawerEntry>[
                      NorthstarDrawerRouteEntry(
                        location: '/nested',
                        label: 'Child route',
                      ),
                    ],
                  ),
                  NorthstarDrawerCustomEntry(builder: _versionTile),
                ],
              ),
              body: const Center(
                child: Padding(
                  padding: EdgeInsets.all(NorthstarSpacing.space16),
                  child: Text(
                    'Open ☰ — same data types as in your host code.',
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

Widget _versionTile(BuildContext context) {
  return ListTile(
    dense: true,
    title: Text(
      'Custom row (not a route)',
      style: Theme.of(context).textTheme.bodySmall,
    ),
    subtitle: const Text('e.g. build number'),
  );
}
