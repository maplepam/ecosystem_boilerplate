import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_search_field.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarSearchFieldCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_search_field',
    title: 'NorthstarSearchField',
    description: 'Outlined search field with leading icon for list filters and '
        'catalog-style UIs. Optional [automationId] maps to a [ValueKey].',
    code: '''
  NorthstarSearchField(
    hintText: 'Search…',
    automationId: 'orders_search',
    onChanged: (v) {},
  )
  ''',
    preview: (BuildContext context) => const _NorthstarSearchFieldCatalogDemo(),
  );
}

class _NorthstarSearchFieldCatalogDemo extends StatefulWidget {
  const _NorthstarSearchFieldCatalogDemo();

  @override
  State<_NorthstarSearchFieldCatalogDemo> createState() =>
      _NorthstarSearchFieldCatalogDemoState();
}

class _NorthstarSearchFieldCatalogDemoState
    extends State<_NorthstarSearchFieldCatalogDemo> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          NorthstarSearchField(
            hintText: 'Search components…',
            onChanged: (String v) => setState(() => _query = v),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Text(
            _query.isEmpty ? 'Query: (empty)' : 'Query: $_query',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
