import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';

/// Line axis for [NorthstarDivider].
enum NorthstarDividerOrientation {
  horizontal,
  vertical,
}

/// How the line is inset from the parent (Figma **full-width** / **inset** / **middle-inset**).
enum NorthstarDividerStyle {
  /// Spans the full width (horizontal) or height (vertical) of the available space.
  fullWidth,

  /// Indented from the **start** edge only ([EdgeInsetsDirectional.start] /
  /// **top** for vertical).
  inset,

  /// Indented equally from **both** ends on the cross axis (horizontal → left
  /// + right, vertical → top + bottom).
  middleInset,
}

/// Thin rule for lists, panels, and tables (~**1** logical px by default).
///
/// Optional [color] defaults to [NorthstarColorTokens.outlineVariant].
/// [inset] is used when [style] is [NorthstarDividerStyle.inset] or
/// [NorthstarDividerStyle.middleInset] (default **16** if null).
///
/// [margin] is applied outside; [padding] inside that, around the divider layout.
class NorthstarDivider extends StatelessWidget {
  const NorthstarDivider({
    super.key,
    this.orientation = NorthstarDividerOrientation.horizontal,
    this.style = NorthstarDividerStyle.fullWidth,
    this.thickness = 1,
    this.color,
    this.inset,
    this.margin,
    this.padding,
    this.automationId,
  }) : assert(thickness > 0);

  final NorthstarDividerOrientation orientation;

  final NorthstarDividerStyle style;

  /// Stroke thickness (width of horizontal line, height of vertical line).
  final double thickness;

  final Color? color;

  /// Inset amount when [style] is not [NorthstarDividerStyle.fullWidth].
  final double? inset;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final String? automationId;

  static const double _defaultInset = 16;

  @override
  Widget build(BuildContext context) {
    final Color lineColor =
        color ?? NorthstarColorTokens.of(context).outlineVariant;
    final double insetPx = switch (style) {
      NorthstarDividerStyle.fullWidth => 0,
      NorthstarDividerStyle.inset ||
      NorthstarDividerStyle.middleInset =>
        inset ?? _defaultInset,
    };

    Widget core = orientation == NorthstarDividerOrientation.horizontal
        ? _horizontal(lineColor, insetPx)
        : _vertical(lineColor, insetPx);

    if (padding != null) {
      core = Padding(padding: padding!, child: core);
    }
    if (margin != null) {
      core = Padding(padding: margin!, child: core);
    }

    final ValueKey<String>? k =
        DsAutomationKeys.part(automationId, DsAutomationKeys.elementDivider);
    if (k != null) {
      core = KeyedSubtree(key: k, child: core);
    }

    return core;
  }

  Widget _horizontal(Color lineColor, double insetPx) {
    final BoxDecoration decoration = BoxDecoration(
      color: lineColor,
      borderRadius: BorderRadius.circular(thickness / 2),
    );

    switch (style) {
      case NorthstarDividerStyle.fullWidth:
        return SizedBox(
          height: thickness,
          width: double.infinity,
          child: DecoratedBox(decoration: decoration),
        );
      case NorthstarDividerStyle.inset:
        return Padding(
          padding: EdgeInsetsDirectional.only(start: insetPx),
          child: SizedBox(
            height: thickness,
            width: double.infinity,
            child: DecoratedBox(decoration: decoration),
          ),
        );
      case NorthstarDividerStyle.middleInset:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: insetPx),
          child: SizedBox(
            height: thickness,
            width: double.infinity,
            child: DecoratedBox(decoration: decoration),
          ),
        );
    }
  }

  Widget _vertical(Color lineColor, double insetPx) {
    final BoxDecoration decoration = BoxDecoration(
      color: lineColor,
      borderRadius: BorderRadius.circular(thickness / 2),
    );

    switch (style) {
      case NorthstarDividerStyle.fullWidth:
        return SizedBox(
          width: thickness,
          height: double.infinity,
          child: DecoratedBox(decoration: decoration),
        );
      case NorthstarDividerStyle.inset:
        return Padding(
          padding: EdgeInsets.only(top: insetPx),
          child: SizedBox(
            width: thickness,
            height: double.infinity,
            child: DecoratedBox(decoration: decoration),
          ),
        );
      case NorthstarDividerStyle.middleInset:
        return Padding(
          padding: EdgeInsets.symmetric(vertical: insetPx),
          child: SizedBox(
            width: thickness,
            height: double.infinity,
            child: DecoratedBox(decoration: decoration),
          ),
        );
    }
  }
}
