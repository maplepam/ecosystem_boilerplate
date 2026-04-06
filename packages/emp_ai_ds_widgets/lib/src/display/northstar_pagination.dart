import 'dart:math' as math;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pagination UI colors aligned with [NorthstarBaseTokens.light].
abstract final class NorthstarPaginationTokens {
  const NorthstarPaginationTokens._();

  static final Color specPrimaryBlue = NorthstarBaseTokens.light.primary;
  static final Color specTextPrimary = NorthstarBaseTokens.light.onSurface;
  static final Color specTextSecondary =
      NorthstarBaseTokens.light.onSurfaceVariant;
  static final Color specActiveBackground =
      NorthstarBaseTokens.light.surfaceContainerLow;
  static final Color specBorder = NorthstarBaseTokens.light.outlineVariant;
  static final Color specHoverBackground = NorthstarBaseTokens.light.surface;
}

/// Visible page control slots: page numbers or `null` for ellipsis.
List<int?> northstarPaginationPageSlots({
  required int currentPage,
  required int totalPages,
}) {
  final int total = math.max(0, totalPages);
  final int current = currentPage.clamp(1, math.max(1, total));
  if (total <= 0) {
    return <int?>[];
  }
  if (total <= 7) {
    return List<int?>.generate(total, (int i) => i + 1);
  }
  if (current <= 4) {
    return <int?>[1, 2, 3, 4, 5, null, total];
  }
  if (current >= total - 3) {
    return <int?>[
      1,
      null,
      total - 4,
      total - 3,
      total - 2,
      total - 1,
      total,
    ];
  }
  return <int?>[1, null, current - 1, current, current + 1, null, total];
}

List<int?> _northstarPaginationSlotsCompact3({
  required int current,
  required int total,
}) {
  if (total <= 3) {
    return List<int?>.generate(total, (int i) => i + 1);
  }
  if (current <= 1 || current >= total) {
    return <int?>[1, null, total];
  }
  return <int?>[1, current, total];
}

List<int?> _northstarPaginationSlotsCompact4({
  required int current,
  required int total,
}) {
  if (total <= 4) {
    return List<int?>.generate(total, (int i) => i + 1);
  }
  if (current <= 2) {
    return <int?>[1, 2, null, total];
  }
  if (current >= total - 1) {
    return <int?>[1, null, total - 1, total];
  }
  return <int?>[1, null, current, total];
}

List<int?> _northstarPaginationSlotsCompact5({
  required int current,
  required int total,
}) {
  if (total <= 5) {
    return List<int?>.generate(total, (int i) => i + 1);
  }
  if (current <= 3) {
    return <int?>[1, 2, 3, null, total];
  }
  if (current >= total - 2) {
    return <int?>[1, null, total - 2, total - 1, total];
  }
  return <int?>[1, null, current, null, total];
}

/// Page slots between prev/next, capped by [maxSlotCount] (3–7) so the strip
/// fits without horizontal scrolling. Use with [northstarPaginationMaxSlotCountForWidth].
///
/// When [totalPages] fits in the cap, every page is shown. Otherwise a denser
/// ellipsis pattern is used (same start/middle/end intent as
/// [northstarPaginationPageSlots], but with fewer cells).
List<int?> northstarPaginationPageSlotsAdaptive({
  required int currentPage,
  required int totalPages,
  required int maxSlotCount,
}) {
  final int total = math.max(0, totalPages);
  final int current = currentPage.clamp(1, math.max(1, total));
  if (total <= 0) {
    return <int?>[];
  }
  final int cap = maxSlotCount.clamp(3, 7);
  if (total <= cap) {
    return List<int?>.generate(total, (int i) => i + 1);
  }
  if (cap >= 7) {
    return northstarPaginationPageSlots(
      currentPage: current,
      totalPages: total,
    );
  }
  if (cap >= 5) {
    return _northstarPaginationSlotsCompact5(current: current, total: total);
  }
  if (cap == 4) {
    return _northstarPaginationSlotsCompact4(current: current, total: total);
  }
  return _northstarPaginationSlotsCompact3(current: current, total: total);
}

