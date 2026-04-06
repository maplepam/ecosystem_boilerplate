import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/dashboard/reorderable_dashboard_slots.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry reorderableDashboardSlotListCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'reorderable_dashboard_slot_list',
    title: 'ReorderableDashboardSlotList',
    description: 'Edit mode: drag-reorder slots and toggle visibility. Persist '
        '`order` and `hidden` in the host (e.g. Riverpod + SharedPreferences).',
    code: '''
  ReorderableDashboardSlotList(
    definitions: [
      DashboardSlotDefinition(
  id: 'kpi',
  title: 'KPIs',
  subtitle: 'Headline metrics',
      ),
    ],
    order: ['kpi'],
    hidden: {},
    onReorder: (next) { /* save */ },
    onToggleVisible: (id, visible) { /* save */ },
  )
  ''',
    preview: (BuildContext context) {
      return const _ReorderableDashboardCatalogDemo();
    },
  );
}

/// Local state so drag-reorder and visibility toggles actually update in Try it.
class _ReorderableDashboardCatalogDemo extends StatefulWidget {
  const _ReorderableDashboardCatalogDemo();

  @override
  State<_ReorderableDashboardCatalogDemo> createState() =>
      _ReorderableDashboardCatalogDemoState();
}

class _ReorderableDashboardCatalogDemoState
    extends State<_ReorderableDashboardCatalogDemo> {
  List<String> _order = <String>['a', 'b'];
  final Set<String> _hidden = <String>{};

  @override
  Widget build(BuildContext context) {
    return ReorderableDashboardSlotList(
      definitions: const <DashboardSlotDefinition>[
        DashboardSlotDefinition(
          id: 'a',
          title: 'Widget A',
          subtitle: 'Drag handle to reorder',
        ),
        DashboardSlotDefinition(
          id: 'b',
          title: 'Widget B',
          subtitle: 'Toggle visibility',
        ),
      ],
      order: _order,
      hidden: _hidden,
      onReorder: (List<String> next) => setState(() => _order = next),
      onToggleVisible: (String id, bool visible) => setState(() {
        if (visible) {
          _hidden.remove(id);
        } else {
          _hidden.add(id);
        }
      }),
    );
  }
}
