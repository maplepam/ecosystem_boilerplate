import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import '../testing/ds_automation_keys.dart';
import 'northstar_text_link.dart';

/// Northstar V3 banner surface: **normal** (inline), **system-wide fixed**, or **floating**.
enum NorthstarBannerKind {
  /// Pastel surface + border; sits in page flow ([NorthstarBannerLayout.flow]).
  normal,

  /// High-contrast full-width strip (system alerts). Use [NorthstarBannerLayout.overlay]
  /// inside a [Stack] or [flow] under a host header.
  systemFixed,

  /// Compact solid “toast”; use [NorthstarBannerLayout.overlay] in a [Stack].
  floating,
}

/// Semantic palette (Figma **Status** column).
enum NorthstarBannerStatus {
  success,
  informative,
  warning,
  error,
  neutral,
}

/// Corner / edge placement when [NorthstarBannerLayout.overlay] is used.
enum NorthstarBannerAnchor {
  topCenter,
  bottomCenter,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// How [NorthstarBanner] participates in layout.
enum NorthstarBannerLayout {
  /// Width follows parent; no [Positioned] wrapper.
  flow,

  /// Must be a **direct** child of [Stack]. Wraps in [Positioned] using [anchor].
  overlay,
}

/// Northstar **Banners** (Figma): icon, label, optional body/notes, up to two text
/// actions, optional dismiss.
///
/// **Spacing (anatomy):** 16 padding; 10 between icon and text; 4 between label and
/// body/notes; 32 before actions/close on wide layouts (collapses on narrow).
///
/// **Overlay:** For [NorthstarBannerKind.systemFixed] or [floating] with
/// [NorthstarBannerLayout.overlay], place this widget as a direct [Stack] child.
/// [anchor] and [margin] control inset (default **12** logical px — Figma header gap).
///
/// **Floating hover:** Slightly darkens the solid background on pointer hover (web/desktop).
class NorthstarBanner extends StatefulWidget {
  const NorthstarBanner({
    super.key,
    required this.kind,
    required this.status,
    required this.label,
    this.body,
    this.notes,
    this.layout = NorthstarBannerLayout.flow,
    this.anchor = NorthstarBannerAnchor.topCenter,
    this.margin = const EdgeInsets.all(NorthstarSpacing.space12),
    this.leading,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.showDismissButton = true,
    this.onDismiss,
    this.maxFloatingWidth = 560,
    this.automationId,
  });

  final NorthstarBannerKind kind;

  final NorthstarBannerStatus status;

  final String label;

  final String? body;

  final String? notes;

  final NorthstarBannerLayout layout;

  final NorthstarBannerAnchor anchor;

  /// Insets from the [Stack] edges when [layout] is [NorthstarBannerLayout.overlay].
  final EdgeInsetsGeometry margin;

  /// Replaces the default status icon when non-null.
  final Widget? leading;

  final String? primaryActionLabel;

  final VoidCallback? onPrimaryAction;

  final String? secondaryActionLabel;

  final VoidCallback? onSecondaryAction;

  final bool showDismissButton;

  final VoidCallback? onDismiss;

  /// Max width for [NorthstarBannerKind.floating] in overlay mode.
  final double maxFloatingWidth;

  final String? automationId;

  static const double _iconGap = 10;

  @override
  State<NorthstarBanner> createState() => _NorthstarBannerState();
}

class _NorthstarBannerState extends State<NorthstarBanner> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final _BannerStyle style = _BannerStyle.resolve(
      context,
      widget.kind,
      widget.status,
      widget.kind == NorthstarBannerKind.floating && _hovering,
    );