/// Maps the horizontal space for the page strip (inside prev/next) to a slot
/// budget. Each cell is ~44 logical px (36 + gap).
int northstarPaginationMaxSlotCountForWidth(double width) {
  const double navAndGaps = 36 + 8 + 8 + 36;
  const double slotUnit = 36 + 8;
  if (!width.isFinite || width <= navAndGaps) {
    return 3;
  }
  final int raw = ((width - navAndGaps) / slotUnit).floor();
  return raw.clamp(3, 7);
}

/// Northstar **Pagination** bar: prev/next, page numbers, ellipsis skip (+3),
/// optional rows-per-page, optional go-to (when [goToPageVisibleThreshold]
/// exceeded), range summary.
class NorthstarPaginationBar extends StatefulWidget {
  const NorthstarPaginationBar({
    super.key,
    this.automationId,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.totalItems,
    this.pageSize,
    this.pageSizeOptions = const <int>[10, 25, 50],
    this.onPageSizeChanged,
    this.showItemsPerPage = true,
    this.showSummary = true,
    this.goToPageVisibleThreshold = 8,
    this.goToPageLoading = false,
    this.compact = false,
    this.ellipsisSkipDelta = 3,
    this.enabled = true,
    this.emptyResults = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: NorthstarSpacing.space16,
      vertical: NorthstarSpacing.space12,
    ),
  });

  final String? automationId;

  /// 1-based.
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  final int? totalItems;
  final int? pageSize;
  final List<int> pageSizeOptions;
  final ValueChanged<int>? onPageSizeChanged;

  final bool showItemsPerPage;
  final bool showSummary;

  /// Show **Go to** field when [totalPages] ≥ this value (default **8**).
  final int goToPageVisibleThreshold;

  final bool goToPageLoading;
  final bool compact;

  /// Ellipsis click / skip adds this many pages (clamped to [totalPages]).
  final int ellipsisSkipDelta;

  final bool enabled;
  final bool emptyResults;

  final EdgeInsetsGeometry padding;

  @override
  State<NorthstarPaginationBar> createState() => _NorthstarPaginationBarState();
}

class _NorthstarPaginationBarState extends State<NorthstarPaginationBar> {
  final TextEditingController _goToController = TextEditingController();
  int? _ellipsisHoverSlot;

  @override
  void dispose() {
    _goToController.dispose();
    super.dispose();
  }

  bool get _effectiveEnabled =>
      widget.enabled && !widget.emptyResults && widget.totalPages > 0;

  void _goToSubmit() {
    if (!_effectiveEnabled || widget.goToPageLoading) {
      return;
    }
    final int? parsed = int.tryParse(_goToController.text.trim());
    if (parsed == null) {
      return;
    }
    final int clamped = parsed.clamp(1, math.max(1, widget.totalPages));
    widget.onPageChanged(clamped);
    _goToController.clear();
  }

