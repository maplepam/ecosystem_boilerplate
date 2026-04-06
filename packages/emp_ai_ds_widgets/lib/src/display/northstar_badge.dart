import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import '../testing/ds_automation_keys.dart';

/// Semantic palette (Figma green / red / yellow / blue / grey).
enum NorthstarBadgeSemantic {
  /// Live, online, active (green).
  positive,

  /// Alert, error (red).
  negative,

  /// Warning, away (yellow / amber).
  warning,

  /// Information, primary (blue).
  info,

  /// Offline, disabled (grey).
  neutral,
}

/// Visual shape / content mode for [NorthstarBadge].
enum NorthstarBadgeVariant {
  /// Solid dot only.
  status,

  /// Circular badge with a contrasting glyph ([icon] required).
  icon,

  /// 1–2 numeric characters, circular ([label] required, e.g. `'3'`, `'12'`).
  digits,

  /// Longer text, pill ([label] required; design **10px** type).
  label,
}

/// Where [NorthstarBadged] places the badge relative to the child’s **top-end**
/// corner (LTR: top-right).
enum NorthstarBadgePlacement {
  /// Fully inside the child, with [NorthstarBadged.inset] padding (status dots).
  insetTopEnd,

  /// Badge **center** on the corner point; half extends outside (counts / icons).
  centeredOnCornerTopEnd,
}

/// Northstar **badge / status indicator**: status dot, icon circle, 1–2 digits, or
/// text pill; optional contrasting **border** for overlap (e.g. on avatars). When
/// [showBorder] is true and [borderColor] is null, [NorthstarColorTokens.surface]
/// is used.
///
/// Use named constructors [NorthstarBadge.status], [.icon], [.digits], [.label].
class NorthstarBadge extends StatelessWidget {
  const NorthstarBadge._({
    super.key,
    required this.variant,
    required this.semantic,
    this.icon,
    this.label,
    this.statusDiameter = 10,
    this.iconBadgeSize = 18,
    this.iconGlyphSize = 12,
    this.digitMinHeight = 18,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.backgroundColor,
    this.foregroundColor,
    this.automationId,
  });

  /// Small solid dot.
  factory NorthstarBadge.status({
    Key? key,
    required NorthstarBadgeSemantic semantic,
    double diameter = 10,
    bool showBorder = false,
    Color? borderColor,
    double borderWidth = 2,
    Color? backgroundColor,
    String? automationId,
  }) {
    return NorthstarBadge._(
      key: key,
      variant: NorthstarBadgeVariant.status,
      semantic: semantic,
      statusDiameter: diameter,
      showBorder: showBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      automationId: automationId,
    );
  }

  /// Circular badge with [icon] (typically white / on-color).
  factory NorthstarBadge.icon({
    Key? key,
    required NorthstarBadgeSemantic semantic,
    required IconData icon,
    double badgeSize = 18,
    double iconSize = 12,
    bool showBorder = false,
    Color? borderColor,
    double borderWidth = 2,
    Color? backgroundColor,
    Color? foregroundColor,
    String? automationId,
  }) {
    return NorthstarBadge._(
      key: key,
      variant: NorthstarBadgeVariant.icon,
      semantic: semantic,
      icon: icon,
      iconBadgeSize: badgeSize,
      iconGlyphSize: iconSize,
      showBorder: showBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      automationId: automationId,
    );
  }

  /// 1–2 digit count; circular.
  factory NorthstarBadge.digits({
    Key? key,
    required NorthstarBadgeSemantic semantic,
    required String value,
    double minHeight = 18,
    bool showBorder = false,
    Color? borderColor,
    double borderWidth = 2,
    Color? backgroundColor,
    Color? foregroundColor,
    String? automationId,
  }) {
    assert(
      value.length <= 2 && RegExp(r'^\d{1,2}$').hasMatch(value),
      'digits: use 1–2 numeric characters only',
    );
    return NorthstarBadge._(
      key: key,
      variant: NorthstarBadgeVariant.digits,
      semantic: semantic,
      label: value,
      digitMinHeight: minHeight,
      showBorder: showBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      automationId: automationId,
    );
  }

  /// Pill for **3+** characters (or non-numeric labels like `NEW`).
  factory NorthstarBadge.label({
    Key? key,
    required NorthstarBadgeSemantic semantic,
    required String text,
    bool showBorder = false,
    Color? borderColor,
    double borderWidth = 2,
    Color? backgroundColor,
    Color? foregroundColor,
    String? automationId,
  }) {
    assert(text.isNotEmpty, 'label: text must be non-empty');
    return NorthstarBadge._(
      key: key,
      variant: NorthstarBadgeVariant.label,
      semantic: semantic,
      label: text,
      showBorder: showBorder,
      borderColor: borderColor,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      automationId: automationId,
    );
  }

  final NorthstarBadgeVariant variant;
  final NorthstarBadgeSemantic semantic;
  final IconData? icon;
  final String? label;

  final double statusDiameter;
  final double iconBadgeSize;
  final double iconGlyphSize;
  final double digitMinHeight;

  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final String? automationId;

  static const double _labelFontSize = 10;

