/// Northstar **Filter** toolbar: [NorthstarFilterDropdown], [NorthstarAllFiltersButton],
/// [NorthstarFilterGroup], plus [showNorthstarFilterMenu] to anchor a popup under a
/// filter chip.
///
/// ## Who owns what
///
/// | Piece | Your code |
/// |----|----|
/// | **Option list** | Constants, API models, repository — *not* a widget parameter. |
/// | **Selected value(s)** | `State`, Riverpod `Notifier`, Bloc, etc. |
/// | **Overlays** | You call [showMenu], [showModalBottomSheet], `Navigator`, … |
/// | **Chrome** | These widgets: border, hover, label, `+N` badge, chevron. |
///
/// ## 1. Single-select dropdown (popup menu)
///
/// Store one `String?` (or an enum / id). Put a [GlobalKey] on the dropdown so the
/// menu opens under it. Use [showNorthstarFilterMenu] or copy its [RelativeRect] math.
///
/// ```dart
/// class _ExampleState extends State<Example> {
///   final GlobalKey _statusKey = GlobalKey();
///   static const List<String> _options = ['Open', 'In progress', 'Done'];
///   String? _status;
///
///   @override
///   Widget build(BuildContext context) {
///     return NorthstarFilterDropdown(
///       key: _statusKey,
///       leadingIcon: Icons.flag_outlined,
///       placeholder: 'Status',
///       valueLabel: _status,
///       onTap: () async {
///         final String? picked = await showNorthstarFilterMenu<String>(
///           context: context,
///           anchorKey: _statusKey,
///           items: [
///             const PopupMenuItem(value: '', child: Text('Any')),
///             for (final String o in _options)
///               PopupMenuItem(value: o, child: Text(o)),
///           ],
///         );
///         if (!context.mounted || picked == null) return;
///         setState(() => _status = picked.isEmpty ? null : picked);
///       },
///     );
///   }
/// }
/// ```
///
/// ## 2. Multi-select → first label + **+N** badge
///
/// Keep a `List<String>` or `Set<String>`. Pass the first item as [NorthstarFilterDropdown.valueLabel]
/// and `additionalSelectionCount: max(0, length - 1)`.
///
/// ```dart
/// final List<String> cities = ['Sydney', 'Melbourne', 'Brisbane'];
/// NorthstarFilterDropdown(
///   leadingIcon: Icons.place_outlined,
///   placeholder: 'Location',
///   valueLabel: cities.isEmpty ? null : cities.first,
///   additionalSelectionCount: cities.length > 1 ? cities.length - 1 : 0,
///   onTap: () => _openCityPicker(context), // bottom sheet with checkboxes → setState
/// );
/// ```
///
/// ## 3. Disabled (no menu)
///
/// ```dart
/// NorthstarFilterDropdown(
///   leadingIcon: Icons.lock_outline,
///   placeholder: 'Locked',
///   enabled: false,
///   onTap: null,
/// );
/// ```
///
/// ## 4. **All filters** button (overflow / summary)
///
/// [NorthstarAllFiltersButton.activeFilterCount] is typically the number of facets
/// that are non-default. [onPressed] opens a sheet, drawer, or full-screen filter UI.
///
/// ```dart
/// int _activeCount() =>
///     (role != null ? 1 : 0) + (locations.isNotEmpty ? 1 : 0);
///
/// NorthstarAllFiltersButton(
///   label: 'All filters',
///   activeFilterCount: _activeCount(),
///   onPressed: () => showModalBottomSheet(context: context, builder: …),
/// );
/// ```
///
/// ## 5. Full bar ([NorthstarFilterGroup])
///
/// ```dart
/// NorthstarFilterGroup(
///   padding: const EdgeInsets.all(NorthstarSpacing.space16),
///   children: [
///     NorthstarSearchField(hintText: 'Search…'), // optional leading search
///     // up to ~3 [NorthstarFilterDropdown]s, then:
///     NorthstarAllFiltersButton(
///       activeFilterCount: 4,
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
library;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import '../testing/ds_automation_keys.dart';
import 'northstar_badge.dart';

