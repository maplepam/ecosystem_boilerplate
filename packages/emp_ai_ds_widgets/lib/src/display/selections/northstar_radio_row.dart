import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_selection_controls_theme.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_selection_row.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Typed radio row. Must sit under a [RadioGroup] ancestor that supplies
/// [RadioGroup.groupValue] and [RadioGroup.onChanged] (Material 3.32+).
///
/// See also: [NorthstarRadioGroup] for a small Column wrapper around [RadioGroup].
class NorthstarRadioRow<T extends Object> extends StatelessWidget {
  const NorthstarRadioRow({
    super.key,
    this.automationId,
    required this.label,
    this.description,
    required this.value,
    this.enabled = true,
    this.labelDescriptionGap = NorthstarSpacing.space4,
  });

  final String? automationId;
  final String label;
  final String? description;
  final T value;
  final bool enabled;
  final double labelDescriptionGap;

  void _selectFromRow(BuildContext context) {
    if (!enabled) {
      return;
    }
    final RadioGroupRegistry<T>? registry = RadioGroup.maybeOf<T>(context);
    registry?.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return NorthstarSelectionControlsTheme(
      child: NorthstarSelectionRow(
        automationId: automationId,
        control: Radio<T>(
          key: DsAutomationKeys.part(
            automationId,
            DsAutomationKeys.elementSelectionControl,
          ),
          value: value,
          enabled: enabled,
        ),
        label: label,
        description: description,
        enabled: enabled,
        labelDescriptionGap: labelDescriptionGap,
        onTap: enabled ? () => _selectFromRow(context) : null,
      ),
    );
  }
}
