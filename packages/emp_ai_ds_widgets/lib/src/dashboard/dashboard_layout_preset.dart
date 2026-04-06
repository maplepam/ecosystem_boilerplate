import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// High-level responsive column presets for analytics / admin home pages.
enum DashboardLayoutPreset {
  /// Single scroll column (mobile-first).
  singleColumn,

  /// 1 col narrow, 2 cols when `maxWidth >= breakpointMedium`.
  twoColumnAdaptive,

  /// Up to 3 cols when `maxWidth >= breakpointWide`.
  threeColumnWideWeb,
}

/// Default breakpoints (logical pixels). Override per host if needed.
@immutable
abstract final class DashboardLayoutBreakpoints {
  const DashboardLayoutBreakpoints._();

  static const double medium = 720;
  static const double wide = 1100;
}

/// Builds a scrollable dashboard body from [children] order.
class DashboardLayoutBuilder extends StatelessWidget {
  const DashboardLayoutBuilder({
    super.key,
    required this.preset,
    required this.children,
    this.automationId,
    this.padding = const EdgeInsets.all(NorthstarSpacing.space16),
    this.mainAxisSpacing = NorthstarSpacing.space12,
    this.crossAxisSpacing = NorthstarSpacing.space12,
  });

  final DashboardLayoutPreset preset;
  final List<Widget> children;

  /// Optional [DsAutomationKeys] root ([elementDashboardLayout]).
  final String? automationId;

  final EdgeInsets padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  int _columnsForWidth(double w) {
    return switch (preset) {
      DashboardLayoutPreset.singleColumn => 1,
      DashboardLayoutPreset.twoColumnAdaptive =>
        w >= DashboardLayoutBreakpoints.medium ? 2 : 1,
      DashboardLayoutPreset.threeColumnWideWeb => w >= DashboardLayoutBreakpoints.wide
          ? 3
          : w >= DashboardLayoutBreakpoints.medium
              ? 2
              : 1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ValueKey<String>? layoutKey = DsAutomationKeys.part(
      automationId,
      DsAutomationKeys.elementDashboardLayout,
    );

    Widget body = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int cols = _columnsForWidth(c.maxWidth);
        if (cols == 1) {
          return ListView.separated(
            padding: padding,
            itemCount: children.length,
            separatorBuilder: (_, __) => SizedBox(height: mainAxisSpacing),
            itemBuilder: (BuildContext context, int i) => children[i],
          );
        }
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: 1.4,
          ),
          itemCount: children.length,
          itemBuilder: (BuildContext context, int i) => children[i],
        );
      },
    );

    if (layoutKey != null) {
      body = KeyedSubtree(key: layoutKey, child: body);
    }
    return body;
  }
}