/// Opens [showMenu] with its [RelativeRect] aligned under the widget that owns
/// [anchorKey] (the filter chip’s [GlobalKey]).
///
/// Returns the selected value, or `null` if the menu was dismissed. Use
/// [anchorKey] on the same widget as [NorthstarFilterDropdown.key].
Future<T?> showNorthstarFilterMenu<T>({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<PopupMenuEntry<T>> items,
}) async {
  final BuildContext? buttonContext = anchorKey.currentContext;
  if (buttonContext == null || !buttonContext.mounted) {
    return null;
  }
  final RenderBox button = buttonContext.findRenderObject()! as RenderBox;
  final RenderBox overlay =
      Overlay.of(buttonContext).context.findRenderObject()! as RenderBox;
  final Offset origin =
      button.localToGlobal(Offset.zero, ancestor: overlay);
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromLTWH(
      origin.dx,
      origin.dy + button.size.height,
      button.size.width,
      0,
    ),
    Offset.zero & overlay.size,
  );
  return showMenu<T>(
    context: buttonContext,
    position: position,
    items: items,
  );
}

/// **Catalog / tests:** force hover or pressed paint without a pointer.
enum NorthstarFilterDropdownInteractionPreview {
  none,
  hovered,
  pressed,
}

/// Figma **Filter dropdown**: rounded **8** container, **required** [leadingIcon],
/// [placeholder] when empty, [valueLabel] when filled (design **20** char cap +
/// **124** logical px max width + ellipsis), optional **+N** [additionalSelectionCount]
/// badge, trailing chevron. [onTap] should open your menu/sheet; the widget does
/// not build overlays. Use [showNorthstarFilterMenu] for a typical anchored
/// [showMenu].
///
/// Colors follow [ColorScheme] (hover ≈ light primary tint + primary border).
///
/// **Examples:** single-select, multi-select `+N`, disabled, group + all-filters —
/// see the library doc comment at the top of `northstar_filter_dropdown.dart`.
@immutable
class NorthstarFilterDropdown extends StatefulWidget {
  const NorthstarFilterDropdown({
    super.key,
    required this.leadingIcon,
    required this.placeholder,
    this.valueLabel,
    this.additionalSelectionCount = 0,
    this.onTap,
    this.enabled = true,
    this.showChevron = true,
    this.labelMaxCharacters = 20,
    this.maxLabelWidth = 124,
    this.iconSize = 20,
    this.automationId,
    this.interactionPreview = NorthstarFilterDropdownInteractionPreview.none,
    this.padding = const EdgeInsets.symmetric(
      horizontal: NorthstarSpacing.space12,
      vertical: NorthstarSpacing.space8,
    ),
  }) : assert(labelMaxCharacters >= 1),
       assert(maxLabelWidth > 0),
       assert(additionalSelectionCount >= 0);

  final IconData leadingIcon;

  /// Shown when [valueLabel] is null or empty.
  final String placeholder;

  /// Primary selection (first facet); empty/null → placeholder state.
  final String? valueLabel;

  /// Extra selections beyond [valueLabel]; when &gt; 0 shows a **+N** pill.
  final int additionalSelectionCount;

  final VoidCallback? onTap;

  final bool enabled;

  final bool showChevron;

  /// Design cap on label characters (before ellipsis width constraint).
  final int labelMaxCharacters;

  /// Max width of the label text area (Figma **124px**).
  final double maxLabelWidth;

  final double iconSize;

  final String? automationId;

  final NorthstarFilterDropdownInteractionPreview interactionPreview;

  final EdgeInsetsGeometry padding;

  static String _clipLabel(String raw, int maxChars) {
    if (raw.length <= maxChars) {
      return raw;
    }
    if (maxChars <= 1) {
      return '…';
    }
    return '${raw.substring(0, maxChars - 1)}…';
  }

  @override
  State<NorthstarFilterDropdown> createState() =>
      _NorthstarFilterDropdownState();
}

