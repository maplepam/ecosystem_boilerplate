import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Applies Northstar token colors to Material **Checkbox**, **Radio**, and **Switch**
/// for children (Figma **Selection**).
///
/// When [tokens] is null, uses [NorthstarColorTokens.of] so light/dark themes match.
class NorthstarSelectionControlsTheme extends StatelessWidget {
  const NorthstarSelectionControlsTheme({
    super.key,
    required this.child,
    this.tokens,
  });

  final Widget child;

  /// When null, resolved from [ThemeData.extensions] via [NorthstarColorTokens.of].
  final NorthstarColorTokens? tokens;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens t = tokens ?? NorthstarColorTokens.of(context);
    final ThemeData base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        checkboxTheme: CheckboxThemeData(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(color: t.outline, width: 1.5),
          fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            if (s.contains(WidgetState.disabled)) {
              if (s.contains(WidgetState.selected)) {
                return t.surfaceContainerHigh;
              }
              return t.surfaceContainerHigh;
            }
            if (s.contains(WidgetState.selected)) {
              return t.primary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            if (s.contains(WidgetState.disabled)) {
              if (s.contains(WidgetState.selected)) {
                return t.onSurfaceVariant.withValues(alpha: 0.95);
              }
              return Colors.transparent;
            }
            return t.onPrimary;
          }),
        ),
        radioTheme: RadioThemeData(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            if (s.contains(WidgetState.disabled)) {
              return t.onSurfaceVariant.withValues(alpha: 0.4);
            }
            if (s.contains(WidgetState.selected)) {
              return t.primary;
            }
            return t.outline;
          }),
        ),
        switchTheme: SwitchThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            return t.onPrimary;
          }),
          trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
            if (s.contains(WidgetState.disabled)) {
              if (s.contains(WidgetState.selected)) {
                return t.primary.withValues(alpha: 0.35);
              }
              return t.surfaceContainerHigh;
            }
            if (s.contains(WidgetState.selected)) {
              return t.primary;
            }
            return t.outlineVariant;
          }),
        ),
      ),
      child: child,
    );
  }
}
