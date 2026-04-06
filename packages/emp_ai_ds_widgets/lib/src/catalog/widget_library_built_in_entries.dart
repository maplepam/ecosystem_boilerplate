import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';

import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/dashboard_layout_builder_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_accordion_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_avatar_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_badge_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_banner_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_breadcrumb_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_button_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_chip_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_divider_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_drawer_entry_model_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_file_uploader_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_filter_chip_strip_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_filter_dropdown_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_icon_library_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_input_field_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_input_form_field_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_linear_progress_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_navigation_drawer_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_scaffold_with_drawer_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_search_field_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_spacing_scale_table_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_stacked_avatars_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_text_link_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_tri_state_body_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/northstar_typography_roles_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_library_entries/reorderable_dashboard_slot_list_catalog_entry.dart';

/// All built-in [WidgetCatalogEntry] values for [NorthstarWidgetLibraryPage].
List<WidgetCatalogEntry> builtInWidgetLibraryEntries() {
  return <WidgetCatalogEntry>[
      northstarButtonCatalogEntry(),
      northstarAvatarCatalogEntry(),
      northstarStackedAvatarsCatalogEntry(),
      northstarChipCatalogEntry(),
      northstarDividerCatalogEntry(),
      northstarBadgeCatalogEntry(),
      northstarTextLinkCatalogEntry(),
      northstarBreadcrumbCatalogEntry(),
      northstarLinearProgressCatalogEntry(),
      northstarIconLibraryCatalogEntry(),
      northstarTypographyRolesCatalogEntry(),
      northstarScaffoldWithDrawerCatalogEntry(),
      dashboardLayoutBuilderCatalogEntry(),
      reorderableDashboardSlotListCatalogEntry(),
      northstarNavigationDrawerCatalogEntry(),
      northstarDrawerEntryModelCatalogEntry(),
      northstarInputFieldCatalogEntry(),
      northstarInputFormFieldCatalogEntry(),
      northstarSearchFieldCatalogEntry(),
      northstarSpacingScaleTableCatalogEntry(),
      northstarAccordionCatalogEntry(),
      northstarBannerCatalogEntry(),
      northstarFilterChipStripCatalogEntry(),
      northstarFilterDropdownCatalogEntry(),
      northstarFileUploaderCatalogEntry(),
      northstarTriStateBodyCatalogEntry(),
  ];
}