  Widget _buildPageStrip({
    required List<int?> slots,
    required Color border,
    required Color hoverBg,
    required Color activeBg,
    required Color numberText,
    required Color activeText,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _NavIconButton(
          automationKey: DsAutomationKeys.part(
            widget.automationId,
            DsAutomationKeys.elementPaginationPrev,
          ),
          icon: Icons.chevron_left_rounded,
          borderColor: border,
          hoverBg: hoverBg,
          enabled: _effectiveEnabled && widget.currentPage > 1,
          onPressed: () =>
              widget.onPageChanged(math.max(1, widget.currentPage - 1)),
        ),
        const SizedBox(width: NorthstarSpacing.space8),
        for (var i = 0; i < slots.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: NorthstarSpacing.space8),
          _PageOrEllipsis(
            slotIndex: i,
            value: slots[i],
            currentPage: widget.currentPage,
            borderColor: border,
            hoverBg: hoverBg,
            activeBg: activeBg,
            numberColor: numberText,
            activeColor: activeText,
            ellipsisHover: _ellipsisHoverSlot == i,
            enabled: _effectiveEnabled,
            automationId: widget.automationId,
            onEllipsisHover: (bool v) =>
                setState(() => _ellipsisHoverSlot = v ? i : null),
            onNumberTap: (int page) => widget.onPageChanged(page),
            onEllipsisSkip: () {
              final int next = math.min(
                widget.totalPages,
                widget.currentPage + widget.ellipsisSkipDelta,
              );
              widget.onPageChanged(next);
            },
          ),
        ],
        const SizedBox(width: NorthstarSpacing.space8),
        _NavIconButton(
          automationKey: DsAutomationKeys.part(
            widget.automationId,
            DsAutomationKeys.elementPaginationNext,
          ),
          icon: Icons.chevron_right_rounded,
          borderColor: border,
          hoverBg: hoverBg,
          enabled: _effectiveEnabled &&
              widget.currentPage < math.max(1, widget.totalPages),
          onPressed: () => widget.onPageChanged(
            math.min(widget.totalPages, widget.currentPage + 1),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final Color primary = scheme.primary;
    final Color activeText = Color.alphaBlend(
      primary.withValues(alpha: 0.92),
      NorthstarPaginationTokens.specPrimaryBlue,
    );
    final Color numberText = NorthstarPaginationTokens.specTextPrimary;
    final Color secondaryText = NorthstarPaginationTokens.specTextSecondary;
    final Color border = NorthstarPaginationTokens.specBorder;
    final Color activeBg = Color.alphaBlend(
      primary.withValues(alpha: 0.08),
      NorthstarPaginationTokens.specActiveBackground,
    );
    final Color hoverBg = NorthstarPaginationTokens.specHoverBackground;

    final bool showGoTo =
        widget.totalPages >= widget.goToPageVisibleThreshold && !widget.compact;

    if (widget.compact) {
      return Padding(
        padding: widget.padding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            _NavIconButton(
              automationKey: DsAutomationKeys.part(
                widget.automationId,
                DsAutomationKeys.elementPaginationPrev,
              ),
              icon: Icons.chevron_left_rounded,
              borderColor: border,
              hoverBg: hoverBg,
              enabled: _effectiveEnabled && widget.currentPage > 1,
              onPressed: () =>
                  widget.onPageChanged(math.max(1, widget.currentPage - 1)),
            ),
            const SizedBox(width: NorthstarSpacing.space4),
            _NavIconButton(
              automationKey: DsAutomationKeys.part(
                widget.automationId,
                DsAutomationKeys.elementPaginationNext,
              ),
              icon: Icons.chevron_right_rounded,
              borderColor: border,
              hoverBg: hoverBg,
              enabled: _effectiveEnabled &&
                  widget.currentPage < math.max(1, widget.totalPages),
              onPressed: () => widget.onPageChanged(
                math.min(widget.totalPages, widget.currentPage + 1),
              ),
            ),
          ],
        ),
      );
    }

    final int tp = widget.totalPages;

    String summaryText() {
      final int? t = widget.totalItems;
      final int? ps = widget.pageSize;
      if (t == null || ps == null || ps <= 0) {
        return 'Page ${widget.currentPage} of ${widget.totalPages <= 0 ? 1 : widget.totalPages}';
      }
      if (widget.emptyResults || t <= 0) {
        return '0-$ps of 0 items';
      }
      final int start = (widget.currentPage - 1) * ps + 1;
      final int end = math.min(widget.currentPage * ps, t);
      return '$start-$end of $t items';
    }

    final Widget? itemsPerPage = widget.showItemsPerPage &&
            widget.onPageSizeChanged != null &&
            widget.pageSize != null
        ? _ItemsPerPageMenu(
            automationId: widget.automationId,
            current: widget.pageSize!,
            options: widget.pageSizeOptions,
            enabled: _effectiveEnabled,
            borderColor: border,
            hoverBg: hoverBg,
            secondaryText: secondaryText,
            onChanged: widget.onPageSizeChanged!,
          )
        : null;

    final Widget? goTo = showGoTo
        ? _GoToPageField(
            automationId: widget.automationId,
            controller: _goToController,
            enabled: _effectiveEnabled && !widget.goToPageLoading,
            borderColor: border,
            secondaryText: secondaryText,
            textTheme: textTheme,
            onSubmit: _goToSubmit,
          )
        : null;

    final Widget? summary = widget.showSummary
        ? Text(
            summaryText(),
            key: DsAutomationKeys.part(
              widget.automationId,
              DsAutomationKeys.elementPaginationSummary,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(color: secondaryText),
          )
        : null;

    Widget adaptivePageStrip(double stripWidth) {
      final List<int?> slots = tp <= 0
          ? const <int?>[]
          : northstarPaginationPageSlotsAdaptive(
              currentPage: widget.currentPage,
              totalPages: tp,
              maxSlotCount: northstarPaginationMaxSlotCountForWidth(stripWidth),
            );
      return FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: _buildPageStrip(
          slots: slots,
          border: border,
          hoverBg: hoverBg,
          activeBg: activeBg,
          numberText: numberText,
          activeText: activeText,
        ),
      );
    }

    return Padding(
      key: DsAutomationKeys.part(
        widget.automationId,
        DsAutomationKeys.elementPaginationBar,
      ),
      padding: widget.padding,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool narrow = constraints.maxWidth < 720;
          final Widget midControls = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (itemsPerPage != null || goTo != null)
                const SizedBox(width: NorthstarSpacing.space16),
              if (itemsPerPage != null) itemsPerPage,
              if (goTo != null) ...<Widget>[
                const SizedBox(width: NorthstarSpacing.space16),
                goTo,
              ],
            ],
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints inner) {
                          return Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  adaptivePageStrip(inner.maxWidth),
                                  midControls,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (summary != null) ...<Widget>[
                  const SizedBox(height: NorthstarSpacing.space8),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: summary,
                  ),
                ],
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints inner) {
                    return Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            adaptivePageStrip(inner.maxWidth),
                            midControls,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (summary != null) ...<Widget>[
                const SizedBox(width: NorthstarSpacing.space16),
                Flexible(
                  flex: 0,
                  fit: FlexFit.loose,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: summary,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _NavIconButton extends StatefulWidget {
  const _NavIconButton({
    required this.icon,
    required this.borderColor,
    required this.hoverBg,
    required this.enabled,
    required this.onPressed,
    this.automationKey,
  });

  final IconData icon;
  final Color borderColor;
  final Color hoverBg;
  final bool enabled;
  final VoidCallback onPressed;
  final Key? automationKey;

  @override
  State<_NavIconButton> createState() => _NavIconButtonState();
}

class _NavIconButtonState extends State<_NavIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final Color fg = widget.enabled
        ? NorthstarPaginationTokens.specTextPrimary
        : NorthstarPaginationTokens.specTextSecondary.withValues(alpha: 0.45);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        key: widget.automationKey,
        color: _hover && widget.enabled ? widget.hoverBg : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: widget.borderColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.enabled ? widget.onPressed : null,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(widget.icon, size: 22, color: fg),
          ),
        ),
      ),
    );
  }
}

