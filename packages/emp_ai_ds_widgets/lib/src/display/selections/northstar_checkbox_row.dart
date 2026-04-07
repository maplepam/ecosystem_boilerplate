import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_selection_controls_theme.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_selection_row.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Checkbox row with optional **indeterminate** ([value] `null`).
class NorthstarCheckboxRow extends StatelessWidget {
  const NorthstarCheckboxRow({
    super.key,
    this.automationId,
    required this.label,
    this.description,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.labelDescriptionGap = NorthstarSpacing.space4,
  });

  final String? automationId;
  final String label;
  final String? description;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;
  final double labelDescriptionGap;

  void _toggle() {
    if (!enabled || onChanged == null) {
      return;
    }
    if (value == null) {
      onChanged!(true);
      return;
    }
    onChanged!(!value!);
  }

  @override
  Widget build(BuildContext context) {
    return NorthstarSelectionControlsTheme(
      child: NorthstarSelectionRow(
        automationId: automationId,
        control: Checkbox(
          key: DsAutomationKeys.part(
            automationId,
            DsAutomationKeys.elementSelectionControl,
          ),
          value: value,
          tristate: true,
          onChanged: enabled ? onChanged : null,
        ),
        label: label,
        description: description,
        enabled: enabled,
        labelDescriptionGap: labelDescriptionGap,
        onTap: (enabled && onChanged != null) ? _toggle : null,
      ),
    );
  }
}
