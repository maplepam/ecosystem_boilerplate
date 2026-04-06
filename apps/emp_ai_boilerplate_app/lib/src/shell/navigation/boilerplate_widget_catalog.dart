import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_host_widget_catalog_entries.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';

/// DS catalog entries plus host shell navigation widgets
/// ([boilerplateHostShellNavigationCatalogEntries]).
List<WidgetCatalogEntry> boilerplateWidgetCatalogAllEntries() {
  return <WidgetCatalogEntry>[
    ...NorthstarWidgetLibraryPage.builtInEntries(),
    ...boilerplateHostShellNavigationCatalogEntries(),
  ];
}

WidgetCatalogEntry? findBoilerplateWidgetCatalogEntry(String id) {
  for (final WidgetCatalogEntry e in boilerplateWidgetCatalogAllEntries()) {
    if (e.id == id) {
      return e;
    }
  }
  return null;
}
