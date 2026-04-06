import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_paths.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_widget_catalog.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// When the window is wide enough, keeps the component list visible beside the
/// routed preview (master–detail). Narrow layouts use [child] only.
class WideWidgetCatalogSplit extends StatelessWidget {
  const WideWidgetCatalogSplit({
    super.key,
    required this.child,
  });

  final Widget child;

  /// Width at which list + detail render side by side.
  static const double breakpointWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    if (w < breakpointWidth) {
      return child;
    }

    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          width: 400,
          child: Material(
            color: tokens.surfaceContainerLow,
            child: NorthstarWidgetLibraryListPage(
              title: 'Components',
              subtitle:
                  'Select a widget to preview it on the right — same live '
                  'controls as production.',
              entries: boilerplateWidgetCatalogAllEntries(),
              onOpenEntry: (WidgetCatalogEntry e) {
                GoRouter.of(context).go(
                  BoilerplateShellPaths.widgetDetail(e.id),
                );
              },
            ),
          ),
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: tokens.outlineVariant,
        ),
        Expanded(child: child),
      ],
    );
  }
}