class _NorthstarFilterDropdownState extends State<NorthstarFilterDropdown> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _filled {
    final String? v = widget.valueLabel;
    return v != null && v.trim().isNotEmpty;
  }

  String get _textForDisplay {
    if (_filled) {
      return NorthstarFilterDropdown._clipLabel(
        widget.valueLabel!.trim(),
        widget.labelMaxCharacters,
      );
    }
    return NorthstarFilterDropdown._clipLabel(
      widget.placeholder,
      widget.labelMaxCharacters,
    );
  }

  bool get _effectiveHover =>
      widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.hovered ||
      (_hovering && widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.none);

  bool get _effectivePressed =>
      widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.pressed ||
      (_pressed && widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.none);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool canTap = widget.enabled && widget.onTap != null;

    final Color borderColor;
    final Color bgColor;
    final Color fgColor;
    if (!widget.enabled) {
      borderColor = scheme.outlineVariant;
      bgColor = scheme.surfaceContainerLow;
      fgColor = scheme.onSurface.withValues(alpha: 0.38);
    } else if (_effectivePressed || _effectiveHover) {
      borderColor = scheme.primary;
      bgColor = Color.alphaBlend(
        scheme.primary.withValues(alpha: _effectivePressed ? 0.14 : 0.08),
        scheme.surface,
      );
      fgColor = scheme.primary;
    } else {
      borderColor = scheme.outlineVariant;
      bgColor = scheme.surface;
      fgColor = _filled ? scheme.onSurface : scheme.onSurfaceVariant;
    }

    final TextStyle textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fgColor,
        );

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          widget.leadingIcon,
          size: widget.iconSize,
          color: fgColor,
        ),
        const SizedBox(width: NorthstarSpacing.space8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxLabelWidth),
          child: Text(
            _textForDisplay,
            key: DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementLabel),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
        if (widget.additionalSelectionCount > 0) ...<Widget>[
          SizedBox(width: NorthstarSpacing.space8),
          _PlusCountBadge(
            count: widget.additionalSelectionCount,
            foreground: fgColor,
            borderColor: borderColor,
            backgroundColor: bgColor,
          ),
        ],
        if (widget.showChevron) ...<Widget>[
          SizedBox(width: NorthstarSpacing.space8),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: fgColor,
          ),
        ],
      ],
    );

    return MouseRegion(
      onEnter: (_) {
        if (canTap) {
          setState(() => _hovering = true);
        }
      },
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
          side: BorderSide(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: DsAutomationKeys.part(
            widget.automationId,
            DsAutomationKeys.elementFilterDropdown,
          ),
          onTap: canTap ? widget.onTap : null,
          borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
          onHighlightChanged: canTap
              ? (bool v) => setState(() => _pressed = v)
              : null,
          child: Padding(
            padding: widget.padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PlusCountBadge extends StatelessWidget {
  const _PlusCountBadge({
    required this.count,
    required this.foreground,
    required this.borderColor,
    required this.backgroundColor,
  });

  final int count;
  final Color foreground;
  final Color borderColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final String text = '+$count';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(foreground.withValues(alpha: 0.12), backgroundColor),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space8,
          vertical: NorthstarSpacing.space2,
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground,
                height: 1,
              ),
        ),
      ),
    );
  }
}

/// **All filters** control: filter icon + label + optional active-count badge
/// (Figma **Filter / Button**). Matches dropdown height/padding for toolbar rows.
/// Drive [activeFilterCount] from your filter model; [onPressed] opens overflow UI.
/// See the library doc on this file for a full-bar example.
@immutable
class NorthstarAllFiltersButton extends StatefulWidget {
  const NorthstarAllFiltersButton({
    super.key,
    this.label = 'All filters',
    this.activeFilterCount = 0,
    this.onPressed,
    this.enabled = true,
    this.filterIcon = Icons.filter_list_rounded,
    this.automationId,
    this.interactionPreview = NorthstarFilterDropdownInteractionPreview.none,
    this.padding = const EdgeInsets.symmetric(
      horizontal: NorthstarSpacing.space12,
      vertical: NorthstarSpacing.space8,
    ),
  }) : assert(activeFilterCount >= 0);