    final Widget core = _BannerCore(
      style: style,
      label: widget.label,
      body: widget.body,
      notes: widget.notes,
      leading: widget.leading ?? _defaultIcon(widget.status, style.iconColor),
      primaryActionLabel: widget.primaryActionLabel,
      onPrimaryAction: widget.onPrimaryAction,
      secondaryActionLabel: widget.secondaryActionLabel,
      onSecondaryAction: widget.onSecondaryAction,
      showDismissButton: widget.showDismissButton,
      onDismiss: widget.onDismiss,
      automationId: widget.automationId,
      tight: widget.kind == NorthstarBannerKind.floating,
    );

    final Widget surfaced = widget.kind == NorthstarBannerKind.floating
        ? MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: _DecoratedBanner(
              kind: widget.kind,
              style: style,
              child: core,
            ),
          )
        : _DecoratedBanner(
            kind: widget.kind,
            style: style,
            child: core,
          );

    final Widget sized = widget.kind == NorthstarBannerKind.floating &&
            widget.layout == NorthstarBannerLayout.overlay
        ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxFloatingWidth),
            child: surfaced,
          )
        : widget.kind == NorthstarBannerKind.systemFixed &&
                widget.layout == NorthstarBannerLayout.flow
            ? SizedBox(width: double.infinity, child: surfaced)
            : widget.kind == NorthstarBannerKind.normal
                ? SizedBox(width: double.infinity, child: surfaced)
                : surfaced;

    if (widget.layout == NorthstarBannerLayout.flow) {
      return _KeyedBanner(automationId: widget.automationId, child: sized);
    }

    assert(
      widget.kind != NorthstarBannerKind.normal,
      'NorthstarBannerLayout.overlay is for systemFixed or floating.',
    );

    return _KeyedBanner(
      automationId: widget.automationId,
      child: _BannerPositioned(
        anchor: widget.anchor,
        margin: widget.margin,
        child: widget.kind == NorthstarBannerKind.systemFixed &&
                (widget.anchor == NorthstarBannerAnchor.topCenter ||
                    widget.anchor == NorthstarBannerAnchor.bottomCenter)
            ? SizedBox(width: double.infinity, child: sized)
            : Align(
                alignment: _NorthstarBannerState._alignmentFor(widget.anchor),
                child: sized,
              ),
      ),
    );
  }

  static Alignment _alignmentFor(NorthstarBannerAnchor a) {
    return switch (a) {
      NorthstarBannerAnchor.topCenter => Alignment.topCenter,
      NorthstarBannerAnchor.bottomCenter => Alignment.bottomCenter,
      NorthstarBannerAnchor.topLeft => Alignment.topLeft,
      NorthstarBannerAnchor.topRight => Alignment.topRight,
      NorthstarBannerAnchor.bottomLeft => Alignment.bottomLeft,
      NorthstarBannerAnchor.bottomRight => Alignment.bottomRight,
    };
  }

  static Widget _defaultIcon(NorthstarBannerStatus s, Color color) {
    final IconData d = switch (s) {
      NorthstarBannerStatus.success => Icons.check_circle_outline_rounded,
      NorthstarBannerStatus.informative => Icons.info_outline_rounded,
      NorthstarBannerStatus.warning => Icons.warning_amber_rounded,
      NorthstarBannerStatus.error => Icons.error_outline_rounded,
      NorthstarBannerStatus.neutral => Icons.info_outline_rounded,
    };
    return Icon(d, size: 22, color: color);
  }
}

class _KeyedBanner extends StatelessWidget {
  const _KeyedBanner({
    required this.child,
    this.automationId,
  });

  final Widget child;
  final String? automationId;

  @override
  Widget build(BuildContext context) {
    final ValueKey<String>? k = DsAutomationKeys.part(
      automationId,
      DsAutomationKeys.elementBanner,
    );
    if (k != null) {
      return KeyedSubtree(key: k, child: child);
    }
    return child;
  }
}

class _BannerPositioned extends StatelessWidget {
  const _BannerPositioned({
    required this.anchor,
    required this.margin,
    required this.child,
  });

