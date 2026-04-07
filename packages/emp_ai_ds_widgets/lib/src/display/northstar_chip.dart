import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';

/// Northstar chip use case (Assist / Filter / Input / Status).
enum NorthstarChipUseCase {
  /// Outlined contextual action; label max [NorthstarChip.labelMaxLength] **20**.
  assist,

  /// Toggle selection; optional leading icon or image; max label **20**; selected shows a check.
  filter,

  /// Removable tag; fixed **32** px height; optional close; max label **30**; [selected] = active (delete) highlight.
  input,

  /// Read-only state; semantic palette; Title Case label max **20**; optional chevron.
  status,
}

/// Semantic palette for [NorthstarChipUseCase.status].
enum NorthstarChipStatusSemantic {
  positive,
  warning,
  negative,
  pending,
  neutral,
}

/// Visual weight for [NorthstarChipUseCase.status].
enum NorthstarChipStatusEmphasis {
  standard,
  soft,
}

/// **Catalog / screenshot only:** force hover or pressed paint.
enum NorthstarChipInteractionPreview {
  none,
  hovered,
  pressed,
}

/// Single configurable chip for Assist, Filter, Input, and Status patterns.
///
/// Optional [backgroundColor], [borderColor], and [foregroundColor] override
/// token defaults for the **base** state; hover / press overlays still apply.
/// [inputActiveBackgroundColor] / [inputActiveForegroundColor] override the
/// filled “active” state for [NorthstarChipUseCase.input] when [selected] is
/// true; when null, [NorthstarColorTokens.primary] /
/// [NorthstarColorTokens.onPrimary] are used.
///
/// **Filter-style selection:** set [onSelected] to receive the **new** value
/// after a tap (same contract as [FilterChip.onSelected]). It runs before
/// [onTap] when both are non-null. The chip stays tappable when only
/// [onSelected] is set.
class NorthstarChip extends StatefulWidget {
  NorthstarChip({
    super.key,
    required this.useCase,
    required this.label,
    this.leadingIcon,
    this.leadingImage,
    this.trailingIcon,
    this.showCloseButton,
    this.selected = false,
    this.disabled = false,
    this.isDragged = false,
    this.onTap,
    this.onSelected,
    this.onClose,
    this.statusSemantic,
    this.statusEmphasis = NorthstarChipStatusEmphasis.standard,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.inputActiveBackgroundColor,
    this.inputActiveForegroundColor,
    this.automationId,
    this.interactionPreview = NorthstarChipInteractionPreview.none,
    this.padding,
    this.iconSize = 18,
    this.leadingImageSize = 20,
    this.tooltipMessage,
  }) : assert(label.isNotEmpty),
        assert(
          useCase != NorthstarChipUseCase.status || statusSemantic != null,
          'statusSemantic is required when useCase is status',
        ),
        assert(
          !(leadingIcon != null && leadingImage != null),
          'Use either leadingIcon or leadingImage, not both',
        );

  final NorthstarChipUseCase useCase;

  /// Display text (see [labelMaxLength] per use case).
  final String label;

  final IconData? leadingIcon;
  final ImageProvider? leadingImage;

  /// Trailing glyph (e.g. chevron on status chips).
  final IconData? trailingIcon;

  /// [NorthstarChipUseCase.input] only; defaults to **true** for input.
  final bool? showCloseButton;

  /// Filter: selected styling + leading check. Input: “active” delete highlight.
  final bool selected;

  final bool disabled;

  /// Drag affordance (elevation).
  final bool isDragged;

  final VoidCallback? onTap;

  /// Invoked with the toggled selection (`!selected`) on tap; use with
  /// [NorthstarChipUseCase.filter] like [FilterChip.onSelected].
  final ValueChanged<bool>? onSelected;

  /// Close control ([NorthstarChipUseCase.input]).
  final VoidCallback? onClose;

  final NorthstarChipStatusSemantic? statusSemantic;
  final NorthstarChipStatusEmphasis statusEmphasis;

  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;

