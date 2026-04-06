import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';

/// User (circle) vs entity / company (rounded square).
enum NorthstarAvatarPersona {
  user,
  entity,
}

/// Initials scale inside the avatar glyph.
enum NorthstarAvatarInitialsSize {
  normal,
  small,
}

/// Single configurable avatar: image, icon, or initials; optional border and
/// status badge; optional **navigation row** (title / subtitle / chevron) with
/// hover and press surface (Figma “Avatar Information”).
///
/// Content priority: [image] → non-empty [initials] → [icon] (or persona default).
class NorthstarAvatar extends StatefulWidget {
  // Non-const: optional [ImageProvider], callbacks, and runtime-only fields.
  // ignore: prefer_const_constructors_in_immutables
  NorthstarAvatar({
    super.key,
    this.persona = NorthstarAvatarPersona.user,
    this.size = 40,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 1.5,
    this.entityCornerRadius = 8,
    this.image,
    this.icon,
    this.initials,
    this.initialsSize = NorthstarAvatarInitialsSize.normal,
    this.backgroundColor,
    this.foregroundColor,
    this.statusBadgeColor,
    this.statusBadgeDiameter = 10,
    this.statusBadgeBorderWidth = 2,
    this.title,
    this.subtitle,
    this.showExpandChevron = false,
    this.onTap,
    this.tooltip,
    this.automationId,
  }) : assert(size > 0);

  final NorthstarAvatarPersona persona;

  /// Diameter (user circle) or shorter box side (entity).
  final double size;

  final bool showBorder;

  /// When null and [showBorder] is true, [NorthstarColorTokens.primary] is used.
  final Color? borderColor;
  final double borderWidth;

  /// Corner radius when [persona] is [NorthstarAvatarPersona.entity].
  final double entityCornerRadius;

  final ImageProvider? image;
  final IconData? icon;

  /// Displayed uppercase; truncated to **2** chars (user) or **1** (entity).
  final String? initials;

  final NorthstarAvatarInitialsSize initialsSize;

  final Color? backgroundColor;
  final Color? foregroundColor;

  /// When non-null, draws a status dot at the bottom-trailing edge.
  final Color? statusBadgeColor;

  final double statusBadgeDiameter;
  final double statusBadgeBorderWidth;

  /// When non-null, builds the “avatar + labels” row (hover / press).
  final String? title;
  final String? subtitle;
  final bool showExpandChevron;
  final VoidCallback? onTap;

  /// Shown on long-press / hover (material tooltip).
  final String? tooltip;

  final String? automationId;

  @override
  State<NorthstarAvatar> createState() => _NorthstarAvatarState();
}

class _NorthstarAvatarState extends State<NorthstarAvatar> {
  bool _hovered = false;
  bool _pressed = false;

  String _initialsText() {
    final String? raw = widget.initials;
    if (raw == null || raw.trim().isEmpty) {
      return '';
    }
    final String t = raw.trim().toUpperCase();
    if (widget.persona == NorthstarAvatarPersona.entity) {
      return t.characters.take(1).string;
    }
    return t.characters.take(2).string;
  }

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);

    final Color bg = widget.backgroundColor ?? ns.primaryContainer;
    final Color fg = widget.foregroundColor ?? ns.onPrimaryContainer;

    final Widget core = _buildCore(context, bg, fg, ns);

    final ValueKey<String>? kSurface =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementAvatar);
    final ValueKey<String>? kTitle =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementAvatarTitle);
    final ValueKey<String>? kSubtitle =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementAvatarSubtitle);
    final ValueKey<String>? kChevron =
        DsAutomationKeys.part(widget.automationId, DsAutomationKeys.elementAvatarChevron);

    Widget wrappedCore = core;
    if (kSurface != null) {
      wrappedCore = KeyedSubtree(key: kSurface, child: core);
    }

    if (widget.title == null) {
      if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
        wrappedCore = Tooltip(message: widget.tooltip!, child: wrappedCore);
      }
      if (widget.onTap != null) {
        wrappedCore = InkWell(
          onTap: widget.onTap,
          customBorder: _clipShape(),
          child: wrappedCore,
        );
      }
      return wrappedCore;
    }

    final Color hoverBg = ns.surfaceContainerHigh.withValues(alpha: 0.85);
    final Color pressBg = ns.surfaceContainerHigh;

    Widget row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: NorthstarSpacing.space8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          wrappedCore,
          const SizedBox(width: NorthstarSpacing.space12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.title!,
                  key: kTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ns.onSurface,
                      ),
                ),
                if (widget.subtitle != null && widget.subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: NorthstarSpacing.space2),
                    child: Text(
                      widget.subtitle!,
                      key: kSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ns.onSurfaceVariant,
                          ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.showExpandChevron) ...<Widget>[
            const SizedBox(width: NorthstarSpacing.space8),
            Icon(
              Icons.expand_more,
              key: kChevron,
              size: 20,
              color: ns.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    row = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: _pressed
            ? pressBg
            : _hovered
                ? hoverBg
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: row,
    );

    row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        onHighlightChanged: (bool v) => setState(() => _pressed = v),
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: row,
        ),
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      row = Tooltip(message: widget.tooltip!, child: row);
    }

    return row;
  }

  ShapeBorder _clipShape() {
    return switch (widget.persona) {
      NorthstarAvatarPersona.user => const CircleBorder(),
      NorthstarAvatarPersona.entity => RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.entityCornerRadius),
        ),
    };
  }

  Widget _buildCore(
    BuildContext context,
    Color bg,
    Color fg,
    NorthstarColorTokens ns,
  ) {
    return _AvatarFace(
      persona: widget.persona,
      size: widget.size,
      entityCornerRadius: widget.entityCornerRadius,
      showBorder: widget.showBorder,
      borderColor: widget.borderColor ?? ns.primary,
      borderWidth: widget.borderWidth,
      backgroundColor: bg,
      foregroundColor: fg,
      image: widget.image,
      icon: widget.icon,
      initialsText: _initialsText(),
      initialsSize: widget.initialsSize,
      automationId: widget.automationId,
      statusBadgeColor: widget.statusBadgeColor,
      statusBadgeDiameter: widget.statusBadgeDiameter,
      statusBadgeBorderWidth: widget.statusBadgeBorderWidth,
      surfaceForBadge: ns.surface,
    );
  }
}

