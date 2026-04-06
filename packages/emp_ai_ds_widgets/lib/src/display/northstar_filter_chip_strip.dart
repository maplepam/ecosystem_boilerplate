import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// One selectable filter; use [value] `null` for an “All” row item.
@immutable
class NorthstarFilterChipStripItem {
  const NorthstarFilterChipStripItem({
    required this.value,
    required this.label,
  });

  final String? value;
  final String label;
}

/// Horizontal scroll of [FilterChip]s for category / facet bars.
@immutable
class NorthstarFilterChipStrip extends StatelessWidget {
  const NorthstarFilterChipStrip({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: NorthstarSpacing.space12),
  });

  final List<NorthstarFilterChipStripItem> items;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: NorthstarSpacing.space8),
            FilterChip(
              label: Text(items[i].label),
              selected: selectedValue == items[i].value,
              onSelected: (_) => onSelected(items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}
