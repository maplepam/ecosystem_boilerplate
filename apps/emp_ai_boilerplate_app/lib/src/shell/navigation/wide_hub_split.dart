import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub segment switcher for **narrow** widths only.
///
/// On wide layouts, the same parent’s children appear under the expandable
/// side rail in [BoilerplateShellScaffold]. Segments are driven by
/// [boilerplateShellNavConfigProvider] — whichever [ShellNavParent] owns the
/// current path supplies [ShellNavLeaf] rows for the [SegmentedButton].
class WideHubSplit extends ConsumerWidget {
  const WideHubSplit({
    super.key,
    required this.child,
  });

  final Widget child;

  static const double breakpointWidth = 1100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ShellNavItem> nav = ref.watch(boilerplateShellNavConfigProvider);
    final String path = GoRouterState.of(context).uri.path;
    final ShellNavParent? parent = shellNavParentOwningPath(nav, path);
    final double w = MediaQuery.sizeOf(context).width;

    if (w < breakpointWidth && parent != null && parent.children.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ConfigurableHubSegmentPicker(parent: parent, path: path),
          Expanded(child: child),
        ],
      );
    }

    return child;
  }
}

class _ConfigurableHubSegmentPicker extends StatelessWidget {
  const _ConfigurableHubSegmentPicker({
    required this.parent,
    required this.path,
  });

  final ShellNavParent parent;
  final String path;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final ShellNavLeaf active =
        parent.matchingLeaf(path) ?? parent.children.first;
    return Material(
      color: tokens.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: SegmentedButton<String>(
          segments: <ButtonSegment<String>>[
            for (final ShellNavLeaf leaf in parent.children)
              ButtonSegment<String>(
                value: leaf.location,
                label: Text(leaf.label),
                icon: Icon(leaf.icon, size: 18),
              ),
          ],
          selected: <String>{active.location},
          onSelectionChanged: (Set<String> next) {
            GoRouter.of(context).go(next.single);
          },
        ),
      ),
    );
  }
}
