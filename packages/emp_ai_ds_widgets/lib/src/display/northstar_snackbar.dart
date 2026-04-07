import 'dart:math' as math;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void _postFrameVoid(VoidCallback action) {
  SchedulerBinding.instance.addPostFrameCallback((_) => action());
}

/// Snackbar semantic accent (Figma **Snackbars** — left stripe).
enum NorthstarSnackbarKind {
  success,
  warning,
  error,
  neutral,
}

/// **[standard]** uses [NorthstarColorTokens.surface]; **[inverse]** uses
/// [NorthstarColorTokens.inverseSurface] (Material “on-inverse” contrast).
/// In **light** themes the bar is typically light vs dark; in **dark** themes
/// **surface** is dark and **inverseSurface** is light, so appearances swap.
enum NorthstarSnackbarSurfaceVariant {
  standard,
  inverse,
}

/// Anchor for floating snack placement. Default **[bottomLeft]** uses **88** start
/// and **48** bottom inset (Figma).
enum NorthstarSnackbarPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomRight,
  bottomCenter,
}

/// Text action to the right of the message (Figma **Action group**).
@immutable
class NorthstarSnackbarAction {
  const NorthstarSnackbarAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

/// Northstar **Snackbar** surface: **4px** left accent, message, optional text actions
/// (**24px** gaps), optional close.
///
/// **Width:** content **hugs** between **272** and **480** logical px (Figma **Width**).
///
/// **Spacing (Figma):** vertical padding **16**; **8** after accent; **16** end;
/// **24** between message, actions, and close. Message is **start**-aligned; actions
/// and close sit on the **trailing** side, **center**-aligned with the text block.
///
/// For placement and timing, use [showNorthstarSnackBar] (default **bottomLeft**,
/// **48** bottom / **88** start). For **bulk / selection** bars, use
/// [showNorthstarBulkSnackBar] with [NorthstarBatchActionBar] (**always** bottom
/// center, width hugs content; pass **overlayDismissAfter** on the show helper
/// for timed overlay removal).
class NorthstarSnackbar extends StatelessWidget {
  const NorthstarSnackbar({
    super.key,
    this.automationId,
    required this.message,
    this.kind = NorthstarSnackbarKind.neutral,
    this.surfaceVariant = NorthstarSnackbarSurfaceVariant.standard,
    this.actions = const <NorthstarSnackbarAction>[],
    this.showClose = true,
    this.onClose,
    this.heightOverride,
  });

  final String? automationId;
  final String message;
  final NorthstarSnackbarKind kind;
  final NorthstarSnackbarSurfaceVariant surfaceVariant;
  final List<NorthstarSnackbarAction> actions;
  final bool showClose;
  final VoidCallback? onClose;

  /// When set (e.g. **56** for top overlay toasts), vertical padding tightens and
  /// the message uses a single line with ellipsis so the bar does not stretch
  /// the overlay.
  final double? heightOverride;

  static const double minWidth = 272;
  static const double maxWidth = 480;
  /// Material top snack height (Figma single-line toast slot).
  static const double topOverlayHeight = 56;
  static const double _accentWidth = 4;

  /// Horizontal budget for actions + close only (the **24** gap after the message
  /// is accounted for separately as [gapBeforeTrailing]).
  static double _trailingReserve(
    List<NorthstarSnackbarAction> actions,
    bool showClose,
  ) {
    const double perActionSlot = 96;
    const double closeSlot = 56;
    if (actions.isEmpty && !showClose) {
      return 0;
    }
    double w = 0;
    for (var i = 0; i < actions.length; i++) {
      if (i > 0) {
        w += NorthstarSpacing.space24;
      }
      w += perActionSlot;
    }
    if (showClose) {
      w += (actions.isNotEmpty ? NorthstarSpacing.space24 : 0) + closeSlot;
    }
    return w;
  }