  static Color _fill(
      NorthstarColorTokens ns, NorthstarBadgeSemantic s, Color? override) {
    if (override != null) {
      return override;
    }
    return switch (s) {
      NorthstarBadgeSemantic.positive => ns.success,
      NorthstarBadgeSemantic.negative => ns.error,
      NorthstarBadgeSemantic.warning => ns.warning,
      NorthstarBadgeSemantic.info => ns.primary,
      NorthstarBadgeSemantic.neutral => ns.outline,
    };
  }

  static Color _onFill(
      NorthstarColorTokens ns, NorthstarBadgeSemantic s, Color? override) {
    if (override != null) {
      return override;
    }
    return switch (s) {
      NorthstarBadgeSemantic.positive => ns.onSuccess,
      NorthstarBadgeSemantic.negative => ns.onError,
      NorthstarBadgeSemantic.warning => ns.onWarning,
      NorthstarBadgeSemantic.info => ns.onPrimary,
      NorthstarBadgeSemantic.neutral => ns.onSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Color fill = _fill(ns, semantic, backgroundColor);
    final Color fg = _onFill(ns, semantic, foregroundColor);
    final Color resolvedBorder = borderColor ?? ns.surface;

    final ValueKey<String>? kBadge =
        DsAutomationKeys.part(automationId, DsAutomationKeys.elementBadge);
    final ValueKey<String>? kText =
        DsAutomationKeys.part(automationId, DsAutomationKeys.elementBadgeLabel);

    BoxDecoration deco({required BorderRadius radius}) {
      return BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: showBorder
            ? Border.all(color: resolvedBorder, width: borderWidth)
            : null,
      );
    }

    final Widget core;
    switch (variant) {
      case NorthstarBadgeVariant.status:
        core = Container(
          width: statusDiameter,
          height: statusDiameter,
          decoration: deco(radius: BorderRadius.circular(statusDiameter / 2)),
        );
        break;
      case NorthstarBadgeVariant.icon:
        assert(icon != null, 'icon variant requires icon');
        core = Container(
          width: iconBadgeSize,
          height: iconBadgeSize,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(color: resolvedBorder, width: borderWidth)
                : null,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconGlyphSize,
            color: fg,
          ),
        );
        break;
      case NorthstarBadgeVariant.digits:
        core = Container(
          constraints: BoxConstraints(
              minHeight: digitMinHeight, minWidth: digitMinHeight),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: deco(radius: BorderRadius.circular(digitMinHeight / 2)),
          alignment: Alignment.center,
          child: Text(
            label!,
            key: kText,
            style: TextStyle(
              color: fg,
              fontSize: _labelFontSize,
              height: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        break;
      case NorthstarBadgeVariant.label:
        core = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: NorthstarSpacing.space8,
            vertical: 3,
          ),
          decoration: deco(radius: BorderRadius.circular(999)),
          child: Text(
            label!,
            key: kText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg,
              fontSize: _labelFontSize,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
        break;
    }

    final Widget withKey =
        kBadge != null ? KeyedSubtree(key: kBadge, child: core) : core;

    return Semantics(
      label: _semanticsLabel(),
      child: withKey,
    );
  }

  String _semanticsLabel() {
    return switch (variant) {
      NorthstarBadgeVariant.status => 'Status',
      NorthstarBadgeVariant.icon => 'Badge',
      NorthstarBadgeVariant.digits => 'Count ${label ?? ''}',
      NorthstarBadgeVariant.label => label ?? 'Badge',
    };
  }
}

/// Overlays a [badge] on [child] at the **top-end** corner (LTR: top-right;
/// e.g. bell + count, title + status dot).
///
/// [centeredOnCornerTopEnd] aligns the **center** of the badge to the child’s
/// top-end corner ([FractionalTranslation] −½× child size) — works for any
/// badge width (digits, pills). [insetTopEnd] keeps the badge fully inside
/// with [inset] padding (status dots on cards / titles).
class NorthstarBadged extends StatelessWidget {
  const NorthstarBadged({
    super.key,
    required this.child,
    required this.badge,
    this.placement = NorthstarBadgePlacement.insetTopEnd,
    this.inset = const EdgeInsetsDirectional.only(
      top: NorthstarSpacing.space4,
      end: NorthstarSpacing.space4,
    ),
  });

  final Widget child;
  final Widget badge;
  final NorthstarBadgePlacement placement;
  final EdgeInsetsDirectional inset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        child,
        switch (placement) {
          NorthstarBadgePlacement.insetTopEnd => PositionedDirectional(
              top: inset.top,
              end: inset.end,
              child: badge,
            ),
          NorthstarBadgePlacement.centeredOnCornerTopEnd =>
            PositionedDirectional(
              top: 0,
              end: 0,
              child: Builder(
                builder: (BuildContext context) {
                  // LTR: top-end is top-right — shift left/up by half size.
                  // RTL: top-end is top-left — shift right/up so the center sits on
                  // the corner (FractionalTranslation uses -dx = left in both cases).
                  final TextDirection dir = Directionality.of(context);
                  final double dx = dir == TextDirection.rtl ? 0.5 : -0.5;
                  return FractionalTranslation(
                    translation: Offset(dx, -0.5),
                    child: badge,
                  );
                },
              ),
            ),
        },
      ],
    );
  }
}
