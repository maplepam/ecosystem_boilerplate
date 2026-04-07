import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Bottom **batch** bar for table multi-select (dark surface, primary line + actions).
class NorthstarBatchActionBar extends StatelessWidget {
  const NorthstarBatchActionBar({
    super.key,
    this.automationId,
    this.leading,
    required this.primaryLine,
    this.secondaryLine,
    this.onDeselect,
    this.deselectLabel = 'Deselect',
    this.actions = const <Widget>[],
  });

  final String? automationId;

  /// Optional leading icon (e.g. file) before the text block (Figma bulk bar).
  final Widget? leading;
  final String primaryLine;
  final String? secondaryLine;
  final VoidCallback? onDeselect;
  final String deselectLabel;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Color bg = ns.inverseSurface;
    final Color onBg = ns.onInverseSurface;

    return Material(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementBatchActionBar,
      ),
      color: bg,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space24,
          vertical: NorthstarSpacing.space16,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              IconTheme(
                data: IconThemeData(color: onBg, size: 22),
                child: leading!,
              ),
              const SizedBox(width: NorthstarSpacing.space12),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  primaryLine,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: onBg,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
                if (secondaryLine != null) ...<Widget>[
                  const SizedBox(height: NorthstarSpacing.space4),
                  Text(
                    secondaryLine!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onBg.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                  ),
                ],
              ],
            ),
            if (onDeselect != null || actions.isNotEmpty) ...<Widget>[
              const SizedBox(width: NorthstarSpacing.space12),
              SizedBox(
                height: 36,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: onBg.withValues(alpha: 0.22),
                ),
              ),
              const SizedBox(width: NorthstarSpacing.space12),
            ],
            if (onDeselect != null)
              TextButton(
                onPressed: onDeselect,
                style: TextButton.styleFrom(
                  foregroundColor: onBg,
                  padding: const EdgeInsets.symmetric(
                    horizontal: NorthstarSpacing.space12,
                  ),
                ),
                child: Text(
                  deselectLabel,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: onBg,
                  ),
                ),
              ),
            ...actions,
          ],
        ),
      ),
    );
  }
}