  static Color _accentColor(
    NorthstarSnackbarKind k,
    NorthstarColorTokens tokens,
  ) {
    return switch (k) {
      NorthstarSnackbarKind.success => tokens.success,
      NorthstarSnackbarKind.warning => tokens.warning,
      NorthstarSnackbarKind.error => tokens.error,
      NorthstarSnackbarKind.neutral => tokens.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Color accent = _accentColor(kind, ns);

    final bool inverse = surfaceVariant == NorthstarSnackbarSurfaceVariant.inverse;
    final Color surface = inverse ? ns.inverseSurface : ns.surface;
    final Color onMsg = inverse ? ns.onInverseSurface : ns.onSurface;
    final Color secondary = inverse
        ? ns.onInverseSurface.withValues(alpha: 0.75)
        : ns.onSurfaceVariant;
    final Color link = inverse ? ns.primary : ns.primary;

    return LayoutBuilder(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementSnackbar,
      ),
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextStyle? messageStyle = textTheme.bodyMedium?.copyWith(
          color: onMsg,
          fontWeight: FontWeight.w600,
        );
        final bool compactHeight = heightOverride != null;
        final int messageMaxLines = compactHeight ? 1 : 8;
        final double verticalPad =
            compactHeight ? NorthstarSpacing.space8 : NorthstarSpacing.space16;
        final double parentMax = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : NorthstarSnackbar.maxWidth;
        final double maxBar = math.min(NorthstarSnackbar.maxWidth, parentMax);
        final double minBar = math.min(NorthstarSnackbar.minWidth, parentMax);
        final double trailingR = _trailingReserve(actions, showClose);
        const double horizontalPad =
            NorthstarSpacing.space8 + NorthstarSpacing.space16;
        final bool hasTrailing = actions.isNotEmpty || showClose;
        final double gapBeforeTrailing =
            hasTrailing ? NorthstarSpacing.space24 : 0;
        final double innerBudgetAtMax =
            maxBar - _accentWidth - horizontalPad;
        final double messageMaxForMeasure = math.max(
          0.0,
          innerBudgetAtMax - gapBeforeTrailing - trailingR,
        );

        final TextPainter measurePainter = TextPainter(
          text: TextSpan(text: message, style: messageStyle),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: messageMaxLines,
          ellipsis: '…',
        )..layout(
            maxWidth: messageMaxForMeasure > 0
                ? messageMaxForMeasure
                : double.infinity,
          );
        final double textW = measurePainter.size.width;
        final double measuredTextH = measurePainter.size.height;
        measurePainter.dispose();

        final double naturalOuter = _accentWidth +
            horizontalPad +
            textW +
            gapBeforeTrailing +
            trailingR;
        final double barW = naturalOuter.clamp(minBar, maxBar);

        final double rowCrossH = compactHeight
            ? heightOverride!
            : math.max(
                measuredTextH + 2 * verticalPad,
                math.max(hasTrailing ? 44.0 : 0.0, 48.0),
              );

        final Widget bar = Material(
          elevation: 3,
          shadowColor: onMsg.withValues(alpha: 0.12),
          color: surface,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              SizedBox(
                width: _accentWidth,
                height: rowCrossH,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    NorthstarSpacing.space8,
                    verticalPad,
                    NorthstarSpacing.space16,
                    verticalPad,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            message,
                            key: DsAutomationKeys.part(
                              automationId,
                              DsAutomationKeys.elementSnackbarMessage,
                            ),
                            textAlign: TextAlign.start,
                            maxLines: messageMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: messageStyle,
                          ),
                        ),
                      ),
                        if (hasTrailing) ...<Widget>[
                          const SizedBox(width: NorthstarSpacing.space24),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              for (var i = 0; i < actions.length; i++) ...<Widget>[
                                if (i > 0)
                                  const SizedBox(width: NorthstarSpacing.space24),
                                TextButton(
                                  key: DsAutomationKeys.part(
                                    automationId,
                                    '${DsAutomationKeys.elementSnackbarAction}_$i',
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: link,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: NorthstarSpacing.space8,
                                      vertical: NorthstarSpacing.space4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: actions[i].onPressed,
                                  child: Text(actions[i].label),
                                ),
                              ],
                              if (showClose) ...<Widget>[
                                if (actions.isNotEmpty)
                                  const SizedBox(
                                    width: NorthstarSpacing.space24,
                                  ),
                                IconButton(
                                  key: DsAutomationKeys.part(
                                    automationId,
                                    DsAutomationKeys.elementSnackbarClose,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: secondary,
                                  ),
                                  onPressed: onClose,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

        if (heightOverride != null) {
          return SizedBox(
            width: barW,
            height: heightOverride,
            child: bar,
          );
        }
        return SizedBox(
          width: barW,
          child: bar,
        );
      },
    );
  }
}

/// Default Figma insets for edge-aligned snack positions.
const double kNorthstarSnackbarEdgeInset = 88;
const double kNorthstarSnackbarMinorInset = 16;
const double kNorthstarSnackbarVerticalInset = 48;

/// Places the snack **card** in the wide [SnackBar] slot without a full-width
/// [Align] for start/end (avoids a huge hit target and mouse-tracker edge cases).
/// Bottom **center** still uses [widthFactor] 1 so the card centers horizontally.
Widget _wrapBottomSnackInWideSlot(
  NorthstarSnackbarPosition position,
  Widget snack,
) {
  return switch (position) {
    NorthstarSnackbarPosition.bottomCenter => Align(
        widthFactor: 1,
        alignment: Alignment.bottomCenter,
        child: snack,
      ),
    NorthstarSnackbarPosition.bottomRight => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: snack,
      ),
    NorthstarSnackbarPosition.bottomLeft => Align(
        alignment: AlignmentDirectional.centerStart,
        child: snack,
      ),
    _ => Align(
        alignment: AlignmentDirectional.centerStart,
        child: snack,
      ),
  };
}

/// Bottom-center bulk bar: hug intrinsic width, capped by the snack bar slot.
Widget _wrapBulkSnackBarHugWidth(Widget child) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: IntrinsicWidth(child: child),
        );
      },
    ),
  );
}

