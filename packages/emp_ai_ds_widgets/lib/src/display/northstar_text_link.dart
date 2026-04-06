import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';

/// **Catalog / screenshots only:** paint default, hover, or visited without relying
/// on the pointer (same idea as [NorthstarButtonInteractionPreview]).
enum NorthstarTextLinkInteractionPreview {
  /// Real hover from [MouseRegion] only.
  none,

  /// Blue (or [visitedColor] if [NorthstarTextLink.isVisited]), **no** underline.
  hovered,

  /// Violet, underlined (visited affordance).
  visited,
}

/// Northstar **text link** for inline copy (paragraphs, sentences — not standalone
/// “View all” actions; use tertiary [NorthstarButton] for those).
///
/// **States (Figma):**
/// * **Default** — [defaultColor] or [NorthstarColorTokens.primary], underlined.
/// * **Hover** — same color as unvisited / visited, **underline removed**.
/// * **Visited** — [visitedColor] or [NorthstarColorTokens.secondary], underlined
///   (when not hovering).
///
/// Typography **inherits** from [DefaultTextStyle] (size, weight, family, height);
/// only color and underline are overridden.
class NorthstarTextLink extends StatefulWidget {
  const NorthstarTextLink({
    super.key,
    required this.label,
    this.onTap,
    this.isVisited = false,
    this.defaultColor,
    this.visitedColor,
    this.interactionPreview = NorthstarTextLinkInteractionPreview.none,
    this.automationId,
    this.semanticsLabel,
  });

  /// Link label (plain text).
  final String label;

  final VoidCallback? onTap;

  /// When true, uses [visitedColor] (app sets after navigation or history check).
  final bool isVisited;

  /// Unvisited / hover accent; defaults to [NorthstarColorTokens.primary].
  final Color? defaultColor;

  /// Visited accent; defaults to [NorthstarColorTokens.secondary].
  final Color? visitedColor;

  /// See [NorthstarTextLinkInteractionPreview].
  final NorthstarTextLinkInteractionPreview interactionPreview;

  final String? automationId;

  /// Overrides the semantics label; defaults to [label].
  final String? semanticsLabel;

  @override
  State<NorthstarTextLink> createState() => _NorthstarTextLinkState();
}

class _NorthstarTextLinkState extends State<NorthstarTextLink> {
  bool _hovering = false;

  bool get _effectiveHover {
    return switch (widget.interactionPreview) {
      NorthstarTextLinkInteractionPreview.hovered => true,
      NorthstarTextLinkInteractionPreview.visited => false,
      NorthstarTextLinkInteractionPreview.none => _hovering,
    };
  }

  bool get _useVisitedColor {
    return switch (widget.interactionPreview) {
      NorthstarTextLinkInteractionPreview.visited => true,
      NorthstarTextLinkInteractionPreview.hovered => widget.isVisited,
      NorthstarTextLinkInteractionPreview.none => widget.isVisited,
    };
  }

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens t = NorthstarColorTokens.of(context);
    final Color color = _useVisitedColor
        ? (widget.visitedColor ?? t.secondary)
        : (widget.defaultColor ?? t.primary);
    final bool underline = !_effectiveHover;

    final TextStyle base = DefaultTextStyle.of(context).style;
    final TextStyle linkStyle = base.copyWith(
      color: color,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      decorationColor: color,
    );

    final ValueKey<String>? linkKey = DsAutomationKeys.part(
      widget.automationId,
      DsAutomationKeys.elementTextLink,
    );

    final Widget text = Text(
      widget.label,
      style: linkStyle,
      key: linkKey,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: Semantics(
          link: true,
          label: widget.semanticsLabel ?? widget.label,
          child: text,
        ),
      ),
    );
  }
}
