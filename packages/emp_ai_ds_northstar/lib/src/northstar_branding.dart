import 'package:flutter/material.dart';

import 'northstar_color_tokens.dart';
import 'northstar_theme.dart';
import 'northstar_typography_style.dart';

/// Bundle token sets for light/dark so white-label apps swap one object.
class NorthstarBranding {
  const NorthstarBranding({
    required this.lightTokens,
    required this.darkTokens,
    this.seedColor,
    this.fontFamily,
    this.typographyStyle = NorthstarTypographyStyle.figmaNorthstarV3,
  });

  final NorthstarColorTokens lightTokens;
  final NorthstarColorTokens darkTokens;
  final Color? seedColor;
  final String? fontFamily;

  /// When [typographyStyle] is [NorthstarTypographyStyle.figmaNorthstarV3],
  /// fonts come from `google_fonts` (Lexend Deca + Inter); [fontFamily] is
  /// only applied for [NorthstarTypographyStyle.material3].
  final NorthstarTypographyStyle typographyStyle;

  ThemeData theme(Brightness brightness) {
    final NorthstarColorTokens tokens =
        brightness == Brightness.dark ? darkTokens : lightTokens;
    return NorthstarTheme.buildThemeData(
      brightness: brightness,
      tokens: tokens,
      seedColor: seedColor,
      fontFamily: fontFamily,
      typographyStyle: typographyStyle,
    );
  }
}
