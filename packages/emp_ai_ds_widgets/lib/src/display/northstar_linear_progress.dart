import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import '../testing/ds_automation_keys.dart';

/// Northstar horizontal **linear** progress: flat (square) caps, primary fill on
/// a neutral track. Common placement: **bottom of an app bar**.
///
/// * **Determinate:** pass [value] in **0–1** (e.g. `0.75` for 75%).
/// * **Indeterminate:** pass `value: null` — a segment slides along the track.
///
/// Default height **3** logical px (spec ~2–4). Override [trackColor] / [color]
/// as needed.
class NorthstarLinearProgress extends StatelessWidget {
  const NorthstarLinearProgress({
    super.key,
    this.value,
    this.height = 3,
    this.trackColor,
    this.color,
    this.automationId,
    this.indeterminateSegmentWidthFactor = 0.35,
  })  : assert(height > 0),
        assert(indeterminateSegmentWidthFactor > 0 && indeterminateSegmentWidthFactor < 1),
        assert(value == null || (value >= 0 && value <= 1));

  /// `null` → indeterminate animation; else clamped **0.0–1.0**.
  final double? value;

  /// Bar thickness (horizontal height).
  final double height;

  final Color? trackColor;
  final Color? color;

  final String? automationId;

  /// Indeterminate segment length as a fraction of track width.
  final double indeterminateSegmentWidthFactor;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Color track = trackColor ?? ns.surfaceContainerHigh;
    final Color fill = color ?? ns.primary;

    Widget bar = value != null
        ? _DeterminateBar(
            trackColor: track,
            color: fill,
            value: value!.clamp(0.0, 1.0),
          )
        : _IndeterminateBar(
            height: height,
            trackColor: track,
            color: fill,
            segmentWidthFactor: indeterminateSegmentWidthFactor,
          );

    final ValueKey<String>? k = DsAutomationKeys.part(
      automationId,
      DsAutomationKeys.elementLinearProgress,
    );
    if (k != null) {
      bar = KeyedSubtree(key: k, child: bar);
    }

    return Semantics(
      label: 'Progress',
      value: value != null ? '${(value! * 100).round()} percent' : null,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: bar,
      ),
    );
  }
}

class _DeterminateBar extends StatelessWidget {
  const _DeterminateBar({
    required this.trackColor,
    required this.color,
    required this.value,
  });

  final Color trackColor;
  final Color color;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: <Widget>[
        ColoredBox(color: trackColor),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            widthFactor: value,
            heightFactor: 1,
            alignment: AlignmentDirectional.centerStart,
            child: ColoredBox(color: color),
          ),
        ),
      ],
    );
  }
}

class _IndeterminateBar extends StatefulWidget {
  const _IndeterminateBar({
    required this.height,
    required this.trackColor,
    required this.color,
    required this.segmentWidthFactor,
  });

  final double height;
  final Color trackColor;
  final Color color;
  final double segmentWidthFactor;

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double w = constraints.maxWidth;
            final double segW = w * widget.segmentWidthFactor;
            final double t = _controller.value;
            final double x = -segW + t * (w + segW);
            return Stack(
              clipBehavior: Clip.hardEdge,
              fit: StackFit.expand,
              children: <Widget>[
                ColoredBox(color: widget.trackColor),
                PositionedDirectional(
                  start: x,
                  width: segW,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(color: widget.color),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
