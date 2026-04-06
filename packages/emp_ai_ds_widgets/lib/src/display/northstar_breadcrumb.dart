import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import '../testing/ds_automation_keys.dart';

/// Typography scale for [NorthstarBreadcrumb] (Figma **Small** / **Large**).
enum NorthstarBreadcrumbSize {
  /// ~14px body (Figma `size-14`).
  small,

  /// ~16px body (Figma `size-16`).
  large,
}

/// One crumb in [NorthstarBreadcrumb].
///
/// Every segment except the **last** must provide [onTap]. The last segment
/// omits [onTap] to represent the **current** page (bold, not interactive).
class NorthstarBreadcrumbItem {
  const NorthstarBreadcrumbItem({
    required this.label,
    this.onTap,
    this.enabled = true,
    this.semanticsLabel,
  }) : assert(label.length > 0);

  /// Display text (truncated with ellipsis when longer than [maxLabelLength]).
  final String label;

  /// `null` marks the **current** page (must only be used for the last item).
  final VoidCallback? onTap;

  /// When false, the link is styled disabled and does not receive taps.
  final bool enabled;

  /// Optional semantics; defaults to [label].
  final String? semanticsLabel;

  /// Whether this item is the current page (non-link).
  bool get isCurrent => onTap == null;
}

/// Northstar **breadcrumb**: hierarchical trail with `/` separators, optional
/// overflow menu, and label truncation (Figma **Breadcrumb**).
///
/// **Layout:** Single line — does not wrap. When there are more than **three**
/// navigable segments before the current page, middle segments collapse into a
/// `…` menu (first link + last two links + current stay visible).
///
/// **Labels:** Longer than [maxLabelLength] characters are truncated with `…`;
/// the full label is shown in a [Tooltip] on hover.
///
/// **Tokens:** Uses [NorthstarColorTokens] for link, separator, current, and
/// disabled colors.
class NorthstarBreadcrumb extends StatelessWidget {
  const NorthstarBreadcrumb({
    super.key,
    required this.items,
    this.size = NorthstarBreadcrumbSize.small,
    this.maxLabelLength = 24,
    this.automationId,
  }) : assert(maxLabelLength > 1);

  /// Ordered trail; **last** item must be current ([NorthstarBreadcrumbItem.isCurrent]).
  final List<NorthstarBreadcrumbItem> items;

  final NorthstarBreadcrumbSize size;

  /// Max visible characters before `…` (Figma recommends **24**).
  final int maxLabelLength;

  final String? automationId;

  static const String _separator = '/';

  @override
  Widget build(BuildContext context) {
    assert(
      () {
        if (items.isEmpty) {
          throw FlutterError('NorthstarBreadcrumb.items must not be empty.');
        }
        if (!items.last.isCurrent) {
          throw FlutterError(
            'NorthstarBreadcrumb: last item must be current (omit onTap).',
          );
        }
        for (var i = 0; i < items.length - 1; i++) {
          if (items[i].onTap == null) {
            throw FlutterError(
              'NorthstarBreadcrumb: only the last item may omit onTap '
              '(index $i).',
            );
          }
        }
        return true;
      }(),
    );

    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double fontSize = switch (size) {
      NorthstarBreadcrumbSize.small => 14,
      NorthstarBreadcrumbSize.large => 16,
    };

    final TextStyle baseStyle = (textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          fontSize: fontSize,
          height: 1.25,
        );

    final TextStyle separatorStyle = baseStyle.copyWith(
      color: tokens.onSurfaceVariant,
      fontWeight: FontWeight.w400,
    );

    final List<_BreadcrumbSlot> slots = _computeSlots(items);

    final ValueKey<String>? rootKey = DsAutomationKeys.part(
      automationId,
      DsAutomationKeys.elementBreadcrumb,
    );

    final List<Widget> children = <Widget>[];
    for (var i = 0; i < slots.length; i++) {
      if (i > 0) {
        children.add(_Separator(text: _separator, style: separatorStyle));
      }
      children.add(
        _slotWidget(
          context: context,
          slot: slots[i],
          index: i,
          tokens: tokens,
          baseStyle: baseStyle,
          maxLabelLength: maxLabelLength,
          automationId: automationId,
        ),
      );
    }

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: children,
    );

