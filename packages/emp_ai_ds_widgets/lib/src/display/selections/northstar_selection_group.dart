import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Group wrapper: optional **legend** (with required asterisk), **helper**, **counter**,
/// **16px** to first item, **12px** between items, **8px** before **error** (Figma **Spacing**).
class NorthstarSelectionGroup extends StatelessWidget {
  const NorthstarSelectionGroup({
    super.key,
    this.automationId,
    this.label,
    this.requiredField = false,
    this.helper,
    this.error,
    this.counterText,
    this.counterAtMax = false,
    required this.children,
  });

  final String? automationId;
  final String? label;
  final bool requiredField;
  final String? helper;
  final String? error;
  final String? counterText;
  final bool counterAtMax;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color onSurface = ns.onSurface;
    final Color variant = ns.onSurfaceVariant;
    final Color accentErr = ns.error;

    return Semantics(
      container: true,
      child: Column(
        key: DsAutomationKeys.part(
          automationId,
          DsAutomationKeys.elementSelectionGroup,
        ),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (label != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text.rich(
                    key: DsAutomationKeys.part(
                      automationId,
                      DsAutomationKeys.elementSelectionGroupLabel,
                    ),
                    TextSpan(
                      style: textTheme.titleSmall?.copyWith(
                        color: onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.25,
                      ),
                      children: <InlineSpan>[
                        TextSpan(text: label),
                        if (requiredField)
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: accentErr),
                          ),
                      ],
                    ),
                  ),
                ),
                if (counterText != null)
                  Text(
                    counterText!,
                    key: DsAutomationKeys.part(
                      automationId,
                      DsAutomationKeys.elementSelectionGroupCounter,
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: counterAtMax ? onSurface : variant,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          if (helper != null) ...<Widget>[
            const SizedBox(height: NorthstarSpacing.space4),
            Text(
              helper!,
              key: DsAutomationKeys.part(
                automationId,
                DsAutomationKeys.elementSelectionGroupHelper,
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: variant,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ],
          if (label != null || helper != null)
            const SizedBox(height: NorthstarSpacing.space16),
          for (var i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: NorthstarSpacing.space12),
            children[i],
          ],
          if (error != null) ...<Widget>[
            const SizedBox(height: NorthstarSpacing.space8),
            Text(
              error!,
              key: DsAutomationKeys.part(
                automationId,
                DsAutomationKeys.elementSelectionGroupError,
              ),
              style: textTheme.bodySmall?.copyWith(
                color: accentErr,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