  final NorthstarBannerAnchor anchor;
  final EdgeInsetsGeometry margin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets m = margin.resolve(Directionality.of(context));
    return switch (anchor) {
      NorthstarBannerAnchor.topCenter => Positioned(
          top: m.top,
          left: m.left,
          right: m.right,
          child: child,
        ),
      NorthstarBannerAnchor.bottomCenter => Positioned(
          bottom: m.bottom,
          left: m.left,
          right: m.right,
          child: child,
        ),
      NorthstarBannerAnchor.topLeft => Positioned(
          top: m.top,
          left: m.left,
          child: child,
        ),
      NorthstarBannerAnchor.topRight => Positioned(
          top: m.top,
          right: m.right,
          child: child,
        ),
      NorthstarBannerAnchor.bottomLeft => Positioned(
          bottom: m.bottom,
          left: m.left,
          child: child,
        ),
      NorthstarBannerAnchor.bottomRight => Positioned(
          bottom: m.bottom,
          right: m.right,
          child: child,
        ),
    };
  }
}

class _DecoratedBanner extends StatelessWidget {
  const _DecoratedBanner({
    required this.kind,
    required this.style,
    required this.child,
  });

  final NorthstarBannerKind kind;
  final _BannerStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final BorderRadius r = switch (kind) {
      NorthstarBannerKind.normal => BorderRadius.circular(8),
      NorthstarBannerKind.systemFixed => BorderRadius.circular(8),
      NorthstarBannerKind.floating => BorderRadius.circular(8),
    };

    return Material(
      color: style.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: r,
        side: style.borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: kind == NorthstarBannerKind.systemFixed
            ? const EdgeInsets.symmetric(
                horizontal: NorthstarSpacing.space16,
                vertical: 14,
              )
            : const EdgeInsets.all(NorthstarSpacing.space16),
        child: child,
      ),
    );
  }
}

class _BannerCore extends StatelessWidget {
  const _BannerCore({
    required this.style,
    required this.label,
    required this.body,
    required this.notes,
    required this.leading,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.showDismissButton,
    required this.onDismiss,
    required this.automationId,
    required this.tight,
  });

  final _BannerStyle style;
  final String label;
  final String? body;
  final String? notes;
  final Widget leading;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool showDismissButton;
  final VoidCallback? onDismiss;
  final String? automationId;
  final bool tight;

  /// [Positioned] with only `top`/`left` (e.g. [NorthstarBannerAnchor.topLeft])
  /// gives the row **unbounded** max width — [Expanded] is invalid there; use
  /// [Flexible] with [FlexFit.loose] and [MainAxisSize.min] on the [Row].
  static Widget _flexibleTextColumn(BoxConstraints c, Widget column) {
    if (c.maxWidth.isFinite) {
      return Expanded(
        flex: 1,
        child: column,
      );
    }
    return Flexible(
      fit: FlexFit.loose,
      flex: 1,
      child: column,
    );
  }

  static MainAxisSize _rowMainAxisForWidth(BoxConstraints c) {
    return c.maxWidth.isFinite ? MainAxisSize.max : MainAxisSize.min;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle =
        Theme.of(context).textTheme.titleSmall!.copyWith(
              color: style.foregroundColor,
              fontWeight: FontWeight.w600,
            );

    final TextStyle? bodyStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: style.foregroundColor,
            );

    final TextStyle? notesStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(
              color: style.mutedForegroundColor,
            );

