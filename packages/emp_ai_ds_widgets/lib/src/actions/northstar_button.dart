import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import '../testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Semantic color family (blue / green / red matrices in Figma).
enum NorthstarButtonTone {
  /// [NorthstarColorTokens.primary] / [NorthstarColorTokens.onPrimary].
  standard,

  /// [NorthstarColorTokens.success] / [NorthstarColorTokens.onSuccess].
  positive,

  /// [NorthstarColorTokens.error] / [NorthstarColorTokens.onError].
  negative,
}

/// Visual style row from the Northstar button matrix (Figma).
enum NorthstarButtonVariant {
  /// Filled primary background, on-primary label.
  primary,

  /// Outlined; neutral default, primary border/label on hover.
  secondary,

  /// Text-only; primary label on hover/press.
  tertiary,

  /// Square content-hugging icon; hover/press use a subtle surface tint.
  iconOnly,
}

/// **Catalog / screenshot only:** force hover or pressed paint without pointer.
enum NorthstarButtonInteractionPreview {
  /// Use real pointer/focus states only.
  none,

  /// Paint as hovered.
  hovered,

  /// Paint as pressed.
  pressed,
}

/// How [NorthstarButton] shows [NorthstarButton.isLoading].
enum NorthstarButtonLoadingStyle {
  /// Hide label and icons; centered [CircularProgressIndicator] only.
  spinnerOnly,

  /// Keep the label (and leading icon); trailing icon is replaced by the
  /// progress indicator. [NorthstarButtonVariant.iconOnly] always uses a
  /// centered spinner only.
  labelWithSpinner,
}

/// Northstar action button: **40px** height, **8** radius, **12px / w600** label,
/// **8px** gap between label and icons. Optional [leadingIcon] / [trailingIcon]
/// (omit both for label-only). Optional [padding] / [margin] override defaults.
/// Optional [width]; omit to hug contents.
///
/// [tone] selects standard (primary blue), positive (success green), or negative
/// (error red). [backgroundColor] / [foregroundColor] override the accent fill
/// and label/icon color for that tone (hover/pressed still derive from the
/// accent).
///
/// [onPressed] `null` → disabled. [isLoading] → no tap; see [loadingStyle].
///
/// [automationId] assigns stable [ValueKey]s for integration tests
/// (`find.byKey(DsAutomationKeys.part(id, …))`). Sub-keys: [DsAutomationKeys]
/// `button`, `label`, `leading_icon`, `trailing_icon`, `progress`.
///
/// [NorthstarButtonVariant.iconOnly] requires at least one icon; the drawn
/// glyph is [trailingIcon] if set, otherwise [leadingIcon].
class NorthstarButton extends StatefulWidget {
  NorthstarButton({
    super.key,
    required this.variant,
    this.tone = NorthstarButtonTone.standard,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
    this.isLoading = false,
    this.loadingStyle = NorthstarButtonLoadingStyle.spinnerOnly,
    this.automationId,
    this.width,
    this.padding,
    this.margin,
    this.interactionPreview = NorthstarButtonInteractionPreview.none,
    this.semanticLabel,
  })  : assert(
          variant != NorthstarButtonVariant.iconOnly ||
              label == null ||
              label.isEmpty,
          'iconOnly variant should not use a visible text label',
        ),
        assert(
          variant != NorthstarButtonVariant.iconOnly ||
              trailingIcon != null ||
              leadingIcon != null,
          'iconOnly requires trailingIcon and/or leadingIcon',
        ),
        assert(
          variant == NorthstarButtonVariant.iconOnly ||
              (label != null && label.isNotEmpty) ||
              leadingIcon != null ||
              trailingIcon != null,
          'Provide a non-empty label and/or at least one icon',
        );

  final NorthstarButtonVariant variant;

  /// Semantic palette: standard, positive (success), or negative (error).
  final NorthstarButtonTone tone;

  /// Ignored when [variant] is [NorthstarButtonVariant.iconOnly].
  final String? label;

  /// Optional icon before the label.
  final IconData? leadingIcon;

  /// Optional icon after the label. For [NorthstarButtonVariant.iconOnly], this
  /// is preferred over [leadingIcon] when both are set.
  final IconData? trailingIcon;

  /// Overrides the tone’s accent (filled primary background, hover/press base).
  final Color? backgroundColor;

  /// Overrides label and icon color on filled primary; on secondary/tertiary
  /// replaces the accent color for borders and active text.
  final Color? foregroundColor;

