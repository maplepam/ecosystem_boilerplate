import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_nav_rail_branding.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_side_nav_tile.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Wide shell **left rail**: branding strip + [ShellNavItem] list (leaves +
/// expandable parents). [expanded] is hover width state; [showExpandedChrome]
/// also requires min width for labels (see [_kMinWidthForExpandedLabels]).
class ShellWebSideNav extends StatelessWidget {
  const ShellWebSideNav({
    super.key,
    required this.expanded,
    required this.tokens,
    required this.items,
    required this.shellPath,
    required this.parentExpanded,
    required this.onLeaf,
    required this.onParentToggle,
    this.brandingTitle = 'Starter shell',
    this.brandingSubtitle =
        'A calm place to explore components, color, and the live product shell.',
    this.footerTip =
        'Tip: open “Components” to browse every widget, then tap one '
            'for a full-screen preview.',
  });

  static const double kMinWidthForExpandedLabels = 184;

  final bool expanded;
  final NorthstarColorTokens tokens;
  final List<ShellNavItem> items;
  final String shellPath;
  final Map<String, bool> parentExpanded;
  final void Function(ShellNavLeaf leaf, ShellNavParent? owningParent) onLeaf;
  final ValueChanged<String> onParentToggle;
  final String brandingTitle;
  final String brandingSubtitle;
  final String footerTip;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double railW = constraints.maxWidth;
        final bool showExpandedChrome =
            expanded && railW >= kMinWidthForExpandedLabels;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ShellNavRailBranding(
              showExpandedChrome: showExpandedChrome,
              tokens: tokens,
              title: brandingTitle,
              subtitle: brandingSubtitle,
            ),
            for (final ShellNavItem e in items) ...<Widget>[
              switch (e) {
                ShellNavTopLeaf(:final ShellNavLeaf leaf) => ShellSideNavTile(
                    icon: leaf.icon,
                    label: leaf.label,
                    showExpandedLabels: showExpandedChrome,
                    selected: leaf.matchesPath(shellPath),
                    nested: false,
                    isExpandableParent: false,
                    parentExpanded: false,
                    emphasizeWhenCollapsedRail: false,
                    onTap: () => onLeaf(leaf, null),
                  ),
                ShellNavTopParent(:final ShellNavParent parent) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ShellSideNavTile(
                        icon: parent.icon,
                        label: parent.label,
                        showExpandedLabels: showExpandedChrome,
                        selected: false,
                        nested: false,
                        isExpandableParent: true,
                        parentExpanded: parentExpanded[parent.id] ?? false,
                        emphasizeWhenCollapsedRail:
                            parent.containsPath(shellPath),
                        onTap: () => onParentToggle(parent.id),
                      ),
                      if (showExpandedChrome &&
                          (parentExpanded[parent.id] ?? false))
                        for (final ShellNavLeaf leaf in parent.children)
                          ShellSideNavTile(
                            icon: leaf.icon,
                            label: leaf.label,
                            showExpandedLabels: showExpandedChrome,
                            selected: leaf.matchesPath(shellPath),
                            nested: true,
                            isExpandableParent: false,
                            parentExpanded: false,
                            emphasizeWhenCollapsedRail: false,
                            onTap: () => onLeaf(leaf, parent),
                          ),
                    ],
                  ),
              },
            ],
            const Spacer(),
            if (showExpandedChrome)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Text(
                  footerTip,
                  style: textTheme.labelSmall?.copyWith(
                    color: tokens.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
