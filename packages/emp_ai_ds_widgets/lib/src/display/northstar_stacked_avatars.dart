import 'package:flutter/material.dart';

import 'package:emp_ai_ds_widgets/src/display/northstar_avatar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';

/// How [NorthstarStackedAvatars] lays out a list of avatars (Figma stacked group).
enum NorthstarStackedAvatarsBehavior {
  /// Show every avatar in [avatars], up to [maxVisible] (default **5**).
  showAllMaxFive,

  /// First **4** faces + count chip: shows **total − 4**; **99** when that
  /// equals 99; **99+** when **total − 4** is greater than 99 (e.g. 80 → **76**, 103 → **99**, 104+ → **99+**).
  overflowNumeric,

  /// First **4** faces + ellipsis chip when [totalMemberCount] (or list length) **> 4**.
  overflowIndeterminate,
}

/// Horizontally stacked avatars with **−20 px** overlap (see [overlapPixels]).
///
/// Pass [NorthstarAvatar] children; for stacks, prefer `showBorder: true` per design.
class NorthstarStackedAvatars extends StatelessWidget {
  const NorthstarStackedAvatars({
    super.key,
    required this.behavior,
    required this.avatars,
    this.avatarSize = 40,
    this.overlapPixels = 20,
    this.totalMemberCount,
    this.maxVisible = 5,
    this.tooltip,
    this.automationId,
  })  : assert(avatarSize > 0),
        assert(overlapPixels >= 0),
        assert(maxVisible >= 1 && maxVisible <= 5);

  final NorthstarStackedAvatarsBehavior behavior;
  final List<Widget> avatars;

  /// Expected diameter of each [NorthstarAvatar] for layout math.
  final double avatarSize;

  /// Overlap between neighbors; Figma gap **−20** → pass `20`.
  final double overlapPixels;

  /// For overflow modes: total headcount. Defaults to [avatars.length].
  final int? totalMemberCount;

  /// [NorthstarStackedAvatarsBehavior.showAllMaxFive] only.
  final int maxVisible;

  final String? tooltip;
  final String? automationId;

  int get _total => totalMemberCount ?? avatars.length;

  List<Widget> _visibleFaces() {
    switch (behavior) {
      case NorthstarStackedAvatarsBehavior.showAllMaxFive:
        return avatars.take(maxVisible).toList();
      case NorthstarStackedAvatarsBehavior.overflowNumeric:
      case NorthstarStackedAvatarsBehavior.overflowIndeterminate:
        return avatars.take(4).toList();
    }
  }

  bool _showOverflowChip() {
    switch (behavior) {
      case NorthstarStackedAvatarsBehavior.showAllMaxFive:
        return false;
      case NorthstarStackedAvatarsBehavior.overflowNumeric:
      case NorthstarStackedAvatarsBehavior.overflowIndeterminate:
        return _total > 4;
    }
  }

  String? _overflowLabel() {
    if (!_showOverflowChip()) {
      return null;
    }
    switch (behavior) {
      case NorthstarStackedAvatarsBehavior.showAllMaxFive:
        return null;
      case NorthstarStackedAvatarsBehavior.overflowNumeric:
        final int rest = _total - 4;
        if (rest <= 0) {
          return null;
        }
        if (rest > 99) {
          return '99+';
        }
        return '$rest';
      case NorthstarStackedAvatarsBehavior.overflowIndeterminate:
        return '…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> faces = _visibleFaces();
    final String? overflowText = _overflowLabel();
    final double step = avatarSize - overlapPixels;
    final int slotCount = faces.length + (overflowText != null ? 1 : 0);
    final double width = slotCount == 0 ? 0 : (slotCount - 1) * step + avatarSize;

    Widget stack = SizedBox(
      width: width,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          for (int i = 0; i < faces.length; i++)
            Positioned(
              left: i * step,
              child: _maybeKeyed(
                DsAutomationKeys.part(
                  automationId,
                  '${DsAutomationKeys.elementStackedAvatarSlot}_$i',
                ),
                faces[i],
              ),
            ),
          if (overflowText != null)
            Positioned(
              left: faces.length * step,
              child: _maybeKeyed(
                DsAutomationKeys.part(
                  automationId,
                  DsAutomationKeys.elementStackedAvatarsOverflow,
                ),
                NorthstarAvatar(
                  persona: NorthstarAvatarPersona.user,
                  size: avatarSize,
                  showBorder: true,
                  initials: overflowText,
                  initialsSize: NorthstarAvatarInitialsSize.small,
                  automationId: automationId == null || automationId!.isEmpty
                      ? null
                      : '${automationId}_overflow',
                ),
              ),
            ),
        ],
      ),
    );

    stack = _maybeKeyed(
      DsAutomationKeys.part(automationId, DsAutomationKeys.elementStackedAvatars),
      stack,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      stack = Tooltip(message: tooltip!, child: stack);
    }

    return stack;
  }
}

Widget _maybeKeyed(ValueKey<String>? key, Widget child) {
  if (key == null) {
    return child;
  }
  return KeyedSubtree(key: key, child: child);
}
