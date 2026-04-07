import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// One selection line: **12px** gap from control to text stack; **4px** (or [labelDescriptionGap])
/// between label and description; control **top** aligns with first label line (Figma **Spacing**).
///
/// Whole row is tappable when [onTap] is non-null (**Trigger** guideline).
class NorthstarSelectionRow extends StatelessWidget {
  const NorthstarSelectionRow({
    super.key,
    this.automationId,
    required this.control,
    required this.label,
    this.description,
    this.enabled = true,
    this.labelDescriptionGap = NorthstarSpacing.space4,
    this.onTap,
    this.labelStyle,
    this.descriptionStyle,
  });

  final String? automationId;
  final Widget control;
  final String label;
  final String? description;
  final bool enabled;
  final double labelDescriptionGap;
  final VoidCallback? onTap;
  final TextStyle? labelStyle;
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color labelColor =
        enabled ? ns.onSurface : ns.onSurfaceVariant;
    final Color descColor = enabled
        ? ns.onSurfaceVariant
        : ns.onSurfaceVariant.withValues(alpha: 0.7);

    final Widget textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          key: DsAutomationKeys.part(
            automationId,
            DsAutomationKeys.elementSelectionLabel,
          ),
          style: (labelStyle ?? textTheme.bodyLarge)?.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.3,
          ),
        ),
        if (description != null && description!.isNotEmpty) ...<Widget>[
          SizedBox(height: labelDescriptionGap),
          Text(
            description!,
            key: DsAutomationKeys.part(
              automationId,
              DsAutomationKeys.elementSelectionDescription,
            ),
            style: (descriptionStyle ?? textTheme.bodyMedium)?.copyWith(
              color: descColor,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ],
    );

    final Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: IconTheme.merge(
            data: IconThemeData(size: 20, color: labelColor),
            child: control,
          ),
        ),
        const SizedBox(width: NorthstarSpacing.space12),
        Expanded(child: textColumn),
      ],
    );

    return MergeSemantics(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementSelectionRow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: NorthstarSpacing.space4,
              horizontal: NorthstarSpacing.space4,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}
