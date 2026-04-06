import 'package:flutter/foundation.dart';

/// Stable [ValueKey] names for `integration_test` / `flutter_test`
/// ([find.byKey]).
///
/// Pass the same [automationId] from widgets ([NorthstarButton],
/// [NorthstarChip], [NorthstarDivider], [NorthstarLinearProgress], [NorthstarBadge],
/// [NorthstarTextLink], [NorthstarAvatar], [NorthstarStackedAvatars], [NorthstarAccordion],
/// [NorthstarBanner], [NorthstarBreadcrumb], [NorthstarInputField],
/// [NorthstarTextArea], [NorthstarTextAreaRichToolbar], [NorthstarFilterDropdown], [NorthstarMenuField], [NorthstarAllFiltersButton],
/// [DashboardLayoutBuilder],
/// [NorthstarNavigationDrawer], [NorthstarPaginationBar], [NorthstarDataTable], …)
/// and a unique
/// [elementId] per sub-control. Format: `ds:<automationId>:<elementId>`.
abstract final class DsAutomationKeys {
  const DsAutomationKeys._();

  /// [Scaffold] shell ([NorthstarScaffoldWithDrawer]).
  static const String elementScaffold = 'scaffold';

  /// [Drawer] panel ([NorthstarNavigationDrawer]).
  static const String elementDrawer = 'drawer';

  /// [DashboardLayoutBuilder] root.
  static const String elementDashboardLayout = 'dashboard_layout';

  /// [ReorderableDashboardSlotList] list.
  static const String elementDashboardReorderList = 'dashboard_reorder_list';

  /// Root / surface — use for the outermost keyed subtree of a component.
  static const String elementButton = 'button';

  static const String elementLabel = 'label';

  static const String elementLeadingIcon = 'leading_icon';

  static const String elementTrailingIcon = 'trailing_icon';

  static const String elementProgress = 'progress';

  /// Single icon in [NorthstarButtonVariant.iconOnly] (no separate leading/trailing).
  static const String elementIcon = 'icon';

  /// [NorthstarAvatar] keyed surface (glyph area / outer face).
  static const String elementAvatar = 'avatar';

  static const String elementAvatarTitle = 'avatar_title';

  static const String elementAvatarSubtitle = 'avatar_subtitle';

  static const String elementAvatarChevron = 'avatar_chevron';

  static const String elementAvatarIcon = 'avatar_icon';

  static const String elementAvatarInitials = 'avatar_initials';

  static const String elementAvatarBadge = 'avatar_badge';

  /// [NorthstarStackedAvatars] root.
  static const String elementStackedAvatars = 'stacked_avatars';

  /// One stacked slot; append index, e.g. `'${elementStackedAvatarSlot}_0'`.
  static const String elementStackedAvatarSlot = 'stacked_avatar_slot';

  static const String elementStackedAvatarsOverflow =
      'stacked_avatars_overflow';

  /// [NorthstarChip] surface.
  static const String elementChip = 'chip';

  static const String elementChipLabel = 'chip_label';

  static const String elementChipLeading = 'chip_leading';

  static const String elementChipTrailing = 'chip_trailing';

  static const String elementChipClose = 'chip_close';

  /// Filter chip selected-state checkmark.
  static const String elementChipFilterCheck = 'chip_filter_check';

  /// [NorthstarDivider] root.
  static const String elementDivider = 'divider';

  /// [NorthstarLinearProgress] root.
  static const String elementLinearProgress = 'linear_progress';

  /// [NorthstarBadge] / [NorthstarBadged] surface.
  static const String elementBadge = 'badge';

  /// [NorthstarBadge] text (digits / pill).
  static const String elementBadgeLabel = 'badge_label';

  /// [NorthstarTextLink] label.
  static const String elementTextLink = 'text_link';

  /// [NorthstarAccordion] root.
  static const String elementAccordion = 'accordion';

  /// [NorthstarAccordion] trailing chevron.
  static const String elementAccordionChevron = 'accordion_chevron';

  /// [NorthstarBanner] root.
  static const String elementBanner = 'banner';

  /// [NorthstarBanner] dismiss control.
  static const String elementBannerDismiss = 'banner_dismiss';

  /// [NorthstarInputField] clear action (when [NorthstarInputField.clearable]).
  static const String elementInputClear = 'input_clear';

  /// [NorthstarInputField] label-row info control.
  static const String elementInputInfo = 'input_info';