    final Widget textBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: labelStyle),
        if (body != null && body!.isNotEmpty) ...<Widget>[
          const SizedBox(height: NorthstarSpacing.space4),
          Text(body!, style: bodyStyle),
        ],
        if (notes != null && notes!.isNotEmpty) ...<Widget>[
          const SizedBox(height: NorthstarSpacing.space4),
          Text(notes!, style: notesStyle),
        ],
      ],
    );

    final bool hasActions = (primaryActionLabel != null &&
            primaryActionLabel!.isNotEmpty &&
            onPrimaryAction != null) ||
        (secondaryActionLabel != null &&
            secondaryActionLabel!.isNotEmpty &&
            onSecondaryAction != null);

    final Widget? actions =
        hasActions || (showDismissButton && onDismiss != null)
            ? _BannerActionsRow(
                style: style,
                primaryActionLabel: primaryActionLabel,
                onPrimaryAction: onPrimaryAction,
                secondaryActionLabel: secondaryActionLabel,
                onSecondaryAction: onSecondaryAction,
                showDismissButton: showDismissButton,
                onDismiss: onDismiss,
                automationId: automationId,
                tight: tight,
              )
            : null;

    if (tight && actions != null) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: _rowMainAxisForWidth(c),
            children: <Widget>[
              leading,
              const SizedBox(width: NorthstarBanner._iconGap),
              _flexibleTextColumn(c, textBody),
              const SizedBox(width: NorthstarSpacing.space16),
              actions,
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final bool narrow = c.maxWidth < 520;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: _rowMainAxisForWidth(c),
                children: <Widget>[
                  leading,
                  const SizedBox(width: NorthstarBanner._iconGap),
                  _flexibleTextColumn(c, textBody),
                ],
              ),
              if (actions != null) ...<Widget>[
                const SizedBox(height: NorthstarSpacing.space12),
                actions,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: _rowMainAxisForWidth(c),
          children: <Widget>[
            leading,
            const SizedBox(width: NorthstarBanner._iconGap),
            _flexibleTextColumn(c, textBody),
            if (actions != null) ...<Widget>[
              const SizedBox(width: NorthstarSpacing.space32),
              actions,
            ],
          ],
        );
      },
    );
  }
}

class _BannerActionsRow extends StatelessWidget {
  const _BannerActionsRow({
    required this.style,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.showDismissButton,
    required this.onDismiss,
    required this.automationId,
    required this.tight,
  });

  final _BannerStyle style;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool showDismissButton;
  final VoidCallback? onDismiss;
  final String? automationId;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[];

    if (primaryActionLabel != null &&
        primaryActionLabel!.isNotEmpty &&
        onPrimaryAction != null) {
      chips.add(
        _link(
          context,
          primaryActionLabel!,
          onPrimaryAction!,
        ),
      );
    }
    if (secondaryActionLabel != null &&
        secondaryActionLabel!.isNotEmpty &&
        onSecondaryAction != null) {
      if (chips.isNotEmpty) {
        chips.add(const SizedBox(width: NorthstarSpacing.space16));
      }
      chips.add(
        _link(
          context,
          secondaryActionLabel!,
          onSecondaryAction!,
        ),
      );
    }

    final Widget? dismiss = showDismissButton && onDismiss != null
        ? IconButton(
            key: DsAutomationKeys.part(
              automationId,
              DsAutomationKeys.elementBannerDismiss,
            ),
            icon: Icon(Icons.close_rounded,
                color: style.foregroundColor, size: 20),
            tooltip: 'Dismiss',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: onDismiss,
          )
        : null;

    if (tight) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ...chips,
          if (dismiss != null) ...<Widget>[
            if (chips.isNotEmpty)
              const SizedBox(width: NorthstarSpacing.space8),
            dismiss,
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...chips,
        if (dismiss != null) ...<Widget>[
          if (chips.isNotEmpty) const SizedBox(width: NorthstarSpacing.space32),
          dismiss,
        ],
      ],
    );
  }

  Widget _link(BuildContext context, String label, VoidCallback onTap) {
    if (style.onSolidBackground) {
      return TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: style.foregroundColor,
          padding:
              const EdgeInsets.symmetric(horizontal: NorthstarSpacing.space8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            color: style.foregroundColor,
          ),
        ),
      );
    }
    return NorthstarTextLink(
      label: label,
      onTap: onTap,
    );
  }
}

