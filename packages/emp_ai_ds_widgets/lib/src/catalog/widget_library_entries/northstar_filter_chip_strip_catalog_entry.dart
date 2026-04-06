import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_filter_chip_strip.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarFilterChipStripCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_filter_chip_strip',
    title: 'NorthstarFilterChipStrip',
    description:
        'Horizontal scroll of Material [FilterChip]s. Use [value] null for '
        'an “All” option; [selectedValue] compares to each item value.',
    code: '''
  NorthstarFilterChipStrip(
    items: const [
      NorthstarFilterChipStripItem(value: null, label: 'All'),
      NorthstarFilterChipStripItem(value: 'a', label: 'A'),
    ],
    selectedValue: null,
    onSelected: (v) {},
  )
  ''',
    preview: (BuildContext context) =>
        const _NorthstarFilterChipStripCatalogDemo(),
  );
}

class _NorthstarFilterChipStripCatalogDemo extends StatefulWidget {
  const _NorthstarFilterChipStripCatalogDemo();

  @override
  State<_NorthstarFilterChipStripCatalogDemo> createState() =>
      _NorthstarFilterChipStripCatalogDemoState();
}

class _NorthstarFilterChipStripCatalogDemoState
    extends State<_NorthstarFilterChipStripCatalogDemo> {
  String? _selected = 'hr';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: NorthstarFilterChipStrip(
        items: const <NorthstarFilterChipStripItem>[
          NorthstarFilterChipStripItem(value: null, label: 'All'),
          NorthstarFilterChipStripItem(value: 'hr', label: 'HR'),
          NorthstarFilterChipStripItem(value: 'it', label: 'IT'),
        ],
        selectedValue: _selected,
        onSelected: (String? v) {
          setState(() => _selected = v);
          catalogPreviewSnack(
            context,
            v == null ? 'All departments' : 'Selected: $v',
          );
        },
      ),
    );
  }
}
