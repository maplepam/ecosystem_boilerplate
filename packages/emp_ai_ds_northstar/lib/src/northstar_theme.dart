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

  /// When [ColorScheme] is **seed-derived**, copy its Material roles into
  /// [NorthstarColorTokens] so [NorthstarColorTokens.of] stays aligned with
  /// [Theme.of] / [ColorScheme] (shell rail, overview cards, buttons, etc.).
  ///
  /// Semantic-only roles (**success**, **warning**, …) stay on [base].
  static NorthstarColorTokens _tokensAlignedWithScheme(
    NorthstarColorTokens base,
    ColorScheme scheme,
  ) {
    return base.copyWith(
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      primaryContainer: scheme.primaryContainer,
      onPrimaryContainer: scheme.onPrimaryContainer,
      secondary: scheme.secondary,
      onSecondary: scheme.onSecondary,
      surface: scheme.surface,
      onSurface: scheme.onSurface,
      onSurfaceVariant: scheme.onSurfaceVariant,
      surfaceContainerLow: scheme.surfaceContainerLow,
      surfaceContainerHigh: scheme.surfaceContainerHigh,
      outline: scheme.outline,
      outlineVariant: scheme.outlineVariant,
      error: scheme.error,
      onError: scheme.onError,
      inverseSurface: scheme.inverseSurface,
      onInverseSurface: scheme.onInverseSurface,
    );
  }

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

    final NorthstarColorTokens extensionTokens = seedColor != null
        ? _tokensAlignedWithScheme(tokens, scheme)
        : tokens;

    return seed.copyWith(
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      // copyWith keeps the seed's scaffold/canvas if omitted — light defaults
      // would remain when only colorScheme switches to dark (invisible text).
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      extensions: <ThemeExtension<dynamic>>[
        extensionTokens,
      ],
    );
  }
}