/// Extracted face stack (image / initials / icon + badge) to avoid duplicate layout bugs.
class _AvatarFace extends StatelessWidget {
  const _AvatarFace({
    required this.persona,
    required this.size,
    required this.entityCornerRadius,
    required this.showBorder,
    required this.borderColor,
    required this.borderWidth,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.image,
    required this.icon,
    required this.initialsText,
    required this.initialsSize,
    required this.automationId,
    required this.statusBadgeColor,
    required this.statusBadgeDiameter,
    required this.statusBadgeBorderWidth,
    required this.surfaceForBadge,
  });

  final NorthstarAvatarPersona persona;
  final double size;
  final double entityCornerRadius;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final ImageProvider? image;
  final IconData? icon;
  final String initialsText;
  final NorthstarAvatarInitialsSize initialsSize;
  final String? automationId;
  final Color? statusBadgeColor;
  final double statusBadgeDiameter;
  final double statusBadgeBorderWidth;
  final Color surfaceForBadge;

  BorderRadius _innerClipRadius(double innerSide) {
    if (persona == NorthstarAvatarPersona.user) {
      return BorderRadius.circular(innerSide / 2);
    }
    final double inset = showBorder ? borderWidth : 0;
    final double r = (entityCornerRadius - inset).clamp(0.0, entityCornerRadius);
    return BorderRadius.circular(r);
  }

  Widget _buildGlyph(double side) {
    if (image != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: image!, fit: BoxFit.cover),
        ),
        child: const SizedBox.expand(),
      );
    }
    if (initialsText.isNotEmpty) {
      final double fontSize = initialsSize == NorthstarAvatarInitialsSize.small
          ? side * 0.28
          : side * 0.36;
      return Center(
        child: SizedBox(
          width: side * 0.92,
          height: side * 0.55,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              initialsText,
              key: DsAutomationKeys.part(automationId, DsAutomationKeys.elementAvatarInitials),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
                height: 1,
              ),
            ),
          ),
        ),
      );
    }
    final IconData ic = icon ??
        (persona == NorthstarAvatarPersona.entity
            ? Icons.business_outlined
            : Icons.person_outline);
    return Icon(
      ic,
      key: DsAutomationKeys.part(automationId, DsAutomationKeys.elementAvatarIcon),
      size: side * 0.5,
      color: foregroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double s = size;
    final Widget face;
    if (showBorder) {
      final double inner = s - 2 * borderWidth;
      face = Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: persona == NorthstarAvatarPersona.user
              ? null
              : BorderRadius.circular(entityCornerRadius),
          shape: persona == NorthstarAvatarPersona.user ? BoxShape.circle : BoxShape.rectangle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Padding(
          padding: EdgeInsets.all(borderWidth),
          child: ClipRRect(
            borderRadius: _innerClipRadius(inner),
            child: ColoredBox(
              color: backgroundColor,
              child: SizedBox(
                width: inner,
                height: inner,
                child: _buildGlyph(inner),
              ),
            ),
          ),
        ),
      );
    } else {
      face = ClipRRect(
        borderRadius: _innerClipRadius(s),
        child: ColoredBox(
          color: backgroundColor,
          child: SizedBox(width: s, height: s, child: _buildGlyph(s)),
        ),
      );
    }

    final Widget sized = SizedBox(
      width: s,
      height: s,
      child: face,
    );

    if (statusBadgeColor != null) {
      return Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          sized,
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              key: DsAutomationKeys.part(automationId, DsAutomationKeys.elementAvatarBadge),
              width: statusBadgeDiameter,
              height: statusBadgeDiameter,
              decoration: BoxDecoration(
                color: statusBadgeColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: surfaceForBadge,
                  width: statusBadgeBorderWidth,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return sized;
  }
}
