import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Drawer block for one [ShellNavParent]. Expansion is controlled externally
/// via [expanded] (from [ShellNavExpansionCoordinator.expanded]).
class ShellDrawerParentSection extends StatelessWidget {
  const ShellDrawerParentSection({
    super.key,
    required this.tokens,
    required this.parent,
    required this.currentPath,
    required this.expanded,
    required this.onParentHeaderTap,
    required this.onChildTap,
  });

  final NorthstarColorTokens tokens;
  final ShellNavParent parent;
  final String currentPath;
  final bool expanded;
  final VoidCallback onParentHeaderTap;
  final ValueChanged<ShellNavLeaf> onChildTap;

  @override
  Widget build(BuildContext context) {
    final bool onLeaf = parent.matchingLeaf(currentPath) != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ListTile(
          leading: Icon(
            parent.icon,
            color: parent.containsPath(currentPath) && !onLeaf
                ? tokens.primary
                : null,
          ),
          title: Text(parent.label),
          trailing: Icon(
            expanded ? Icons.expand_less_rounded : Icons.chevron_right_rounded,
            color: tokens.onSurfaceVariant,
          ),
          onTap: onParentHeaderTap,
        ),
        if (expanded)
          for (final ShellNavLeaf leaf in parent.children)
            ListTile(
              contentPadding: const EdgeInsets.only(
                left: NorthstarSpacing.space32,
                right: NorthstarSpacing.space16,
              ),
              leading: Icon(leaf.icon, size: 22),
              title: Text(leaf.label),
              selected: leaf.matchesPath(currentPath),
              onTap: () => onChildTap(leaf),
            ),
      ],
    );
  }
}