  final VoidCallback? onPressed;

  final bool isLoading;

  /// Layout while [isLoading] is true.
  final NorthstarButtonLoadingStyle loadingStyle;

  /// Non-empty id for test keys ([DsAutomationKeys]).
  final String? automationId;

  /// Fixed width; `null` → intrinsic width (hug content + padding).
  final double? width;

  /// Inner padding; default is **16** horizontal (text variants) or **8** all
  /// sides ([NorthstarButtonVariant.iconOnly]).
  final EdgeInsetsGeometry? padding;

  /// Outer spacing around the button.
  final EdgeInsetsGeometry? margin;

  /// See [NorthstarButtonInteractionPreview].
  final NorthstarButtonInteractionPreview interactionPreview;

  /// Accessibility label (e.g. icon-only).
  final String? semanticLabel;

  static const double _height = 40;
  static const double _radius = 8;
  static const double _gap = 8;
  static const double _hPadding = 16;
  static const double _iconOnlyPadding = 8;

  @override
  State<NorthstarButton> createState() => _NorthstarButtonState();
}

class _NorthstarButtonState extends State<NorthstarButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _blocked => widget.isLoading || widget.onPressed == null;

  Set<WidgetState> get _effectiveStates {
    switch (widget.interactionPreview) {
      case NorthstarButtonInteractionPreview.hovered:
        return <WidgetState>{WidgetState.hovered};
      case NorthstarButtonInteractionPreview.pressed:
        return <WidgetState>{WidgetState.pressed};
      case NorthstarButtonInteractionPreview.none:
        break;
    }
    if (widget.isLoading) {
      return <WidgetState>{};
    }
    if (widget.onPressed == null) {
      return <WidgetState>{WidgetState.disabled};
    }
    return <WidgetState>{
      if (_pressed) WidgetState.pressed,
      if (_hovered) WidgetState.hovered,
    };
  }

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final TextStyle labelStyle = Theme.of(context).textTheme.labelMedium!.copyWith(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
        );

    final _NorthstarButtonPaint paint = _NorthstarButtonPaint.resolve(
      variant: widget.variant,
      tokens: ns,
      states: _effectiveStates,
      isLoading: widget.isLoading,
      tone: widget.tone,
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.foregroundColor,
    );

    final bool iconOnly = widget.variant == NorthstarButtonVariant.iconOnly;
    final bool hasLabel =
        !iconOnly &&
        widget.label != null &&
        widget.label!.isNotEmpty;

    final bool showLeading =
        !widget.isLoading && widget.leadingIcon != null && !iconOnly;
    final bool showTrailing =
        !widget.isLoading && widget.trailingIcon != null && !iconOnly;

    final bool showLeadingWhileLoading =
        widget.isLoading &&
        !iconOnly &&
        widget.loadingStyle == NorthstarButtonLoadingStyle.labelWithSpinner &&
        widget.leadingIcon != null;

    final IconData? iconOnlyGlyph =
        iconOnly ? (widget.trailingIcon ?? widget.leadingIcon) : null;

    final ValueKey<String>? kButton =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementButton);
    final ValueKey<String>? kLabel =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementLabel);
    final ValueKey<String>? kLeading =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementLeadingIcon);
    final ValueKey<String>? kTrailing =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementTrailingIcon);
    final ValueKey<String>? kIcon =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementIcon);
    final ValueKey<String>? kProgress =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementProgress);

    Widget progressBox() {
      return SizedBox(
        key: kProgress,
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: paint.spinnerColor,
        ),
      );
    }

    final Widget content = () {
      if (widget.isLoading) {
        if (iconOnly ||
            widget.loadingStyle == NorthstarButtonLoadingStyle.spinnerOnly) {
          return progressBox();
        }
        // labelWithSpinner — label and/or leading stay visible; trailing slot is spinner.
        if (!hasLabel && !showLeadingWhileLoading) {
          return progressBox();
        }
        final List<Widget> rowChildren = <Widget>[];
        if (showLeadingWhileLoading) {
          rowChildren.add(
            Icon(
              widget.leadingIcon,
              key: kLeading,
              size: 18,
              color: paint.foregroundColor,
            ),
          );
        }
        if (showLeadingWhileLoading && hasLabel) {
          rowChildren.add(const SizedBox(width: NorthstarButton._gap));
        }
        if (hasLabel) {
          rowChildren.add(
            Text(
              widget.label!,
              key: kLabel,
              style: labelStyle.copyWith(color: paint.foregroundColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
        rowChildren.add(const SizedBox(width: NorthstarButton._gap));
        rowChildren.add(progressBox());
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowChildren,
        );
      }

      if (iconOnly) {
        return Icon(
          iconOnlyGlyph,
          key: kIcon,
          size: 18,
          color: paint.foregroundColor,
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (showLeading)
            Icon(
              widget.leadingIcon,
              key: kLeading,
              size: 18,
              color: paint.foregroundColor,
            ),
          if (showLeading && (hasLabel || showTrailing))
            const SizedBox(width: NorthstarButton._gap),
          if (hasLabel)
            Text(
              widget.label!,
              key: kLabel,
              style: labelStyle.copyWith(color: paint.foregroundColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (showTrailing && (hasLabel || showLeading))
            const SizedBox(width: NorthstarButton._gap),
          if (showTrailing)
            Icon(
              widget.trailingIcon,
              key: kTrailing,
              size: 18,
              color: paint.foregroundColor,
            ),
        ],
      );
    }();

    final EdgeInsetsGeometry padding = widget.padding ??
        (iconOnly
            ? const EdgeInsets.all(NorthstarButton._iconOnlyPadding)
            : const EdgeInsets.symmetric(
                horizontal: NorthstarButton._hPadding,
              ));

    Widget button = Material(
      key: kButton,
      color: paint.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NorthstarButton._radius),
        side: paint.borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _blocked ? null : widget.onPressed,
        onHighlightChanged: widget.interactionPreview !=
                NorthstarButtonInteractionPreview.none
            ? null
            : (bool v) => setState(() => _pressed = v),
        hoverColor: paint.hoverOverlay,
        highlightColor: paint.highlightOverlay,
        splashColor: paint.splashColor,
        borderRadius: BorderRadius.circular(NorthstarButton._radius),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: iconOnly ? NorthstarButton._height : 0,
            minHeight: NorthstarButton._height,
            maxHeight: NorthstarButton._height,
          ),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: iconOnly ? 1 : null,
              child: content,
            ),
          ),
        ),
      ),
    );

    if (widget.interactionPreview == NorthstarButtonInteractionPreview.none) {
      button = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: button,
      );
    }

    if (widget.width != null) {
      button = SizedBox(
        width: widget.width,
        child: button,
      );
    }

    if (widget.semanticLabel != null) {
      button = Semantics(
        button: true,
        enabled: !_blocked,
        label: widget.semanticLabel,
        child: button,
      );
    }

    if (widget.margin != null) {
      button = Padding(
        padding: widget.margin!,
        child: button,
      );
    }

    return button;
  }
}

