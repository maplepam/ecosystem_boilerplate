import 'package:flutter/foundation.dart';

/// Stable [ValueKey] names for `integration_test` / `flutter_test`
/// ([find.byKey]).
///
/// Pass the same [automationId] from widgets ([NorthstarButton],
/// [NorthstarChip], [NorthstarDivider], [NorthstarLinearProgress], [NorthstarBadge],
/// [NorthstarTextLink], [NorthstarAvatar], [NorthstarStackedAvatars], [NorthstarAccordion],
/// [NorthstarBanner], [NorthstarBreadcrumb],
/// [DashboardLayoutBuilder],
/// [NorthstarNavigationDrawer], …) and a unique
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

  static const String elementStackedAvatarsOverflow = 'stacked_avatars_overflow';

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

  /// [NorthstarBreadcrumb] root row.
  static const String elementBreadcrumb = 'breadcrumb';

  /// [NorthstarBreadcrumb] segment (`<index>`) or `…_current` for current page.
  static const String elementBreadcrumbSegment = 'breadcrumb_segment';

  /// [NorthstarBreadcrumb] overflow (`…`) control.
  static const String elementBreadcrumbOverflow = 'breadcrumb_overflow';

  /// Returns null when [automationId] is null or empty (no keys applied).
  static ValueKey<String>? part(String? automationId, String elementId) {
    if (automationId == null || automationId.isEmpty) {
      return null;
    }
    return ValueKey<String>('ds:$automationId:$elementId');
  }
}