    if (rootKey != null) {
      row = KeyedSubtree(key: rootKey, child: row);
    }

    return Semantics(
      label: 'Breadcrumb',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        child: row,
      ),
    );
  }
}

/// Internal: ordered pieces to render (link, overflow menu, or current).
enum _BreadcrumbSlotKind { link, overflow, current }

class _BreadcrumbSlot {
  _BreadcrumbSlot.link(this.item)
      : kind = _BreadcrumbSlotKind.link,
        hidden = null;

  _BreadcrumbSlot.overflow(this.hidden)
      : kind = _BreadcrumbSlotKind.overflow,
        item = null;

  _BreadcrumbSlot.current(this.item)
      : kind = _BreadcrumbSlotKind.current,
        hidden = null;

  final _BreadcrumbSlotKind kind;
  final NorthstarBreadcrumbItem? item;
  final List<NorthstarBreadcrumbItem>? hidden;
}

List<_BreadcrumbSlot> _computeSlots(List<NorthstarBreadcrumbItem> items) {
  final NorthstarBreadcrumbItem current = items.last;
  final List<NorthstarBreadcrumbItem> nav = items.sublist(0, items.length - 1);

  if (nav.isEmpty) {
    return <_BreadcrumbSlot>[_BreadcrumbSlot.current(current)];
  }
  if (nav.length <= 3) {
    return <_BreadcrumbSlot>[
      for (final NorthstarBreadcrumbItem n in nav) _BreadcrumbSlot.link(n),
      _BreadcrumbSlot.current(current),
    ];
  }

  final List<NorthstarBreadcrumbItem> hidden =
      nav.sublist(1, nav.length - 2);
  return <_BreadcrumbSlot>[
    _BreadcrumbSlot.link(nav.first),
    _BreadcrumbSlot.overflow(hidden),
    _BreadcrumbSlot.link(nav[nav.length - 2]),
    _BreadcrumbSlot.link(nav[nav.length - 1]),
    _BreadcrumbSlot.current(current),
  ];
}

Widget _slotWidget({
  required BuildContext context,
  required _BreadcrumbSlot slot,
  required int index,
  required NorthstarColorTokens tokens,
  required TextStyle baseStyle,
  required int maxLabelLength,
  required String? automationId,
}) {
  switch (slot.kind) {
    case _BreadcrumbSlotKind.link:
      final NorthstarBreadcrumbItem item = slot.item!;
      return _BreadcrumbLink(
        item: item,
        index: index,
        tokens: tokens,
        baseStyle: baseStyle,
        maxLabelLength: maxLabelLength,
        automationId: automationId,
      );
    case _BreadcrumbSlotKind.overflow:
      return _BreadcrumbOverflowMenu(
        hidden: slot.hidden!,
        tokens: tokens,
        baseStyle: baseStyle,
        maxLabelLength: maxLabelLength,
        automationId: automationId,
        index: index,
      );
    case _BreadcrumbSlotKind.current:
      final NorthstarBreadcrumbItem item = slot.item!;
      return _BreadcrumbCurrent(
        item: item,
        tokens: tokens,
        baseStyle: baseStyle,
        maxLabelLength: maxLabelLength,
        automationId: automationId,
        index: index,
      );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NorthstarSpacing.space8),
      child: Text(text, style: style),
    );
  }
}

String _truncatedLabel(String label, int maxLen) {
  if (label.length <= maxLen) {
    return label;
  }
  return '${label.substring(0, maxLen - 1)}…';
}

class _BreadcrumbLink extends StatefulWidget {
  const _BreadcrumbLink({
    required this.item,
    required this.index,
    required this.tokens,
    required this.baseStyle,
    required this.maxLabelLength,
    required this.automationId,
  });

  final NorthstarBreadcrumbItem item;
  final int index;
  final NorthstarColorTokens tokens;
  final TextStyle baseStyle;
  final int maxLabelLength;
  final String? automationId;

  @override
  State<_BreadcrumbLink> createState() => _BreadcrumbLinkState();
}

