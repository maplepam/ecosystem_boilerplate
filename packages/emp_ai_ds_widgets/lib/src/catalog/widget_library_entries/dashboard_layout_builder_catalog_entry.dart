// ignore_for_file: unused_import
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/northstar_icon_catalog_panel.dart';
import 'package:emp_ai_ds_widgets/src/catalog/northstar_typography_catalog_panel.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/dashboard/dashboard_layout_preset.dart';
import 'package:emp_ai_ds_widgets/src/dashboard/reorderable_dashboard_slots.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_accordion.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_avatar.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_badge.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_banner.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_breadcrumb.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_button.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_chip.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_divider.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_file_uploader.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_filter_chip_strip.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_filter_dropdown.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_input_field.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_input_form_field.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_linear_progress.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_search_field.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_stacked_avatars.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_text_link.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_tri_state.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_drawer_entry.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_navigation_drawer.dart';
import 'package:emp_ai_ds_widgets/src/navigation/northstar_scaffold_with_drawer.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry dashboardLayoutBuilderCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'dashboard_layout_builder',
    title: 'DashboardLayoutBuilder',
    description:
        'Responsive presets for dashboard-style pages (1 / 2 / 3 columns). '
        'Pair with host state for tile visibility and order.',
    code: '''
  DashboardLayoutBuilder(
    preset: DashboardLayoutPreset.twoColumnAdaptive,
    children: [
      Card(child: SizedBox(height: 120, child: Center(child: Text('A')))),
      Card(child: SizedBox(height: 120, child: Center(child: Text('B')))),
    ],
  )
  ''',
    preview: (BuildContext context) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final double h = (c.maxWidth * 0.42).clamp(260.0, 520.0);
          return SizedBox(
            height: h,
            width: double.infinity,
            child: DashboardLayoutBuilder(
              preset: DashboardLayoutPreset.twoColumnAdaptive,
              children: <Widget>[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => catalogPreviewSnack(context, 'Dashboard tile A'),
                    child: Padding(
                      padding: const EdgeInsets.all(NorthstarSpacing.space16),
                      child: Center(
                        child: Text(
                          'Tile A (tap)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => catalogPreviewSnack(context, 'Dashboard tile B'),
                    child: Padding(
                      padding: const EdgeInsets.all(NorthstarSpacing.space16),
                      child: Center(
                        child: Text(
                          'Tile B (tap)',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}