@immutable
class _BannerStyle {
  const _BannerStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.mutedForegroundColor,
    required this.iconColor,
    required this.borderSide,
    required this.onSolidBackground,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color mutedForegroundColor;
  final Color iconColor;
  final BorderSide borderSide;
  final bool onSolidBackground;

  static _BannerStyle resolve(
    BuildContext context,
    NorthstarBannerKind kind,
    NorthstarBannerStatus status,
    bool floatingHovered,
  ) {
    final NorthstarColorTokens t = NorthstarColorTokens.of(context);

    if (kind == NorthstarBannerKind.normal) {
      return switch (status) {
        NorthstarBannerStatus.success => _BannerStyle(
            backgroundColor:
                Color.alphaBlend(t.success.withValues(alpha: 0.14), t.surface),
            foregroundColor: Color.lerp(t.onSurface, t.success, 0.28)!,
            mutedForegroundColor: t.onSurfaceVariant,
            iconColor: t.success,
            borderSide: BorderSide(color: t.success.withValues(alpha: 0.45)),
            onSolidBackground: false,
          ),
        NorthstarBannerStatus.informative => _BannerStyle(
            backgroundColor:
                Color.alphaBlend(t.primary.withValues(alpha: 0.1), t.surface),
            foregroundColor: t.onPrimaryContainer,
            mutedForegroundColor: t.outline,
            iconColor: t.primary,
            borderSide: BorderSide(color: t.primary.withValues(alpha: 0.45)),
            onSolidBackground: false,
          ),
        NorthstarBannerStatus.warning => _BannerStyle(
            backgroundColor:
                Color.alphaBlend(t.warning.withValues(alpha: 0.16), t.surface),
            foregroundColor: t.onWarning,
            mutedForegroundColor: t.onSurfaceVariant,
            iconColor: t.warning,
            borderSide: BorderSide(color: t.warning.withValues(alpha: 0.55)),
            onSolidBackground: false,
          ),
        NorthstarBannerStatus.error => _BannerStyle(
            backgroundColor:
                Color.alphaBlend(t.error.withValues(alpha: 0.1), t.surface),
            foregroundColor: Color.lerp(t.onSurface, t.error, 0.22)!,
            mutedForegroundColor: t.onSurfaceVariant,
            iconColor: t.error,
            borderSide: BorderSide(color: t.error.withValues(alpha: 0.45)),
            onSolidBackground: false,
          ),
        NorthstarBannerStatus.neutral => _BannerStyle(
            backgroundColor: t.surfaceContainerHigh,
            foregroundColor: t.onSurface,
            mutedForegroundColor: t.onSurfaceVariant,
            iconColor: t.onSurfaceVariant,
            borderSide: BorderSide(color: t.outlineVariant),
            onSolidBackground: false,
          ),
      };
    }

    Color bg = switch (status) {
      NorthstarBannerStatus.success => t.success,
      NorthstarBannerStatus.informative => t.primary,
      NorthstarBannerStatus.warning => t.warning,
      NorthstarBannerStatus.error => t.error,
      NorthstarBannerStatus.neutral => t.inverseSurface,
    };

    if (floatingHovered && kind == NorthstarBannerKind.floating) {
      bg = Color.alphaBlend(t.onSurface.withValues(alpha: 0.08), bg);
    }

    final Color fg = switch (status) {
      NorthstarBannerStatus.success => t.onSuccess,
      NorthstarBannerStatus.informative => t.onPrimary,
      NorthstarBannerStatus.warning => t.onWarning,
      NorthstarBannerStatus.error => t.onError,
      NorthstarBannerStatus.neutral => t.onInverseSurface,
    };
    return _BannerStyle(
      backgroundColor: bg,
      foregroundColor: fg,
      mutedForegroundColor: fg.withValues(alpha: 0.85),
      iconColor: fg,
      borderSide: BorderSide.none,
      onSolidBackground: true,
    );
  }
}
