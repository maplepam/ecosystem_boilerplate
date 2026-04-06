import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_nav_rail_branding.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_side_nav_tile.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';
import 'package:flutter/material.dart';

/// Host-only catalog rows (shell chrome). Prepended after DS built-ins via
/// [boilerplateWidgetCatalogAllEntries].
List<WidgetCatalogEntry> boilerplateHostShellNavigationCatalogEntries() {
  return <WidgetCatalogEntry>[
    WidgetCatalogEntry(
      id: 'shell_side_nav_tile',
      title: 'ShellSideNavTile',
      description:
          'Wide shell rail row: icon, optional label row, selected fill, and '
          'optional parent chevron (expand_more / chevron_right). Icon-only '
          'collapsed rail uses tooltip + emphasizeWhenCollapsedRail.',
      code: '''
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_side_nav_tile.dart';

ShellSideNavTile(
  icon: Icons.dashboard_rounded,
  label: 'Overview',
  showExpandedLabels: true,
  selected: true,
  nested: false,
  isExpandableParent: false,
  parentExpanded: false,
  emphasizeWhenCollapsedRail: false,
  onTap: () {},
)
''',
      preview: (BuildContext context) {
        return Material(
          color: NorthstarColorTokens.of(context).surface,
          child: Padding(
            padding: const EdgeInsets.all(NorthstarSpacing.space16),
            child: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ShellSideNavTile(
                    icon: Icons.inbox_outlined,
                    label: 'Inbox',
                    showExpandedLabels: true,
                    selected: false,
                    onTap: () {},
                  ),
                  ShellSideNavTile(
                    icon: Icons.star_rounded,
                    label: 'Starred',
                    showExpandedLabels: true,
                    selected: true,
                    onTap: () {},
                  ),
                  ShellSideNavTile(
                    icon: Icons.folder_outlined,
                    label: 'Folders',
                    showExpandedLabels: true,
                    selected: false,
                    isExpandableParent: true,
                    parentExpanded: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    WidgetCatalogEntry(
      id: 'shell_nav_rail_branding',
      title: 'ShellNavRailBranding',
      description:
          'Gradient header card for the wide shell rail when expanded; collapses '
          'to a single iconic tooltip when the rail is narrow. Uses '
          'NorthstarColorTokens.primaryContainer and surfaceContainerHigh.',
      code: '''
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_nav_rail_branding.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';

ShellNavRailBranding(
  showExpandedChrome: true,
  tokens: NorthstarColorTokens.of(context),
  title: 'My product',
  subtitle: 'Short value line for the shell.',
)
''',
      preview: (BuildContext context) {
        final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
        return Material(
          color: tokens.surface,
          child: Padding(
            padding: const EdgeInsets.all(NorthstarSpacing.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ShellNavRailBranding(
                  showExpandedChrome: true,
                  tokens: tokens,
                  title: 'Starter shell',
                  subtitle:
                      'A calm place to explore components, color, and the shell.',
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                SizedBox(
                  height: 56,
                  child: ShellNavRailBranding(
                    showExpandedChrome: false,
                    tokens: tokens,
                    title: 'Collapsed',
                    subtitle: '',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ];
}
