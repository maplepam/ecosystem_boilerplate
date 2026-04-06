import 'package:emp_ai_ds_widgets/src/catalog/northstar_widget_library_detail_page.dart';
import 'package:emp_ai_ds_widgets/src/catalog/northstar_widget_library_list_page.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_built_in_entries.dart';
import 'package:flutter/material.dart';

/// Developer catalog: every **built-in** `emp_ai_ds_widgets` entry + optional
/// host-registered widgets.
///
/// Built-in rows are defined in `lib/src/catalog/widget_library_entries/`
/// (one Dart file per catalog entry) and aggregated by [builtInWidgetLibraryEntries].
class NorthstarWidgetLibraryPage extends StatelessWidget {
  const NorthstarWidgetLibraryPage({
    super.key,
    this.extraEntries = const <WidgetCatalogEntry>[],
  });

  final List<WidgetCatalogEntry> extraEntries;

  static List<WidgetCatalogEntry> builtInEntries() =>
      builtInWidgetLibraryEntries();

  @override
  Widget build(BuildContext context) {
    final List<WidgetCatalogEntry> all = <WidgetCatalogEntry>[
      ...NorthstarWidgetLibraryPage.builtInEntries(),
      ...extraEntries,
    ]..sort(WidgetCatalogEntry.compareByTitle);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget library'),
      ),
      body: NorthstarWidgetLibraryListPage(
        entries: all,
        subtitle:
            'Pick a component to open its live preview. Ideal for demos and '
            'design reviews.',
        onOpenEntry: (WidgetCatalogEntry e) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext c) => NorthstarWidgetLibraryDetailPage(
                entry: e,
                onBack: () => Navigator.of(c).pop(),
              ),
            ),
          );
        },
      ),
    );
  }
}