  /// Filled state for [NorthstarChipUseCase.input] when [selected]; defaults to
  /// [NorthstarColorTokens.primary] / [NorthstarColorTokens.onPrimary].
  final Color? inputActiveBackgroundColor;
  final Color? inputActiveForegroundColor;

  final String? automationId;
  final NorthstarChipInteractionPreview interactionPreview;

  final EdgeInsetsGeometry? padding;

  final double iconSize;
  final double leadingImageSize;

  /// Short description shown in a **tooltip** on long-press / hover (Figma selection chips).
  final String? tooltipMessage;

  static int labelMaxLength(NorthstarChipUseCase useCase) {
    return switch (useCase) {
      NorthstarChipUseCase.assist => 20,
      NorthstarChipUseCase.filter => 20,
      NorthstarChipUseCase.input => 30,
      NorthstarChipUseCase.status => 20,
    };
  }

  static const double _inputHeight = 32;
  static const double _pillRadius = 999;

  @override
  State<NorthstarChip> createState() => _NorthstarChipState();
}

class _NorthstarChipState extends State<NorthstarChip> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _showClose {
    if (widget.useCase != NorthstarChipUseCase.input) {
      return false;
    }
    return widget.showCloseButton ?? true;
  }

  bool get _hasLeadingVisual =>
      widget.leadingImage != null || widget.leadingIcon != null;

  VoidCallback? get _mainSurfaceTap {
    if (widget.disabled) {
      return null;
    }
    if (widget.onSelected != null) {
      return () {
        widget.onSelected!(!widget.selected);
        widget.onTap?.call();
      };
    }
    return widget.onTap;
  }

  Set<WidgetState> get _effectiveStates {
    switch (widget.interactionPreview) {
      case NorthstarChipInteractionPreview.hovered:
        return <WidgetState>{WidgetState.hovered};
      case NorthstarChipInteractionPreview.pressed:
        return <WidgetState>{WidgetState.pressed};
      case NorthstarChipInteractionPreview.none:
        break;
    }
    if (widget.disabled) {
      return <WidgetState>{WidgetState.disabled};
    }
    return <WidgetState>{
      if (_pressed) WidgetState.pressed,
      if (_hovered) WidgetState.hovered,
    };
  }

  @override
  Widget build(BuildContext context) {
    assert(
      () {
        final int max = NorthstarChip.labelMaxLength(widget.useCase);
        if (widget.label.length > max) {
          throw FlutterError(
            'NorthstarChip label exceeds $max characters for ${widget.useCase} '
            '(got ${widget.label.length}).',
          );
        }
        return true;
      }(),
    );

    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final TextStyle baseStyle = Theme.of(context).textTheme.labelMedium!.copyWith(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
        );

    final _NorthstarChipPaint paint = _NorthstarChipPaint.resolve(
      model: widget,
      tokens: ns,
      states: _effectiveStates,
    );

    final ValueKey<String>? kChip =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementChip);
    final ValueKey<String>? kLabel =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementChipLabel);
    final ValueKey<String>? kLeading =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementChipLeading);
    final ValueKey<String>? kTrailing =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementChipTrailing);
    final ValueKey<String>? kClose =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementChipClose);
    final ValueKey<String>? kFilterCheck = DsAutomationKeys.part(
      widget.automationId,
      DsAutomationKeys.elementChipFilterCheck,
    );

    final List<Widget> rowChildren = <Widget>[];

    if (widget.useCase == NorthstarChipUseCase.filter && widget.selected) {
      rowChildren.add(
        Icon(
          Icons.check_rounded,
          key: kFilterCheck,
          size: widget.iconSize,
          color: paint.contentColor,
        ),
      );
      rowChildren.add(SizedBox(width: _gapAfterLeading()));
    }

    if (widget.leadingImage != null) {
      rowChildren.add(
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.leadingImageSize / 2),
          child: Image(
            key: kLeading,
            image: widget.leadingImage!,
            width: widget.leadingImageSize,
            height: widget.leadingImageSize,
            fit: BoxFit.cover,
          ),
        ),
      );
      rowChildren.add(SizedBox(width: _gapAfterLeading()));
    } else if (widget.leadingIcon != null) {
      rowChildren.add(
        Icon(
          widget.leadingIcon,
          key: kLeading,
          size: widget.iconSize,
          color: paint.contentColor,
        ),
      );
      rowChildren.add(SizedBox(width: _gapAfterLeading()));
    }

    rowChildren.add(
      Text(
        widget.useCase == NorthstarChipUseCase.status
            ? _toTitleCase(widget.label)
            : widget.label,
        key: kLabel,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle.copyWith(color: paint.contentColor),
      ),
    );

    if (widget.trailingIcon != null) {
      rowChildren.add(SizedBox(width: _innerGap()));
      rowChildren.add(
        Icon(
          widget.trailingIcon,
          key: kTrailing,
          size: widget.iconSize,
          color: paint.contentColor,
        ),
      );
    }

    if (_showClose) {
      rowChildren.add(SizedBox(width: _innerGap()));
      rowChildren.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.disabled ? null : widget.onClose,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(NorthstarSpacing.space4),
              child: Icon(
                Icons.close_rounded,
                key: kClose,
                size: 16,
                color: paint.contentColor,
              ),
            ),
          ),
        ),
      );
    }

    final EdgeInsetsGeometry padding = widget.padding ?? _defaultPadding();

    Widget content = Material(
      key: kChip,
      color: paint.backgroundColor,
      elevation: widget.isDragged ? 3 : 0,
      shadowColor: ns.onSurface.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NorthstarChip._pillRadius),
        side: paint.borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _mainSurfaceTap,
        onHighlightChanged: widget.interactionPreview !=
                NorthstarChipInteractionPreview.none
            ? null
            : (bool v) => setState(() => _pressed = v),
        hoverColor: paint.hoverOverlay,
        highlightColor: paint.highlightOverlay,
        splashColor: paint.splashColor,
        borderRadius: BorderRadius.circular(NorthstarChip._pillRadius),
        child: Padding(
          padding: padding,
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: rowChildren,
            ),
          ),
        ),
      ),
    );

    if (widget.useCase == NorthstarChipUseCase.input) {
      content = ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: NorthstarChip._inputHeight,
          maxHeight: NorthstarChip._inputHeight,
        ),
        child: content,
      );
    } else {
      content = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32),
        child: content,
      );
    }

    if (widget.interactionPreview == NorthstarChipInteractionPreview.none) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: content,
      );
    }

    final String? tip = widget.tooltipMessage;
    if (tip != null && tip.isNotEmpty) {
      content = Tooltip(
        message: tip,
        preferBelow: false,
        verticalOffset: 10,
        waitDuration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: ns.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ns.onInverseSurface,
              fontSize: 12,
              height: 1.35,
            ),
        child: content,
      );
    }

    return content;
  }

  double _innerGap() {
    if (widget.useCase == NorthstarChipUseCase.input) {
      return 8;
    }
    return 8;
  }

  double _gapAfterLeading() {
    if (widget.useCase == NorthstarChipUseCase.input && _hasLeadingVisual) {
      return 8;
    }
    return 8;
  }

  EdgeInsetsGeometry _defaultPadding() {
    switch (widget.useCase) {
      case NorthstarChipUseCase.input:
        final double start = _hasLeadingVisual ? 8 : 12;
        final double end = _showClose ? 4 : 12;
        return EdgeInsetsDirectional.fromSTEB(start, 0, end, 0);
      case NorthstarChipUseCase.assist:
      case NorthstarChipUseCase.filter:
      case NorthstarChipUseCase.status:
        return const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space12,
          vertical: 6,
        );
    }
  }
}

