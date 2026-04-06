import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_chip.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// One row in [NorthstarMenuPanel] / [NorthstarMenuField].
@immutable
class NorthstarMenuItemData {
  const NorthstarMenuItemData({
    required this.id,
    required this.label,
    this.subtitle,
    this.leadingIcon,
    this.avatarInitials,
    this.trailingChevron = false,
    this.enabled = true,
    this.destructive = false,
  });

  final String id;
  final String label;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? avatarInitials;
  final bool trailingChevron;
  final bool enabled;
  final bool destructive;
}

/// Single vs multi selection in [NorthstarMenuField].
enum NorthstarMenuSelectionMode {
  /// At most one selected id; menu closes after a choice (when mounted).
  single,

  /// Any number of ids; menu stays open; rows use checkboxes when
  /// [NorthstarMenuField.showCheckboxesInMenu] is true.
  multiple,
}

/// How the closed field summarizes the current value(s).
enum NorthstarMenuClosedDisplayMode {
  /// One label, or comma-separated labels when multi.
  summary,

  /// First label plus “+N more” when multi.
  firstPlusMore,

  /// Removable [NorthstarChip] input tags below the trigger.
  chipsBelowField,

  /// Removable chips inside the trigger next to the chevron.
  chipsInsideField,
}

/// Optional menu chrome (back + title above list).
@immutable
class NorthstarMenuHeaderData {
  const NorthstarMenuHeaderData({
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;
}

/// Scrollable menu surface: optional header, optional search, item list.
///
/// Guidelines: **8** px radius, list region max height **320**; long labels wrap
/// with leading controls top-aligned.
class NorthstarMenuPanel extends StatelessWidget {
  const NorthstarMenuPanel({
    super.key,
    required this.filteredItems,
    required this.selectionMode,
    required this.selectedIds,
    required this.onItemTap,
    this.header,
    this.showSearch = false,
    this.searchController,
    this.onSearchChanged,
    this.searchHint = 'Search for keyword',
    this.showCheckboxes = false,
    this.listMaxHeight = 320,
    this.minWidth = 178,
    this.maxWidth = 322,
    this.automationId,
  });

  final List<NorthstarMenuItemData> filteredItems;
  final NorthstarMenuSelectionMode selectionMode;
  final Set<String> selectedIds;
  final void Function(NorthstarMenuItemData item) onItemTap;

  final NorthstarMenuHeaderData? header;
  final bool showSearch;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;
  final bool showCheckboxes;
  final double listMaxHeight;
  final double minWidth;
  final double maxWidth;
  final String? automationId;

  static bool _matchesQuery(NorthstarMenuItemData item, String q) {
    if (q.isEmpty) {
      return true;
    }
    final String lower = q.toLowerCase();
    return item.label.toLowerCase().contains(lower) ||
        (item.subtitle?.toLowerCase().contains(lower) ?? false);
  }

  /// Filters [items] by [query] (label + subtitle, case-insensitive).
  static List<NorthstarMenuItemData> filter(
    List<NorthstarMenuItemData> items,
    String query,
  ) {
    if (query.trim().isEmpty) {
      return List<NorthstarMenuItemData>.from(items);
    }
    return items
        .where((NorthstarMenuItemData e) => _matchesQuery(e, query.trim()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      !showSearch || searchController != null,
      'searchController is required when showSearch is true',
    );
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Material(
      key: DsAutomationKeys.part(
          automationId, DsAutomationKeys.elementMenuPanel),
      elevation: 6,
      shadowColor: scheme.shadow.withValues(alpha: 0.2),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (header != null) _MenuHeader(data: header!),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  NorthstarSpacing.space12,
                  NorthstarSpacing.space8,
                  NorthstarSpacing.space12,
                  NorthstarSpacing.space8,
                ),
                child: TextField(
                  key: DsAutomationKeys.part(
                    automationId,
                    DsAutomationKeys.elementMenuSearch,
                  ),
                  onChanged: onSearchChanged,
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: searchHint,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(NorthstarSpacing.space8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: NorthstarSpacing.space8,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxHeight),
              child: filteredItems.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(NorthstarSpacing.space24),
                      child: Center(
                        child: Text(
                          'No result found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : Scrollbar(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          vertical: NorthstarSpacing.space4,
                        ),
                        itemCount: filteredItems.length,
                        separatorBuilder: (_, __) => const SizedBox.shrink(),
                        itemBuilder: (BuildContext context, int index) {
                          final NorthstarMenuItemData item =
                              filteredItems[index];
                          final bool selected = selectedIds.contains(item.id);
                          return _NorthstarMenuItemRow(
                            item: item,
                            selected: selected,
                            selectionMode: selectionMode,
                            showCheckbox: showCheckboxes,
                            automationId: automationId,
                            onTap: () => onItemTap(item),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.data});

  final NorthstarMenuHeaderData data;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NorthstarSpacing.space4,
        NorthstarSpacing.space8,
        NorthstarSpacing.space8,
        NorthstarSpacing.space4,
      ),
      child: Row(
        children: <Widget>[
          if (data.onBack != null)
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: data.onBack,
            ),
          Expanded(
            child: Text(
              data.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NorthstarMenuItemRow extends StatefulWidget {
  const _NorthstarMenuItemRow({
    required this.item,
    required this.selected,
    required this.selectionMode,
    required this.showCheckbox,
    required this.onTap,
    this.automationId,
  });

  final NorthstarMenuItemData item;
  final bool selected;
  final NorthstarMenuSelectionMode selectionMode;
  final bool showCheckbox;
  final VoidCallback onTap;
  final String? automationId;

  @override
  State<_NorthstarMenuItemRow> createState() => _NorthstarMenuItemRowState();
}

class _NorthstarMenuItemRowState extends State<_NorthstarMenuItemRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final NorthstarMenuItemData item = widget.item;
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool enabled = item.enabled;
    final bool destructive = item.destructive;

    Color bg = Colors.transparent;
    Color primaryTextColor = scheme.onSurface;
    Color secondaryTextColor = scheme.onSurfaceVariant;

    if (!enabled) {
      primaryTextColor = scheme.onSurfaceVariant.withValues(alpha: 0.45);
      secondaryTextColor = scheme.onSurfaceVariant.withValues(alpha: 0.45);
    } else if (destructive && !widget.selected) {
      primaryTextColor = scheme.error;
      secondaryTextColor = scheme.error.withValues(alpha: 0.8);
    } else if (widget.selected &&
        widget.selectionMode == NorthstarMenuSelectionMode.single) {
      bg = scheme.primary.withValues(alpha: 0.08);
      primaryTextColor = scheme.primary;
      secondaryTextColor = scheme.primary.withValues(alpha: 0.85);
    } else if (_hover && enabled) {
      bg = const Color(0xFFF8FAFC);
    }

    final bool multiCheckbox = widget.showCheckbox &&
        widget.selectionMode == NorthstarMenuSelectionMode.multiple;

    Widget? leading;
    if (multiCheckbox) {
      final Widget box = Checkbox(
        value: widget.selected,
        onChanged: enabled
            ? (_) {
                widget.onTap();
              }
            : null,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
      if (item.avatarInitials != null && item.avatarInitials!.isNotEmpty) {
        leading = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            box,
            const SizedBox(width: NorthstarSpacing.space8),
            CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                item.avatarInitials!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      } else if (item.leadingIcon != null) {
        leading = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            box,
            const SizedBox(width: NorthstarSpacing.space8),
            Icon(
              item.leadingIcon,
              size: 20,
              color: !enabled
                  ? primaryTextColor
                  : destructive
                      ? scheme.error
                      : scheme.onSurfaceVariant,
            ),
          ],
        );
      } else {
        leading = box;
      }
    } else if (item.avatarInitials != null && item.avatarInitials!.isNotEmpty) {
      leading = CircleAvatar(
        radius: 18,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          item.avatarInitials!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (item.leadingIcon != null) {
      leading = Icon(
        item.leadingIcon,
        size: 20,
        color: !enabled
            ? primaryTextColor
            : destructive
                ? scheme.error
                : scheme.onSurfaceVariant,
      );
    }

    final TextStyle titleStyle = theme.textTheme.bodyMedium!.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: primaryTextColor,
    );
    final TextStyle? subStyle = item.subtitle == null
        ? null
        : theme.textTheme.bodySmall!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: secondaryTextColor,
          );

    return MouseRegion(
      onEnter: (_) {
        if (enabled) {
          setState(() => _hover = true);
        }
      },
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: enabled ? widget.onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: NorthstarSpacing.space12,
              vertical: NorthstarSpacing.space12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: leading,
                  ),
                  const SizedBox(width: NorthstarSpacing.space8),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.label,
                        key: DsAutomationKeys.part(
                          widget.automationId,
                          '${DsAutomationKeys.elementMenuItem}_${item.id}',
                        ),
                        style: titleStyle,
                        softWrap: true,
                      ),
                      if (subStyle != null && item.subtitle != null)
                        Text(
                          item.subtitle!,
                          style: subStyle,
                          softWrap: true,
                        ),
                    ],
                  ),
                ),
                if (item.trailingChevron)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: NorthstarSpacing.space8,
                      top: 2,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: primaryTextColor,
                    ),
                  ),
                if (widget.selected &&
                    widget.selectionMode == NorthstarMenuSelectionMode.single)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: NorthstarSpacing.space8,
                      top: 2,
                    ),
                    child: Icon(Icons.check, size: 20, color: scheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Anchored dropdown field that opens a [NorthstarMenuPanel] overlay.
class NorthstarMenuField extends StatefulWidget {
  const NorthstarMenuField({
    super.key,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
    this.selectionMode = NorthstarMenuSelectionMode.single,
    this.closedDisplayMode = NorthstarMenuClosedDisplayMode.summary,
    this.placeholder = 'Select',
    this.label,
    this.enabled = true,
    this.showSearchInMenu = false,
    this.searchHint = 'Search for keyword',
    this.menuHeader,
    this.showCheckboxesInMenu = false,
    this.matchTriggerWidth = true,
    this.menuWidth,
    this.automationId,
  });

  final List<NorthstarMenuItemData> items;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;
  final NorthstarMenuSelectionMode selectionMode;
  final NorthstarMenuClosedDisplayMode closedDisplayMode;
  final String placeholder;
  final String? label;
  final bool enabled;
  final bool showSearchInMenu;
  final String searchHint;
  final NorthstarMenuHeaderData? menuHeader;
  final bool showCheckboxesInMenu;
  final bool matchTriggerWidth;
  final double? menuWidth;
  final String? automationId;

  @override
  State<NorthstarMenuField> createState() => _NorthstarMenuFieldState();
}

class _NorthstarMenuFieldState extends State<NorthstarMenuField> {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final TextEditingController _menuSearchController = TextEditingController();
  double _triggerWidth = 280;

  @override
  void dispose() {
    _menuSearchController.dispose();
    super.dispose();
  }

  void _closeOverlay() {
    _portal.hide();
    _menuSearchController.clear();
    setState(() {});
  }

  void _openOverlay() {
    _menuSearchController.clear();
    _portal.show();
  }

  void _handleItemTap(NorthstarMenuItemData item) {
    if (!item.enabled) {
      return;
    }
    final Set<String> next = Set<String>.from(widget.selectedIds);
    if (widget.selectionMode == NorthstarMenuSelectionMode.single) {
      next
        ..clear()
        ..add(item.id);
      widget.onChanged(next);
      _closeOverlay();
    } else {
      if (next.contains(item.id)) {
        next.remove(item.id);
      } else {
        next.add(item.id);
      }
      widget.onChanged(next);
    }
  }

  String? _labelForId(String id) {
    for (final NorthstarMenuItemData e in widget.items) {
      if (e.id == id) {
        return e.label;
      }
    }
    return null;
  }

  String _closedSummaryText() {
    if (widget.selectedIds.isEmpty) {
      return widget.placeholder;
    }
    if (widget.selectionMode == NorthstarMenuSelectionMode.single) {
      final String id = widget.selectedIds.first;
      return _labelForId(id) ?? id;
    }
    final List<String> labels =
        widget.selectedIds.map(_labelForId).whereType<String>().toList();
    if (labels.isEmpty) {
      return widget.placeholder;
    }
    return labels.join(', ');
  }

  String _closedFirstPlusMoreText() {
    if (widget.selectedIds.isEmpty) {
      return widget.placeholder;
    }
    final List<String> ordered = <String>[];
    for (final NorthstarMenuItemData e in widget.items) {
      if (widget.selectedIds.contains(e.id)) {
        ordered.add(e.label);
      }
    }
    if (ordered.isEmpty) {
      return widget.placeholder;
    }
    if (ordered.length == 1) {
      return ordered.first;
    }
    return '${ordered.first} + ${ordered.length - 1} more';
  }

  Widget _buildChips({required bool insideField}) {
    final List<Widget> chips = <Widget>[];
    for (final String id in widget.selectedIds) {
      final String? lab = _labelForId(id);
      if (lab == null) {
        continue;
      }
      chips.add(
        NorthstarChip(
          useCase: NorthstarChipUseCase.input,
          label: lab,
          showCloseButton: true,
          selected: true,
          onClose: widget.enabled
              ? () {
                  final Set<String> next = Set<String>.from(widget.selectedIds)
                    ..remove(id);
                  widget.onChanged(next);
                }
              : null,
          disabled: !widget.enabled,
          automationId: widget.automationId == null
              ? null
              : '${widget.automationId}_chip_$id',
        ),
      );
    }
    final Widget wrap = Wrap(
      spacing: NorthstarSpacing.space8,
      runSpacing: NorthstarSpacing.space8,
      children: chips,
    );
    if (insideField) {
      return wrap;
    }
    return Padding(
      padding: const EdgeInsets.only(top: NorthstarSpacing.space8),
      child: wrap,
    );
  }

  Widget _buildTriggerContent(Color fg) {
    final TextStyle style = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: fg,
        );

    switch (widget.closedDisplayMode) {
      case NorthstarMenuClosedDisplayMode.summary:
        return Text(
          _closedSummaryText(),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            color: widget.selectedIds.isEmpty
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : fg,
          ),
        );
      case NorthstarMenuClosedDisplayMode.firstPlusMore:
        return Text(
          _closedFirstPlusMoreText(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            color: widget.selectedIds.isEmpty
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : fg,
          ),
        );
      case NorthstarMenuClosedDisplayMode.chipsBelowField:
        return Text(
          widget.placeholder,
          style: style.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      case NorthstarMenuClosedDisplayMode.chipsInsideField:
        if (widget.selectedIds.isEmpty) {
          return Text(
            widget.placeholder,
            style: style.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }
        return _buildChips(insideField: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool canOpen = widget.enabled;

    final Color borderColor = scheme.outlineVariant;
    final Color bg = scheme.surface;
    final Color fg = scheme.onSurface;

    final Widget trigger = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double w = c.maxWidth.isFinite ? c.maxWidth : _triggerWidth;
        if (w > 0 && (w - _triggerWidth).abs() > 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _triggerWidth = w);
            }
          });
        }
        return Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
            side: BorderSide(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: DsAutomationKeys.part(
              widget.automationId,
              DsAutomationKeys.elementMenuTrigger,
            ),
            onTap: canOpen ? _openOverlay : null,
            borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NorthstarSpacing.space12,
                vertical: NorthstarSpacing.space12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: _buildTriggerContent(fg)),
                  const SizedBox(width: NorthstarSpacing.space8),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: fg,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final double panelW =
        (widget.menuWidth ?? (widget.matchTriggerWidth ? _triggerWidth : 280.0))
            .clamp(178.0, 322.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
        ],
        CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: (BuildContext context) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _closeOverlay,
                      child: const ColoredBox(color: Colors.transparent),
                    ),
                  ),
                  CompositedTransformFollower(
                    link: _link,
                    showWhenUnlinked: false,
                    targetAnchor: Alignment.bottomLeft,
                    followerAnchor: Alignment.topLeft,
                    offset: const Offset(0, 4),
                    child: SizedBox(
                      width: panelW,
                      child: NorthstarMenuPanel(
                        filteredItems: NorthstarMenuPanel.filter(
                          widget.items,
                          _menuSearchController.text,
                        ),
                        selectionMode: widget.selectionMode,
                        selectedIds: widget.selectedIds,
                        onItemTap: _handleItemTap,
                        header: widget.menuHeader,
                        showSearch: widget.showSearchInMenu,
                        searchController: _menuSearchController,
                        onSearchChanged: (_) => setState(() {}),
                        searchHint: widget.searchHint,
                        showCheckboxes: widget.showCheckboxesInMenu,
                        maxWidth: panelW,
                        minWidth: 178,
                        automationId: widget.automationId,
                      ),
                    ),
                  ),
                ],
              );
            },
            child: trigger,
          ),
        ),
        if (widget.closedDisplayMode ==
                NorthstarMenuClosedDisplayMode.chipsBelowField &&
            widget.selectedIds.isNotEmpty)
          _buildChips(insideField: false),
      ],
    );
  }
}
