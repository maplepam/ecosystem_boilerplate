import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_selection_controls_theme.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_selection_row.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Switch row; **2px** label–description gap matches Figma **switch** spacing.
class NorthstarSwitchRow extends StatelessWidget {
  const NorthstarSwitchRow({
    super.key,
    this.automationId,
    required this.label,
    this.description,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  final String? automationId;
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return NorthstarSelectionControlsTheme(
      child: NorthstarSelectionRow(
        automationId: automationId,
        control: Switch(
          key: DsAutomationKeys.part(
            automationId,
            DsAutomationKeys.elementSelectionControl,
          ),
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
        label: label,
        description: description,
        enabled: enabled,
        labelDescriptionGap: NorthstarSpacing.space2,
        onTap: (enabled && onChanged != null) ? () => onChanged!(!value) : null,
      ),
    );
  }
}
