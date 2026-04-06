import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';

import 'northstar_color_tokens.dart';
import 'northstar_figma_typography.dart';
import 'northstar_typography.dart';
import 'northstar_typography_style.dart';

/// Builds [ThemeData] from Northstar tokens. Optional [seedColor] uses
/// [flex_seed_scheme] to derive a full M3 scheme while preserving your
/// semantic extension for custom roles (success, warning, …).
abstract final class NorthstarTheme {
  const NorthstarTheme._();

  static ThemeData buildThemeData({
    required Brightness brightness,
    NorthstarColorTokens tokens = NorthstarColorTokens.v3,
    Color? seedColor,
    String? fontFamily,
    ThemeData? base,
    bool useNorthstarTypography = true,
    NorthstarTypographyStyle typographyStyle =
        NorthstarTypographyStyle.figmaNorthstarV3,
  }) {
    final ColorScheme scheme;
    if (seedColor != null) {
      scheme = SeedColorScheme.fromSeeds(
        brightness: brightness,
        primaryKey: seedColor,
        secondaryKey: tokens.secondary,
        tertiaryKey: tokens.outline,
      );
    } else {
      scheme = tokens.toColorScheme(brightness);
    }

    final ThemeData seed = base ?? ThemeData(useMaterial3: true);
    final TextTheme? textTheme = !useNorthstarTypography
        ? (fontFamily != null
            ? seed.textTheme.apply(fontFamily: fontFamily)
            : null)
        : switch (typographyStyle) {
            NorthstarTypographyStyle.material3 => NorthstarTypography.textTheme(
                scheme: scheme,
                brightness: brightness,
                fontFamily: fontFamily,
              ),
            NorthstarTypographyStyle.figmaNorthstarV3 =>
              NorthstarFigmaTypography.textTheme(
                contentBlack: scheme.onSurface,
                contentGray: scheme.onSurfaceVariant,
              ),
          };

    return seed.copyWith(
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      // copyWith keeps the seed's scaffold/canvas if omitted — light defaults
      // would remain when only colorScheme switches to dark (invisible text).
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        tokens,
      ],
    );
  }
}