EdgeInsetsGeometry _snackBarMargin(
  BuildContext context,
  NorthstarSnackbarPosition position,
) {
  final double w = MediaQuery.sizeOf(context).width;
  final double centerSide = ((w - NorthstarSnackbar.maxWidth) / 2)
      .clamp(kNorthstarSnackbarMinorInset, 4000.0);

  return switch (position) {
    NorthstarSnackbarPosition.bottomLeft => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarEdgeInset,
        end: kNorthstarSnackbarMinorInset,
        bottom: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.bottomRight => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarMinorInset,
        end: kNorthstarSnackbarEdgeInset,
        bottom: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.bottomCenter => EdgeInsets.fromLTRB(
        centerSide,
        0,
        centerSide,
        kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.topLeft => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarEdgeInset,
        end: kNorthstarSnackbarMinorInset,
        top: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.topRight => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarMinorInset,
        end: kNorthstarSnackbarEdgeInset,
        top: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.topCenter => EdgeInsets.fromLTRB(
        centerSide,
        kNorthstarSnackbarVerticalInset,
        centerSide,
        0,
      ),
  };
}

/// Margins for [showNorthstarBulkSnackBar]: edge insets for bottom-center
/// placement (**no** 480px cap). Bar width **hugs** content up to the remaining
/// viewport width inside these insets.
EdgeInsetsGeometry _bulkSnackBarMargin(NorthstarSnackbarPosition position) {
  return switch (position) {
    NorthstarSnackbarPosition.bottomLeft => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarEdgeInset,
        end: kNorthstarSnackbarMinorInset,
        bottom: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.bottomRight => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarMinorInset,
        end: kNorthstarSnackbarEdgeInset,
        bottom: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.bottomCenter => const EdgeInsets.fromLTRB(
        kNorthstarSnackbarMinorInset,
        0,
        kNorthstarSnackbarMinorInset,
        kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.topLeft => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarEdgeInset,
        end: kNorthstarSnackbarMinorInset,
        top: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.topRight => const EdgeInsetsDirectional.only(
        start: kNorthstarSnackbarMinorInset,
        end: kNorthstarSnackbarEdgeInset,
        top: kNorthstarSnackbarVerticalInset,
      ),
    NorthstarSnackbarPosition.topCenter => const EdgeInsets.only(
        left: kNorthstarSnackbarMinorInset,
        right: kNorthstarSnackbarMinorInset,
        top: kNorthstarSnackbarVerticalInset,
      ),
  };
}

/// Positions [child] in a [Stack] using viewport-relative [pad] (from
/// [_snackBarMargin] or [_bulkSnackBarMargin]).
Widget _positionSnackOnOverlay(
  NorthstarSnackbarPosition position,
  EdgeInsets pad,
  Widget child,
) {
  return switch (position) {
    NorthstarSnackbarPosition.topLeft => Positioned(
        left: pad.left,
        top: pad.top,
        child: child,
      ),
    NorthstarSnackbarPosition.topRight => Positioned(
        right: pad.right,
        top: pad.top,
        child: child,
      ),
    NorthstarSnackbarPosition.topCenter => Positioned(
        left: pad.left,
        right: pad.right,
        top: pad.top,
        child: Center(child: child),
      ),
    NorthstarSnackbarPosition.bottomLeft => Positioned(
        left: pad.left,
        bottom: pad.bottom,
        child: child,
      ),
    NorthstarSnackbarPosition.bottomRight => Positioned(
        right: pad.right,
        bottom: pad.bottom,
        child: child,
      ),
    NorthstarSnackbarPosition.bottomCenter => Positioned(
        left: pad.left,
        right: pad.right,
        bottom: pad.bottom,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      ),
  };
}

/// Returns **false** if no [Overlay] was found (caller should use scaffold).
bool _showNorthstarSnackBarOverlay(
  BuildContext context, {
  required NorthstarSnackbarPosition position,
  required Duration duration,
  required bool persistUntilDismissed,
  required Widget Function(VoidCallback dismiss) builder,
}) {
  final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true) ??
      Overlay.maybeOf(context);
  if (overlay == null) {
    return false;
  }
  var dismissed = false;
  late OverlayEntry entry;
  void dismiss() {
    if (dismissed) {
      return;
    }
    dismissed = true;
    _postFrameVoid(entry.remove);
  }

  entry = OverlayEntry(
    builder: (BuildContext ctx) {
      final EdgeInsets pad =
          _snackBarMargin(ctx, position).resolve(Directionality.of(ctx));
      final Widget snack = builder(dismiss);
      return SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _positionSnackOnOverlay(position, pad, snack),
          ],
        ),
      );
    },
  );
  overlay.insert(entry);
  if (!persistUntilDismissed) {
    Future<void>.delayed(duration, () => _postFrameVoid(dismiss));
  }
  return true;
}