String _toTitleCase(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((String w) => w.isNotEmpty)
      .map(
        (String w) =>
            '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
      )
      .join(' ');
}

@immutable
final class _NorthstarChipPaint {
  const _NorthstarChipPaint({
    required this.backgroundColor,
    required this.borderSide,
    required this.contentColor,
    required this.hoverOverlay,
    required this.highlightOverlay,
    required this.splashColor,
  });

  final Color backgroundColor;
  final BorderSide borderSide;
  final Color contentColor;
  final Color hoverOverlay;
  final Color highlightOverlay;
  final Color splashColor;

  static _NorthstarChipPaint resolve({
    required NorthstarChip model,
    required NorthstarColorTokens tokens,
    required Set<WidgetState> states,
  }) {
    final bool disabled = states.contains(WidgetState.disabled);
    final bool pressed = states.contains(WidgetState.pressed);
    final bool hovered = states.contains(WidgetState.hovered);

    Color bg;
    Color borderC;
    const double borderWidth = 1;
    Color fg;
    Color hover;
    Color highlight;
    Color splash;

    void applyColorOverrides() {
      if (model.backgroundColor != null) {
        bg = model.backgroundColor!;
      }
      if (model.borderColor != null) {
        borderC = model.borderColor!;
      }
      if (model.foregroundColor != null) {
        fg = model.foregroundColor!;
      }
    }

    switch (model.useCase) {
      case NorthstarChipUseCase.assist:
        bg = Colors.transparent;
        borderC = tokens.primary;
        fg = tokens.primary;
        hover = tokens.primary.withValues(alpha: 0.08);
        highlight = tokens.primary.withValues(alpha: 0.14);
        splash = tokens.primary.withValues(alpha: 0.12);
        if (disabled) {
          bg = Colors.transparent;
          borderC = tokens.outlineVariant;
          fg = tokens.onSurface.withValues(alpha: 0.38);
          hover = Colors.transparent;
          highlight = Colors.transparent;
          splash = Colors.transparent;
        } else {
          applyColorOverrides();
          if (pressed) {
            bg = Color.alphaBlend(highlight, bg);
          } else if (hovered) {
            bg = Color.alphaBlend(hover, bg);
          }
        }
        break;

      case NorthstarChipUseCase.filter:
        if (model.selected) {
          bg = tokens.primaryContainer;
          borderC = tokens.primary;
          fg = tokens.primary;
        } else {
          bg = tokens.surface;
          borderC = tokens.outlineVariant;
          fg = tokens.onSurface;
        }
        hover = tokens.onSurface.withValues(alpha: 0.06);
        highlight = tokens.onSurface.withValues(alpha: 0.1);
        splash = tokens.primary.withValues(alpha: 0.08);
        if (disabled) {
          borderC = tokens.outlineVariant;
          fg = tokens.onSurface.withValues(alpha: 0.38);
          hover = Colors.transparent;
          highlight = Colors.transparent;
          splash = Colors.transparent;
        } else {
          applyColorOverrides();
          if (model.selected) {
            if (pressed) {
              bg = Color.alphaBlend(tokens.primary.withValues(alpha: 0.12), bg);
            } else if (hovered) {
              bg = Color.alphaBlend(tokens.primary.withValues(alpha: 0.08), bg);
            }
          } else {
            if (pressed) {
              bg = Color.alphaBlend(highlight, bg);
            } else if (hovered) {
              bg = Color.alphaBlend(hover, bg);
            }
          }
        }
        break;

      case NorthstarChipUseCase.input:
        if (model.selected) {
          final Color activeBg =
              model.inputActiveBackgroundColor ?? tokens.primary;
          final Color activeFg =
              model.inputActiveForegroundColor ?? tokens.onPrimary;
          bg = activeBg;
          borderC = activeBg;
          fg = activeFg;
          hover = activeFg.withValues(alpha: 0.14);
          highlight = activeFg.withValues(alpha: 0.22);
          splash = activeFg.withValues(alpha: 0.2);
        } else {
          bg = tokens.surface;
          borderC = tokens.outlineVariant;
          fg = tokens.onSurface;
          hover = tokens.onSurface.withValues(alpha: 0.08);
          highlight = tokens.onSurface.withValues(alpha: 0.12);
          splash = tokens.primary.withValues(alpha: 0.1);
        }
        if (disabled) {
          fg = tokens.onSurface.withValues(alpha: 0.38);
          borderC = tokens.outlineVariant;
          hover = Colors.transparent;
          highlight = Colors.transparent;
          splash = Colors.transparent;
        } else {
          applyColorOverrides();
          if (model.selected) {
            if (pressed) {
              bg = Color.alphaBlend(highlight, bg);
            } else if (hovered) {
              bg = Color.alphaBlend(hover, bg);
            }
          } else {
            if (pressed) {
              bg = Color.alphaBlend(highlight, bg);
            } else if (hovered) {
              bg = Color.alphaBlend(hover, bg);
            }
          }
        }
        break;

      case NorthstarChipUseCase.status:
        final _StatusColors sc = _StatusColors.from(
          semantic: model.statusSemantic!,
          tokens: tokens,
          soft: model.statusEmphasis == NorthstarChipStatusEmphasis.soft,
        );
        bg = sc.background;
        borderC = sc.border;
        fg = sc.foreground;
        hover = sc.foreground.withValues(alpha: 0.08);
        highlight = sc.foreground.withValues(alpha: 0.12);
        splash = sc.foreground.withValues(alpha: 0.1);
        if (disabled) {
          fg = tokens.onSurface.withValues(alpha: 0.38);
          borderC = tokens.outlineVariant;
          hover = Colors.transparent;
          highlight = Colors.transparent;
          splash = Colors.transparent;
        } else {
          applyColorOverrides();
          if (pressed) {
            bg = Color.alphaBlend(highlight, bg);
          } else if (hovered) {
            bg = Color.alphaBlend(hover, bg);
          }
        }
        break;
    }

    return _NorthstarChipPaint(
      backgroundColor: bg,
      borderSide: BorderSide(color: borderC, width: borderWidth),
      contentColor: fg,
      hoverOverlay: hover,
      highlightOverlay: highlight,
      splashColor: splash,
    );
  }
}