class _PageOrEllipsis extends StatelessWidget {
  const _PageOrEllipsis({
    required this.slotIndex,
    required this.value,
    required this.currentPage,
    required this.borderColor,
    required this.hoverBg,
    required this.activeBg,
    required this.numberColor,
    required this.activeColor,
    required this.ellipsisHover,
    required this.enabled,
    required this.automationId,
    required this.onEllipsisHover,
    required this.onNumberTap,
    required this.onEllipsisSkip,
  });

  final int slotIndex;
  final int? value;
  final int currentPage;
  final Color borderColor;
  final Color hoverBg;
  final Color activeBg;
  final Color numberColor;
  final Color activeColor;
  final bool ellipsisHover;
  final bool enabled;
  final String? automationId;
  final ValueChanged<bool> onEllipsisHover;
  final ValueChanged<int> onNumberTap;
  final VoidCallback onEllipsisSkip;

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      final int page = value!;
      final bool active = page == currentPage;
      return _PageNumberButton(
        key: DsAutomationKeys.part(
          automationId,
          '${DsAutomationKeys.elementPaginationPage}_$page',
        ),
        label: '$page',
        active: active,
        enabled: enabled,
        borderColor: borderColor,
        hoverBg: hoverBg,
        activeBg: activeBg,
        textColor: numberColor,
        activeTextColor: activeColor,
        onTap: () => onNumberTap(page),
      );
    }
    return MouseRegion(
      onEnter: (_) => onEllipsisHover(true),
      onExit: (_) => onEllipsisHover(false),
      cursor: SystemMouseCursors.click,
      child: Material(
        key: DsAutomationKeys.part(
          automationId,
          '${DsAutomationKeys.elementPaginationEllipsis}_$slotIndex',
        ),
        color: ellipsisHover && enabled ? hoverBg : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onEllipsisSkip : null,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              ellipsisHover && enabled
                  ? Icons.keyboard_double_arrow_right_rounded
                  : Icons.more_horiz_rounded,
              size: 20,
              color: enabled
                  ? NorthstarPaginationTokens.specTextSecondary
                  : NorthstarPaginationTokens.specTextSecondary
                      .withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatefulWidget {
  const _PageNumberButton({
    super.key,
    required this.label,
    required this.active,
    required this.enabled,
    required this.borderColor,
    required this.hoverBg,
    required this.activeBg,
    required this.textColor,
    required this.activeTextColor,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool enabled;
  final Color borderColor;
  final Color hoverBg;
  final Color activeBg;
  final Color textColor;
  final Color activeTextColor;
  final VoidCallback onTap;

  @override
  State<_PageNumberButton> createState() => _PageNumberButtonState();
}

class _PageNumberButtonState extends State<_PageNumberButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle? base = Theme.of(context).textTheme.labelLarge;
    final Color bg = widget.active
        ? widget.activeBg
        : (_hover && widget.enabled ? widget.hoverBg : Colors.transparent);
    final Color fg = widget.active ? widget.activeTextColor : widget.textColor;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: widget.active
                ? widget.borderColor.withValues(alpha: 0.35)
                : widget.borderColor,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.enabled && !widget.active ? widget.onTap : null,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(
                widget.label,
                style: base?.copyWith(
                  color: fg,
                  fontWeight: widget.active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemsPerPageMenu extends StatelessWidget {
  const _ItemsPerPageMenu({
    required this.current,
    required this.options,
    required this.enabled,
    required this.borderColor,
    required this.hoverBg,
    required this.secondaryText,
    required this.onChanged,
    this.automationId,
  });

  final int current;
  final List<int> options;
  final bool enabled;
  final Color borderColor;
  final Color hoverBg;
  final Color secondaryText;
  final ValueChanged<int> onChanged;
  final String? automationId;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementPaginationPageSize,
      ),
      enabled: enabled,
      onSelected: onChanged,
      itemBuilder: (BuildContext context) => options
          .map(
            (int n) => PopupMenuItem<int>(
              value: n,
              child: Text('$n / page'),
            ),
          )
          .toList(),
      child: _MenuChip(
        label: '$current / page',
        borderColor: borderColor,
        hoverBg: hoverBg,
        textColor: secondaryText,
        enabled: enabled,
      ),
    );
  }
}

class _MenuChip extends StatefulWidget {
  const _MenuChip({
    required this.label,
    required this.borderColor,
    required this.hoverBg,
    required this.textColor,
    required this.enabled,
  });

  final String label;
  final Color borderColor;
  final Color hoverBg;
  final Color textColor;
  final bool enabled;

  @override
  State<_MenuChip> createState() => _MenuChipState();
}

class _MenuChipState extends State<_MenuChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: _hover && widget.enabled ? widget.hoverBg : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: widget.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NorthstarSpacing.space12,
            vertical: NorthstarSpacing.space8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: widget.enabled
                          ? widget.textColor
                          : widget.textColor.withValues(alpha: 0.4),
                    ),
              ),
              Icon(
                Icons.expand_more_rounded,
                size: 20,
                color: widget.enabled
                    ? widget.textColor
                    : widget.textColor.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoToPageField extends StatelessWidget {
  const _GoToPageField({
    required this.controller,
    required this.enabled,
    required this.borderColor,
    required this.secondaryText,
    required this.textTheme,
    required this.onSubmit,
    this.automationId,
  });

  final TextEditingController controller;
  final bool enabled;
  final Color borderColor;
  final Color secondaryText;
  final TextTheme textTheme;
  final VoidCallback onSubmit;
  final String? automationId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Go to',
          style: textTheme.bodySmall?.copyWith(color: secondaryText),
        ),
        const SizedBox(width: NorthstarSpacing.space8),
        SizedBox(
          width: 52,
          height: 36,
          child: TextField(
            key: DsAutomationKeys.part(
              automationId,
              DsAutomationKeys.elementPaginationGoToField,
            ),
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NorthstarSpacing.space8,
                vertical: NorthstarSpacing.space8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
        ),
        const SizedBox(width: NorthstarSpacing.space8),
        Text(
          'page',
          style: textTheme.bodySmall?.copyWith(color: secondaryText),
        ),
      ],
    );
  }
}