/// Shows a floating snackbar with [NorthstarSnackbar] content.
///
/// Uses the **root** [Overlay] when available so left / center / right anchors
/// use the **full viewport** (not only the local [Scaffold] body). Falls back
/// to [ScaffoldMessenger] when no overlay exists (e.g. rare test harnesses).
void showNorthstarSnackBar(
  BuildContext context, {
  required String message,
  NorthstarSnackbarKind kind = NorthstarSnackbarKind.neutral,
  NorthstarSnackbarSurfaceVariant surfaceVariant =
      NorthstarSnackbarSurfaceVariant.standard,
  List<NorthstarSnackbarAction> actions = const <NorthstarSnackbarAction>[],
  bool showClose = true,
  Duration duration = const Duration(milliseconds: 1500),
  String? automationId,
  bool persistUntilDismissed = false,
  NorthstarSnackbarPosition position = NorthstarSnackbarPosition.bottomLeft,
}) {
  final Duration effectiveDuration =
      persistUntilDismissed ? const Duration(days: 1) : duration;

  final bool isTop = switch (position) {
    NorthstarSnackbarPosition.topLeft ||
    NorthstarSnackbarPosition.topCenter ||
    NorthstarSnackbarPosition.topRight =>
      true,
    _ => false,
  };

  final bool usedOverlay = _showNorthstarSnackBarOverlay(
    context,
    position: position,
    duration: effectiveDuration,
    persistUntilDismissed: persistUntilDismissed,
    builder: (VoidCallback dismiss) {
      return NorthstarSnackbar(
        automationId: automationId,
        message: message,
        kind: kind,
        surfaceVariant: surfaceVariant,
        actions: actions,
        showClose: showClose,
        heightOverride: isTop ? NorthstarSnackbar.topOverlayHeight : null,
        onClose: showClose ? () => _postFrameVoid(dismiss) : null,
      );
    },
  );
  if (usedOverlay) {
    return;
  }

  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  messenger.clearSnackBars();
  final NorthstarSnackbarPosition scaffoldPosition =
      isTop ? NorthstarSnackbarPosition.bottomLeft : position;
  messenger.showSnackBar(
    SnackBar(
      padding: EdgeInsets.zero,
      margin: _snackBarMargin(context, scaffoldPosition),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.none,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: effectiveDuration,
      content: _wrapBottomSnackInWideSlot(
        scaffoldPosition,
        NorthstarSnackbar(
          automationId: automationId,
          message: message,
          kind: kind,
          surfaceVariant: surfaceVariant,
          actions: actions,
          showClose: showClose,
          heightOverride: isTop ? NorthstarSnackbar.topOverlayHeight : null,
          onClose: showClose
              ? () => _postFrameVoid(messenger.hideCurrentSnackBar)
              : null,
        ),
      ),
    ),
  );
}

