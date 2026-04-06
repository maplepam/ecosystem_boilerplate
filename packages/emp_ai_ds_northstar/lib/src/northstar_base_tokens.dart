import 'package:flutter/material.dart';

import 'northstar_color_tokens.dart';

/// **Canonical light / dark / white-label palettes in Dart** — edit here when
/// the design system evolves. This is the single source of truth for default
/// colors in this package (no runtime JSON loading).
///
/// Pair with [NorthstarTheme.buildThemeData] and [NorthstarTypography] for
/// Material 3 text styles derived from the same [ColorScheme].
abstract final class NorthstarBaseTokens {
  const NorthstarBaseTokens._();

  /// Default light semantic colors (product “Northstar” baseline).
  static const NorthstarColorTokens light = NorthstarColorTokens(
    primary: Color(0xFF046AF2),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFEDF9FF),
    onPrimaryContainer: Color(0xFF104A98),
    secondary: Color(0xFF62D2F4),
    onSecondary: Color(0xFF202939),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF202939),
    onSurfaceVariant: Color(0xFF697586),
    surfaceContainerLow: Color(0xFFF3F6F9),
    surfaceContainerHigh: Color(0xFFE3E8EF),
    outline: Color(0xFFCDD5DF),
    outlineVariant: Color(0xFFE3E8EF),
    error: Color(0xFFE91553),
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF51961A),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF202939),
    inverseSurface: Color(0xFF00263F),
    onInverseSurface: Color(0xFFFFFFFF),
  );

  /// Default dark semantic colors.
  static const NorthstarColorTokens dark = NorthstarColorTokens(
    primary: Color(0xFF22A1FF),
    onPrimary: Color(0xFF121926),
    primaryContainer: Color(0xFF104A98),
    onPrimaryContainer: Color(0xFFD6F0FF),
    secondary: Color(0xFF62D2F4),
    onSecondary: Color(0xFF121926),
    surface: Color(0xFF0A0E14),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFF94A3B8),
    surfaceContainerLow: Color(0xFF202939),
    surfaceContainerHigh: Color(0xFF364152),
    outline: Color(0xFF364152),
    outlineVariant: Color(0xFF202939),
    error: Color(0xFFFF6C8B),
    onError: Color(0xFF121926),
    success: Color(0xFF89D744),
    onSuccess: Color(0xFF0A0E14),
    warning: Color(0xFFFCD34D),
    onWarning: Color(0xFF121926),
    inverseSurface: Color(0xFFF8FAFC),
    onInverseSurface: Color(0xFF202939),
  );

  /// Neutral / white-label light primary ramp. Dark: use [dark] or add a
  /// second dark palette here when design provides it.
  static const NorthstarColorTokens whiteLabeledLight = NorthstarColorTokens(
    primary: Color(0xFF364152),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF3F6F9),
    onPrimaryContainer: Color(0xFF121926),
    secondary: Color(0xFF62D2F4),
    onSecondary: Color(0xFF202939),
    surface: Color(0xFFF8FAFC),
    onSurface: Color(0xFF202939),
    onSurfaceVariant: Color(0xFF697586),
    surfaceContainerLow: Color(0xFFF3F6F9),
    surfaceContainerHigh: Color(0xFFE3E8EF),
    outline: Color(0xFFCDD5DF),
    outlineVariant: Color(0xFFE3E8EF),
    error: Color(0xFFE91553),
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF51961A),
    onSuccess: Color(0xFFFFFFFF),
    warning: Color(0xFFFBBF24),
    onWarning: Color(0xFF202939),
    inverseSurface: Color(0xFF00263F),
    onInverseSurface: Color(0xFFFFFFFF),
  );
}