  /// [NorthstarTextArea] label row.
  static const String elementTextAreaLabel = 'text_area_label';

  /// [NorthstarTextArea] helper line.
  static const String elementTextAreaHelper = 'text_area_helper';

  /// [NorthstarTextArea] main [TextField] (standard / rich body).
  static const String elementTextAreaField = 'text_area_field';

  /// [NorthstarTextArea] validation line under the shell.
  static const String elementTextAreaError = 'text_area_error';

  /// [NorthstarTextArea] rich toolbar control prefix (`…_$id`).
  static const String elementTextAreaToolbar = 'text_area_toolbar';

  /// [NorthstarTextAreaRichToolbar] root strip (below: `…_$id` per control).
  static const String elementTextAreaRichToolbar = 'text_area_rich_toolbar';

  /// [NorthstarTextArea] chips variant inline add field.
  static const String elementTextAreaChipsInput = 'text_area_chips_input';

  /// [NorthstarFilterDropdown] surface / hit target.
  static const String elementFilterDropdown = 'filter_dropdown';

  /// [NorthstarMenuField] closed trigger.
  static const String elementMenuTrigger = 'menu_trigger';

  /// [NorthstarMenuPanel] root surface.
  static const String elementMenuPanel = 'menu_panel';

  /// Search field inside [NorthstarMenuPanel].
  static const String elementMenuSearch = 'menu_search';

  /// [NorthstarMenuPanel] row; composed as `…_${item.id}`.
  static const String elementMenuItem = 'menu_item';

  /// [NorthstarAllFiltersButton] surface / hit target.
  static const String elementAllFilters = 'all_filters';

  /// [NorthstarBreadcrumb] root row.
  static const String elementBreadcrumb = 'breadcrumb';

  /// [NorthstarBreadcrumb] segment (`<index>`) or `…_current` for current page.
  static const String elementBreadcrumbSegment = 'breadcrumb_segment';

  /// [NorthstarBreadcrumb] overflow (`…`) control.
  static const String elementBreadcrumbOverflow = 'breadcrumb_overflow';

  /// [NorthstarFileUploader] root column.
  static const String elementFileUploader = 'file_uploader';

  /// [NorthstarFileUploader] drop zone hit target.
  static const String elementFileUploaderDropZone = 'file_uploader_drop_zone';

  /// Wrapper around the add action; sub-keys use [NorthstarButton] (`button`, …).
  static const String elementFileUploaderAddButton = 'file_uploader_add';

  /// Global validation message under the control.
  static const String elementFileUploaderGlobalError =
      'file_uploader_global_error';

  /// File row root; composed as `…_${item.id}`.
  static const String elementFileUploaderRow = 'file_uploader_row';

  /// Remove control; composed as `…_${item.id}`.
  static const String elementFileUploaderRemove = 'file_uploader_remove';

  /// [NorthstarPaginationBar] root.
  static const String elementPaginationBar = 'pagination_bar';

  static const String elementPaginationPrev = 'pagination_prev';

  static const String elementPaginationNext = 'pagination_next';

  /// Page number button; composed as `…_${page}`.
  static const String elementPaginationPage = 'pagination_page';

  /// Ellipsis / skip control; composed as `…_${slotIndex}`.
  static const String elementPaginationEllipsis = 'pagination_ellipsis';

  static const String elementPaginationSummary = 'pagination_summary';

  static const String elementPaginationPageSize = 'pagination_page_size';

  static const String elementPaginationGoToField = 'pagination_go_to';

  /// [NorthstarDataTable] scroll/surface root.
  static const String elementDataTable = 'data_table';

  /// Header cell; composed as `…_${columnIndex}`.
  static const String elementDataTableHeader = 'data_table_header';

  /// Select-all checkbox in header when row selection is enabled.
  static const String elementDataTableHeaderSelectAll =
      'data_table_header_select_all';

  /// Long-press drag handle on a column header (when column reorder is enabled).
  static const String elementDataTableHeaderColumnDrag =
      'data_table_header_column_drag';

  /// Body row; composed as `…_${rowIndex}`.
  static const String elementDataTableRow = 'data_table_row';

  /// Returns null when [automationId] is null or empty (no keys applied).
  static ValueKey<String>? part(String? automationId, String elementId) {
    if (automationId == null || automationId.isEmpty) {
      return null;
    }
    return ValueKey<String>('ds:$automationId:$elementId');
  }
}
