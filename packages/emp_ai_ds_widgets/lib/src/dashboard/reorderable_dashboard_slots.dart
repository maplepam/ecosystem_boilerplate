import '../testing/ds_automation_keys.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Slot metadata for customize / reorder UIs (persistence lives in the host).
@immutable
class DashboardSlotDefinition {
  const DashboardSlotDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

/// Edit mode: drag to reorder. Host supplies [order] + callbacks; persist with
/// Riverpod / `shared_preferences` / backend.
class ReorderableDashboardSlotList extends StatelessWidget {
  const ReorderableDashboardSlotList({
    super.key,
    required this.definitions,
    required this.order,
    required this.hidden,
    required this.onReorder,
    required this.onToggleVisible,
    this.automationId,
  });

  final List<DashboardSlotDefinition> definitions;
  final List<String> order;
  final Set<String> hidden;
  final void Function(List<String> nextOrder) onReorder;
  final void Function(String id, bool visible) onToggleVisible;

  /// Optional [DsAutomationKeys]: list ([elementDashboardReorderList]) and per
  /// slot `slot_<id>` / `slot_<id>_switch`.
  final String? automationId;

  @override
  Widget build(BuildContext context) {
    final Map<String, DashboardSlotDefinition> byId = <String, DashboardSlotDefinition>{
      for (final DashboardSlotDefinition d in definitions) d.id: d,
    };
    final List<String> ordered = order.where(byId.containsKey).toList(growable: false);

    Widget list = ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ordered.length,
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final List<String> next = List<String>.from(ordered);
        final String id = next.removeAt(oldIndex);
        next.insert(newIndex, id);
        onReorder(next);
      },
      itemBuilder: (BuildContext context, int index) {
        final String id = ordered[index];
        final DashboardSlotDefinition def = byId[id]!;
        final bool isHidden = hidden.contains(id);
        final Key cardKey = DsAutomationKeys.part(
              automationId,
              'slot_$id',
            ) ??
            ValueKey<String>(id);
        return Card(
          key: cardKey,
          margin: const EdgeInsets.only(bottom: NorthstarSpacing.space8),
          child: ListTile(
            leading: const Icon(Icons.drag_handle),
            title: Text(def.title),
            subtitle: Text(def.subtitle),
            trailing: Switch(
              key: DsAutomationKeys.part(automationId, 'slot_${id}_switch'),
              value: !isHidden,
              onChanged: (bool v) => onToggleVisible(id, v),
            ),
          ),
        );
      },
    );

    final ValueKey<String>? listKey = DsAutomationKeys.part(
      automationId,
      DsAutomationKeys.elementDashboardReorderList,
    );
    if (listKey != null) {
      list = KeyedSubtree(key: listKey, child: list);
    }
    return list;
  }
}
