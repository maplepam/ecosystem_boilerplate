import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_navigation_contrast.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// One row in the **wide** shell side rail: icon + optional label, optional
/// parent chevron, selected fill. Used by [ShellWebSideNav].
class ShellSideNavTile extends StatelessWidget {
  const ShellSideNavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.showExpandedLabels,
    required this.selected,
    required this.onTap,
    this.nested = false,
    this.isExpandableParent = false,
    this.parentExpanded = false,
    this.emphasizeWhenCollapsedRail = false,
  });

  final IconData icon;
  final String label;
  final bool showExpandedLabels;
  final bool selected;
  final VoidCallback onTap;
  final bool nested;
  final bool isExpandableParent;
  final bool parentExpanded;
  final bool emphasizeWhenCollapsedRail;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final Color inactiveFg = shellNavInactiveForeground(context);
    final bool showFill = selected;

    return Padding(
      padding: EdgeInsets.only(
        left: nested ? 22 : 10,
        right: 10,
        top: NorthstarSpacing.space2,
        bottom: NorthstarSpacing.space2,
      ),
      child: Material(
        color: showFill
            ? tokens.primaryContainer.withValues(alpha: 0.55)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: showExpandedLabels ? 10 : 0,
              vertical: NorthstarSpacing.space12,
            ),
            child: showExpandedLabels
                ? LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              icon,
                              size: 22,
                              color: selected ? tokens.primary : inactiveFg,
                            ),
                            const SizedBox(width: NorthstarSpacing.space8),
                            Expanded(
                              child: ClipRect(
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? tokens.onSurface
                                            : inactiveFg,
                                      ),
                                ),
                              ),
                            ),
                            if (isExpandableParent)
                              Icon(
                                parentExpanded
                                    ? Icons.expand_more_rounded
                                    : Icons.chevron_right_rounded,
                                size: 22,
                                color: inactiveFg,
                              ),
                          ],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Tooltip(
                      message: label,
                      child: Icon(
                        icon,
                        size: 22,
                        color: emphasizeWhenCollapsedRail || selected
                            ? tokens.primary
                            : inactiveFg,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
