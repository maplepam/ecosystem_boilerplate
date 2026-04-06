import 'package:flutter/material.dart';

/// Material 3–aligned text styles. Use [textTheme] with your [ColorScheme] so
/// body/display colors track light/dark surfaces.
///
/// Prefer `Theme.of(context).textTheme.*` in widgets; use this when building
/// [ThemeData] or for previews outside a [BuildContext].
abstract final class NorthstarTypography {
  const NorthstarTypography._();

  /// M3 black/white baseline tinted with [scheme.onSurface].
  static TextTheme textTheme({
    required ColorScheme scheme,
    required Brightness brightness,
    String? fontFamily,
  }) {
    final Typography typography = Typography.material2021(
      platform: TargetPlatform.android,
      colorScheme: scheme,
    );
    final TextTheme base =
        brightness == Brightness.dark ? typography.white : typography.black;
    return base.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamily: fontFamily,
    );
  }
}