class _BreadcrumbLinkState extends State<_BreadcrumbLink> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final NorthstarBreadcrumbItem item = widget.item;
    final NorthstarColorTokens t = widget.tokens;
    final bool disabled = !item.enabled;
    final String shown = _truncatedLabel(item.label, widget.maxLabelLength);
    final bool truncated = shown != item.label;

    Color fg;
    if (disabled) {
      fg = t.outlineVariant;
    } else if (_pressed) {
      fg = Color.lerp(t.primary, t.onPrimaryContainer, 0.55)!;
    } else {
      fg = t.primary;
    }

    final TextStyle style = widget.baseStyle.copyWith(
      color: fg,
      fontWeight: FontWeight.w400,
      decoration: _hover && !disabled ? TextDecoration.underline : null,
      decorationColor: fg,
    );

    final Widget text = Text(
      shown,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.clip,
      key: DsAutomationKeys.part(
        widget.automationId,
        '${DsAutomationKeys.elementBreadcrumbSegment}_${widget.index}',
      ),
    );

    final Widget core = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: disabled
            ? null
            : () {
                item.onTap?.call();
              },
        child: Semantics(
          button: true,
          label: item.semanticsLabel ?? item.label,
          enabled: !disabled,
          child: truncated
              ? Tooltip(
                  message: item.label,
                  child: text,
                )
              : text,
        ),
      ),
    );

    return core;
  }
}

class _BreadcrumbOverflowMenu extends StatelessWidget {
  const _BreadcrumbOverflowMenu({
    required this.hidden,
    required this.tokens,
    required this.baseStyle,
    required this.maxLabelLength,
    required this.automationId,
    required this.index,
  });

  final List<NorthstarBreadcrumbItem> hidden;
  final NorthstarColorTokens tokens;
  final TextStyle baseStyle;
  final int maxLabelLength;
  final String? automationId;
  final int index;

  @override
  Widget build(BuildContext context) {
    final TextStyle menuStyle = baseStyle.copyWith(
      color: tokens.onSurface,
      fontWeight: FontWeight.w400,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: tokens.primary.withValues(alpha: 0.12),
        highlightColor: tokens.primary.withValues(alpha: 0.08),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: PopupMenuButton<int>(
          tooltip: 'More trail items',
          child: Text(
            '…',
            style: baseStyle.copyWith(
              color: tokens.primary,
              fontWeight: FontWeight.w600,
            ),
            key: DsAutomationKeys.part(
              automationId,
              '${DsAutomationKeys.elementBreadcrumbOverflow}_$index',
            ),
          ),
          onSelected: (int i) {
            final NorthstarBreadcrumbItem it = hidden[i];
            if (it.enabled) {
              it.onTap?.call();
            }
          },
          itemBuilder: (BuildContext context) {
            return <PopupMenuEntry<int>>[
              for (var i = 0; i < hidden.length; i++)
                PopupMenuItem<int>(
                  value: i,
                  enabled: hidden[i].enabled,
                  child: Text(
                    hidden[i].label,
                    style: menuStyle,
                  ),
                ),
            ];
          },
        ),
      ),
    );
  }
}

class _BreadcrumbCurrent extends StatelessWidget {
  const _BreadcrumbCurrent({
    required this.item,
    required this.tokens,
    required this.baseStyle,
    required this.maxLabelLength,
    required this.automationId,
    required this.index,
  });

  final NorthstarBreadcrumbItem item;
  final NorthstarColorTokens tokens;
  final TextStyle baseStyle;
  final int maxLabelLength;
  final String? automationId;
  final int index;

  @override
  Widget build(BuildContext context) {
    final String shown = _truncatedLabel(item.label, maxLabelLength);
    final bool truncated = shown != item.label;

    final TextStyle style = baseStyle.copyWith(
      color: tokens.onSurface,
      fontWeight: FontWeight.w700,
    );

    final Widget text = Text(
      shown,
      style: style,
      maxLines: 1,
      overflow: TextOverflow.clip,
      key: DsAutomationKeys.part(
        automationId,
        '${DsAutomationKeys.elementBreadcrumbSegment}_${index}_current',
      ),
    );

    return Semantics(
      label: item.semanticsLabel ?? item.label,
      child: truncated
          ? Tooltip(
              message: item.label,
              child: text,
            )
          : text,
    );
  }
}