/// Resolved accent + on-accent + soft fill for disabled/loading primary.
@immutable
final class _ButtonPalette {
  const _ButtonPalette({
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.hasForegroundOverride,
  });

  final Color accent;
  final Color onAccent;
  final Color accentSoft;

  /// True when [NorthstarButton.foregroundColor] was set (affects secondary/tertiary active fg).
  final bool hasForegroundOverride;

  factory _ButtonPalette.from({
    required NorthstarColorTokens tokens,
    required NorthstarButtonTone tone,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final Color baseAccent = switch (tone) {
      NorthstarButtonTone.standard => tokens.primary,
      NorthstarButtonTone.positive => tokens.success,
      NorthstarButtonTone.negative => tokens.error,
    };
    final Color accent = backgroundColor ?? baseAccent;

    final Color baseOnAccent = switch (tone) {
      NorthstarButtonTone.standard => tokens.onPrimary,
      NorthstarButtonTone.positive => tokens.onSuccess,
      NorthstarButtonTone.negative => tokens.onError,
    };
    final Color onAccent = foregroundColor ?? baseOnAccent;

    final Color accentSoft = backgroundColor != null
        ? Color.alphaBlend(accent.withValues(alpha: 0.34), tokens.surface)
        : switch (tone) {
            NorthstarButtonTone.standard => tokens.primaryContainer,
            NorthstarButtonTone.positive => Color.alphaBlend(
                tokens.success.withValues(alpha: 0.3),
                tokens.surface,
              ),
            NorthstarButtonTone.negative => Color.alphaBlend(
                tokens.error.withValues(alpha: 0.26),
                tokens.surface,
              ),
          };

    return _ButtonPalette(
      accent: accent,
      onAccent: onAccent,
      accentSoft: accentSoft,
      hasForegroundOverride: foregroundColor != null,
    );
  }
}

class _NorthstarButtonPaint {
  const _NorthstarButtonPaint({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderSide,
    required this.hoverOverlay,
    required this.highlightOverlay,
    required this.splashColor,
    required this.spinnerColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide borderSide;
  final Color hoverOverlay;
  final Color highlightOverlay;
  final Color splashColor;
  final Color spinnerColor;

  static Color _darken(Color c, double t) => Color.lerp(c, Colors.black, t)!;

  static _NorthstarButtonPaint resolve({
    required NorthstarButtonVariant variant,
    required NorthstarColorTokens tokens,
    required Set<WidgetState> states,
    required bool isLoading,
    required NorthstarButtonTone tone,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final bool disabled = states.contains(WidgetState.disabled);
    final bool pressed = states.contains(WidgetState.pressed);
    final bool hovered = states.contains(WidgetState.hovered);

    final _ButtonPalette p = _ButtonPalette.from(
      tokens: tokens,
      tone: tone,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );

    switch (variant) {
      case NorthstarButtonVariant.primary:
        return _primary(
          p: p,
          disabled: disabled,
          pressed: pressed,
          hovered: hovered,
          loading: isLoading,
        );
      case NorthstarButtonVariant.secondary:
        return _secondary(
          p: p,
          tokens: tokens,
          disabled: disabled,
          pressed: pressed,
          hovered: hovered,
          loading: isLoading,
        );
      case NorthstarButtonVariant.tertiary:
        return _tertiary(
          p: p,
          tokens: tokens,
          disabled: disabled,
          pressed: pressed,
          hovered: hovered,
          loading: isLoading,
        );
      case NorthstarButtonVariant.iconOnly:
        return _iconOnly(
          p: p,
          tokens: tokens,
          disabled: disabled,
          pressed: pressed,
          hovered: hovered,
          loading: isLoading,
        );
    }
  }

  static _NorthstarButtonPaint _primary({
    required _ButtonPalette p,
    required bool disabled,
    required bool pressed,
    required bool hovered,
    required bool loading,
  }) {
    final Color onP = p.onAccent;
    if (loading || disabled) {
      return _NorthstarButtonPaint(
        backgroundColor: p.accentSoft,
        foregroundColor: onP.withValues(alpha: 0.72),
        borderSide: BorderSide.none,
        hoverOverlay: Colors.transparent,
        highlightOverlay: onP.withValues(alpha: 0.08),
        splashColor: onP.withValues(alpha: 0.12),
        spinnerColor: onP.withValues(alpha: 0.9),
      );
    }
    Color bg = p.accent;
    if (pressed) {
      bg = _darken(p.accent, 0.22);
    } else if (hovered) {
      bg = _darken(p.accent, 0.08);
    }
    return _NorthstarButtonPaint(
      backgroundColor: bg,
      foregroundColor: onP,
      borderSide: BorderSide.none,
      hoverOverlay: onP.withValues(alpha: 0.06),
      highlightOverlay: onP.withValues(alpha: 0.1),
      splashColor: onP.withValues(alpha: 0.14),
      spinnerColor: onP,
    );
  }

  static _NorthstarButtonPaint _secondary({
    required _ButtonPalette p,
    required NorthstarColorTokens tokens,
    required bool disabled,
    required bool pressed,
    required bool hovered,
    required bool loading,
  }) {
    final Color a = p.accent;
    if (loading) {
      return _NorthstarButtonPaint(
        backgroundColor: tokens.surface,
        foregroundColor: a.withValues(alpha: 0.85),
        borderSide: BorderSide(
          color: a.withValues(alpha: 0.45),
        ),
        hoverOverlay: a.withValues(alpha: 0.04),
        highlightOverlay: a.withValues(alpha: 0.06),
        splashColor: a.withValues(alpha: 0.08),
        spinnerColor: a.withValues(alpha: 0.7),
      );
    }
    if (disabled) {
      return _NorthstarButtonPaint(
        backgroundColor: tokens.surface,
        foregroundColor: tokens.outlineVariant.withValues(alpha: 0.75),
        borderSide: BorderSide(
          color: tokens.outlineVariant.withValues(alpha: 0.55),
        ),
        hoverOverlay: Colors.transparent,
        highlightOverlay: Colors.transparent,
        splashColor: Colors.transparent,
        spinnerColor: tokens.outlineVariant,
      );
    }
    Color border = tokens.outlineVariant;
    Color fg = tokens.onSurface;
    Color bg = tokens.surface;
    if (pressed) {
      border = a;
      fg = p.hasForegroundOverride ? p.onAccent : a;
      bg = Color.alphaBlend(
        a.withValues(alpha: 0.08),
        tokens.surface,
      );
    } else if (hovered) {
      border = a;
      fg = p.hasForegroundOverride ? p.onAccent : a;
    }
    return _NorthstarButtonPaint(
      backgroundColor: bg,
      foregroundColor: fg,
      borderSide: BorderSide(color: border),
      hoverOverlay: a.withValues(alpha: 0.04),
      highlightOverlay: a.withValues(alpha: 0.07),
      splashColor: a.withValues(alpha: 0.1),
      spinnerColor: a,
    );
  }

  static _NorthstarButtonPaint _tertiary({
    required _ButtonPalette p,
    required NorthstarColorTokens tokens,
    required bool disabled,
    required bool pressed,
    required bool hovered,
    required bool loading,
  }) {
    final Color a = p.accent;
    if (loading) {
      return _NorthstarButtonPaint(
        backgroundColor: Colors.transparent,
        foregroundColor: a.withValues(alpha: 0.72),
        borderSide: BorderSide.none,
        hoverOverlay: Colors.transparent,
        highlightOverlay: Colors.transparent,
        splashColor: a.withValues(alpha: 0.08),
        spinnerColor: a.withValues(alpha: 0.65),
      );
    }
    if (disabled) {
      return _NorthstarButtonPaint(
        backgroundColor: Colors.transparent,
        foregroundColor: tokens.outlineVariant,
        borderSide: BorderSide.none,
        hoverOverlay: Colors.transparent,
        highlightOverlay: Colors.transparent,
        splashColor: Colors.transparent,
        spinnerColor: tokens.outlineVariant,
      );
    }
    // Idle uses onSurface so label stays visible on any host background; hover
    // / press switch to accent (or foreground override).
    final Color fg = (hovered || pressed)
        ? (p.hasForegroundOverride ? p.onAccent : a)
        : tokens.onSurface;
    return _NorthstarButtonPaint(
      backgroundColor: Colors.transparent,
      foregroundColor: fg,
      borderSide: BorderSide.none,
      hoverOverlay: a.withValues(alpha: 0.06),
      highlightOverlay: a.withValues(alpha: 0.09),
      splashColor: a.withValues(alpha: 0.12),
      spinnerColor: a,
    );
  }

  static _NorthstarButtonPaint _iconOnly({
    required _ButtonPalette p,
    required NorthstarColorTokens tokens,
    required bool disabled,
    required bool pressed,
    required bool hovered,
    required bool loading,
  }) {
    final Color a = p.accent;
    if (loading) {
      return _NorthstarButtonPaint(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        borderSide: BorderSide.none,
        hoverOverlay: Colors.transparent,
        highlightOverlay: Colors.transparent,
        splashColor: a.withValues(alpha: 0.08),
        spinnerColor: a.withValues(alpha: 0.65),
      );
    }
    if (disabled) {
      return _NorthstarButtonPaint(
        backgroundColor: Colors.transparent,
        foregroundColor: tokens.outlineVariant,
        borderSide: BorderSide.none,
        hoverOverlay: Colors.transparent,
        highlightOverlay: Colors.transparent,
        splashColor: Colors.transparent,
        spinnerColor: tokens.outlineVariant,
      );
    }
    final Color fg = (hovered || pressed)
        ? (p.hasForegroundOverride ? p.onAccent : a)
        : tokens.onSurface;
    final bool surfaceTint = hovered || pressed;
    final Color bg = surfaceTint
        ? tokens.surfaceContainerHigh.withValues(alpha: 0.85)
        : Colors.transparent;
    return _NorthstarButtonPaint(
      backgroundColor: bg,
      foregroundColor: fg,
      borderSide: BorderSide.none,
      hoverOverlay: surfaceTint
          ? Colors.transparent
          : tokens.surfaceContainerHigh.withValues(alpha: 0.35),
      highlightOverlay: surfaceTint
          ? Colors.transparent
          : tokens.surfaceContainerHigh.withValues(alpha: 0.45),
      splashColor: tokens.onSurface.withValues(alpha: 0.08),
      spinnerColor: a,
    );
  }
}
