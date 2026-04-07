import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Read-only **Yes** / **No** line under a field label (Figma **View only** — checkbox / switch).
class NorthstarBooleanViewOnly extends StatelessWidget {
  const NorthstarBooleanViewOnly({
    super.key,
    this.automationId,
    required this.fieldLabel,
    required this.selected,
    this.trueLabel = 'Yes',
    this.falseLabel = 'No',
    this.compact = false,
  });

  final String? automationId;
  final String fieldLabel;
  final bool selected;
  final String trueLabel;
  final String falseLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color variant = ns.onSurfaceVariant;
    final Color onSurface = ns.onSurface;
    final double labelSize = compact ? 12 : 14;
    final double bodySize = compact ? 13 : 14;

    final Widget iconState = selected
        ? Icon(
            Icons.check_circle_rounded,
            size: compact ? 18 : 20,
            color: ns.success,
          )
        : Icon(
            Icons.cancel_outlined,
            size: compact ? 18 : 20,
            color: variant,
          );

    return Column(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementSelectionViewOnly,
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          fieldLabel,
          style: textTheme.labelMedium?.copyWith(
            color: variant,
            fontSize: labelSize,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            iconState,
            const SizedBox(width: NorthstarSpacing.space8),
            Text(
              selected ? trueLabel : falseLabel,
              style: textTheme.bodyMedium?.copyWith(
                color: onSurface,
                fontSize: bodySize,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