/// Shows a **bulk / selection** style bar (e.g. [NorthstarBatchActionBar]) on
/// the **root** [Overlay] when possible, **always** anchored **bottom center**,
/// width **hugging** content (capped by viewport minus horizontal margins).
/// By default the overlay entry stays until the route is disposed; set
/// [overlayDismissAfter] (e.g. for catalog demos) to remove it after a delay.
/// [duration] applies only to the [ScaffoldMessenger] fallback when no overlay
/// is available.
void showNorthstarBulkSnackBar(
  BuildContext context, {
  required Widget child,
  Duration duration = const Duration(seconds: 4),
  Duration? overlayDismissAfter,
}) {
  const NorthstarSnackbarPosition bulkPosition =
      NorthstarSnackbarPosition.bottomCenter;

  final OverlayState? overlay = Overlay.maybeOf(context, rootOverlay: true) ??
      Overlay.maybeOf(context);
  if (overlay != null) {
    var dismissed = false;
    late final OverlayEntry entry;
    void dismissOverlay() {
      if (dismissed) {
        return;
      }
      dismissed = true;
      _postFrameVoid(entry.remove);
    }

    entry = OverlayEntry(
      builder: (BuildContext ctx) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final EdgeInsets pad = _bulkSnackBarMargin(bulkPosition)
                  .resolve(Directionality.of(context));
              final double maxBarWidth = math.max(
                0.0,
                constraints.maxWidth - pad.left - pad.right,
              );
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: pad.left,
                        right: pad.right,
                        bottom: pad.bottom,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxBarWidth),
                          child: IntrinsicWidth(child: child),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    overlay.insert(entry);
    final Duration? after = overlayDismissAfter;
    if (after != null) {
      Future<void>.delayed(after, () => _postFrameVoid(dismissOverlay));
    }
    return;
  }

  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      padding: EdgeInsets.zero,
      margin: _bulkSnackBarMargin(bulkPosition),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.none,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: _wrapBulkSnackBarHugWidth(child),
    ),
  );
}