@immutable
final class _StatusColors {
  const _StatusColors({
    required this.background,
    required this.border,
    required this.foreground,
  });

  final Color background;
  final Color border;
  final Color foreground;

  factory _StatusColors.from({
    required NorthstarChipStatusSemantic semantic,
    required NorthstarColorTokens tokens,
    required bool soft,
  }) {
    final double bgA = soft ? 0.06 : 0.12;
    final double bdA = soft ? 0.28 : 0.45;

    switch (semantic) {
      case NorthstarChipStatusSemantic.positive:
        return _StatusColors(
          background: tokens.success.withValues(alpha: bgA),
          border: tokens.success.withValues(alpha: bdA),
          foreground: tokens.success,
        );
      case NorthstarChipStatusSemantic.warning:
        return _StatusColors(
          background: tokens.warning.withValues(alpha: bgA),
          border: tokens.warning.withValues(alpha: bdA),
          foreground: tokens.warning,
        );
      case NorthstarChipStatusSemantic.negative:
        return _StatusColors(
          background: tokens.error.withValues(alpha: bgA),
          border: tokens.error.withValues(alpha: bdA),
          foreground: tokens.error,
        );
      case NorthstarChipStatusSemantic.pending:
        return _StatusColors(
          background: tokens.primaryContainer.withValues(alpha: soft ? 0.5 : 0.85),
          border: tokens.primary.withValues(alpha: bdA),
          foreground: tokens.primary,
        );
      case NorthstarChipStatusSemantic.neutral:
        return _StatusColors(
          background: tokens.surfaceContainerLow,
          border: tokens.outlineVariant,
          foreground: tokens.onSurfaceVariant,
        );
    }
  }
}
