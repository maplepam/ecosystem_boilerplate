import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Read-only summary: small grey **field** label + value (comma-separated list or single line).
class NorthstarSelectionSummaryField extends StatelessWidget {
  const NorthstarSelectionSummaryField({
    super.key,
    this.automationId,
    required this.fieldLabel,
    required this.valueText,
    this.compact = false,
  });

  final String? automationId;
  final String fieldLabel;
  final String valueText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color variant = ns.onSurfaceVariant;
    final Color onSurface = ns.onSurface;
    final double labelSize = compact ? 12 : 14;

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
        Text(
          valueText,
          style: textTheme.bodyMedium?.copyWith(
            color: onSurface,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
