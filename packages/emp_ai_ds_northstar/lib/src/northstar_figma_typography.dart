import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography from **V3 NORTHSTAR** Figma (Typography frames).
///
/// **Lexend Deca** — hero, title, page title.
/// **Inter** — page title (alt), sub title, labels, body, subheadings.
///
/// **Content colors:** [contentBlack] ≈ “Content Black”, [contentGray] ≈ “Content Gray”.
/// In themes, map from [ColorScheme.onSurface] / [ColorScheme.onSurfaceVariant].
///
/// ### Material [TextTheme] mapping (for `Theme.of(context).textTheme`)
///
/// | Figma role | TextTheme field |
/// |------------|-----------------|
/// | Lexend Hero 40/40 | `displayLarge` |
/// | Lexend Title 24/24 | `displayMedium` |
/// | Lexend Page Title 18/28 | `displaySmall` |
/// | Inter Page Title 18/28 | `headlineLarge` |
/// | Inter Sub Title 16/24 | `headlineMedium` |
/// | Inter Subheading 15/24 reg | `headlineSmall` |
/// | Inter Subheading 15/24 semibold | `titleLarge` |
/// | Inter Subheading 15/24 bold | `titleMedium` |
/// | Inter Label 14/16 | `labelLarge` |
/// | Inter Body Large 14/24 | `bodyLarge` |
/// | Inter Body Standard 12/16 | `bodyMedium` |
/// | Inter Body Small 10/16 | `bodySmall` |
/// | (IDs / chips) 10/16 | `labelSmall` |
abstract final class NorthstarFigmaTypography {
  const NorthstarFigmaTypography._();

  static const String lexendDecaFamily = 'Lexend Deca';
  static const String interFamily = 'Inter';

  static TextStyle _lexend({
    required double fontSize,
    required double lineHeightPx,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.lexendDeca(
      fontSize: fontSize,
      height: lineHeightPx / fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle _inter({
    required double fontSize,
    required double lineHeightPx,
    required Color color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      height: lineHeightPx / fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  /// Full [TextTheme] for [ThemeData.textTheme].
  static TextTheme textTheme({
    required Color contentBlack,
    required Color contentGray,
  }) {
    return TextTheme(
      displayLarge: _lexend(
        fontSize: 40,
        lineHeightPx: 40,
        color: contentBlack,
      ),
      displayMedium: _lexend(
        fontSize: 24,
        lineHeightPx: 24,
        color: contentBlack,
      ),
      displaySmall: _lexend(
        fontSize: 18,
        lineHeightPx: 28,
        color: contentBlack,
      ),
      headlineLarge: _inter(
        fontSize: 18,
        lineHeightPx: 28,
        color: contentBlack,
      ),
      headlineMedium: _inter(
        fontSize: 16,
        lineHeightPx: 24,
        color: contentBlack,
      ),
      headlineSmall: _inter(
        fontSize: 15,
        lineHeightPx: 24,
        color: contentBlack,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: _inter(
        fontSize: 15,
        lineHeightPx: 24,
        color: contentBlack,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: _inter(
        fontSize: 15,
        lineHeightPx: 24,
        color: contentBlack,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: _inter(
        fontSize: 14,
        lineHeightPx: 16,
        color: contentBlack,
        fontWeight: FontWeight.w600,
      ),
      labelLarge: _inter(
        fontSize: 14,
        lineHeightPx: 16,
        color: contentBlack,
      ),
      labelMedium: _inter(
        fontSize: 12,
        lineHeightPx: 16,
        color: contentGray,
      ),
      labelSmall: _inter(
        fontSize: 10,
        lineHeightPx: 16,
        color: contentGray,
      ),
      bodyLarge: _inter(
        fontSize: 14,
        lineHeightPx: 24,
        color: contentBlack,
      ),
      bodyMedium: _inter(
        fontSize: 12,
        lineHeightPx: 16,
        color: contentGray,
      ),
      bodySmall: _inter(
        fontSize: 10,
        lineHeightPx: 16,
        color: contentGray,
      ),
    );
  }
}