  final String label;

  /// Total active facets; **0** hides the badge.
  final int activeFilterCount;

  final VoidCallback? onPressed;

  final bool enabled;

  final IconData filterIcon;

  final String? automationId;

  final NorthstarFilterDropdownInteractionPreview interactionPreview;

  final EdgeInsetsGeometry padding;

  @override
  State<NorthstarAllFiltersButton> createState() =>
      _NorthstarAllFiltersButtonState();
}

class _NorthstarAllFiltersButtonState extends State<NorthstarAllFiltersButton> {
  bool _hovering = false;
  bool _pressed = false;

  bool get _effectiveHover =>
      widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.hovered ||
      (_hovering && widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.none);

  bool get _effectivePressed =>
      widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.pressed ||
      (_pressed && widget.interactionPreview == NorthstarFilterDropdownInteractionPreview.none);

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool canTap = widget.enabled && widget.onPressed != null;

    final Color borderColor;
    final Color bgColor;
    final Color fgColor;
    if (!widget.enabled) {
      borderColor = scheme.outlineVariant;
      bgColor = scheme.surfaceContainerLow;
      fgColor = scheme.onSurface.withValues(alpha: 0.38);
    } else if (_effectivePressed || _effectiveHover) {
      borderColor = scheme.primary;
      bgColor = Color.alphaBlend(
        scheme.primary.withValues(alpha: _effectivePressed ? 0.14 : 0.08),
        scheme.surface,
      );
      fgColor = scheme.primary;
    } else {
      borderColor = scheme.outlineVariant;
      bgColor = scheme.surface;
      fgColor = scheme.onSurface;
    }

    final TextStyle textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fgColor,
        );

    final String badgeText = widget.activeFilterCount > 99
        ? '99+'
        : '${widget.activeFilterCount}';

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(widget.filterIcon, size: 20, color: fgColor),
        SizedBox(width: NorthstarSpacing.space8),
        Text(
          widget.label,
          key: DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementLabel),
          style: textStyle,
        ),
        if (widget.activeFilterCount > 0) ...<Widget>[
          SizedBox(width: NorthstarSpacing.space8),
          NorthstarBadge.label(
            semantic: NorthstarBadgeSemantic.info,
            text: badgeText,
            backgroundColor: Color.alphaBlend(
              fgColor.withValues(alpha: 0.15),
              bgColor,
            ),
            foregroundColor: fgColor,
            automationId: widget.automationId != null
                ? '${widget.automationId}_badge'
                : null,
          ),
        ],
      ],
    );

    return MouseRegion(
      onEnter: (_) {
        if (canTap) {
          setState(() => _hovering = true);
        }
      },
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
          side: BorderSide(color: borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: DsAutomationKeys.part(
            widget.automationId,
            DsAutomationKeys.elementAllFilters,
          ),
          onTap: canTap ? widget.onPressed : null,
          borderRadius: BorderRadius.circular(NorthstarSpacing.space8),
          onHighlightChanged: canTap
              ? (bool v) => setState(() => _pressed = v)
              : null,
          child: Padding(
            padding: widget.padding,
            child: row,
          ),
        ),
      ),
    );
  }
}

/// Horizontal filter **toolbar** row: **8** logical px between children (Figma
/// `gap-8`), optional **16** padding around the group (`padding-all-16`).
///
/// Compose with [NorthstarFilterDropdown], an expandable search field, and
/// [NorthstarAllFiltersButton]. The design recommends up to **three** inline
/// dropdowns before using **All filters** for overflow.
@immutable
class NorthstarFilterGroup extends StatelessWidget {
  const NorthstarFilterGroup({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(NorthstarSpacing.space16),
    this.gap = NorthstarSpacing.space8,
  });

  final List<Widget> children;

  /// Outer padding for the whole bar (Figma **16**).
  final EdgeInsetsGeometry padding;

  /// Space between consecutive children (Figma **8**).
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: gap),
            children[i],
          ],
        ],
      ),
    );
  }
}
