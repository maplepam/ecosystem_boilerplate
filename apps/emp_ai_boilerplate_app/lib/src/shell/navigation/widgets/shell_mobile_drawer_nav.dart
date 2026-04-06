import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_drawer_parent_section.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Full drawer body: title + configurable [ShellNavItem] list (leaves +
/// [ShellDrawerParentSection] for each parent).
class ShellMobileDrawerNav extends StatelessWidget {
  const ShellMobileDrawerNav({
    super.key,
    required this.items,
    required this.currentPath,
    required this.parentExpanded,
    required this.onLeaf,
    required this.onParentToggle,
    this.drawerTitle = 'Navigation',
  });

  final List<ShellNavItem> items;
  final String currentPath;
  final Map<String, bool> parentExpanded;
  final void Function(ShellNavLeaf leaf, ShellNavParent? owningParent) onLeaf;
  final ValueChanged<String> onParentToggle;
  final String drawerTitle;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: NorthstarSpacing.space12),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              NorthstarSpacing.space8,
              20,
              20,
            ),
            child: Text(
              drawerTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (final ShellNavItem e in items) ...<Widget>[
            switch (e) {
              ShellNavTopLeaf(:final ShellNavLeaf leaf) => ListTile(
                  leading: Icon(
                    leaf.icon,
                    color:
                        leaf.matchesPath(currentPath) ? tokens.primary : null,
                  ),
                  title: Text(leaf.label),
                  selected: leaf.matchesPath(currentPath),
                  onTap: () => onLeaf(leaf, null),
                ),
              ShellNavTopParent(:final ShellNavParent parent) =>
                ShellDrawerParentSection(
                  tokens: tokens,
                  parent: parent,
                  currentPath: currentPath,
                  expanded: parentExpanded[parent.id] ?? false,
                  onParentHeaderTap: () => onParentToggle(parent.id),
                  onChildTap: (ShellNavLeaf leaf) => onLeaf(leaf, parent),
                ),
            },
          ],
        ],
      ),
    );
  }
}
