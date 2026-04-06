import 'package:flutter/foundation.dart';

/// One step on the Northstar V3 **spacing** scale (Figma token name + **rem** + **px**).
///
/// Values are **logical pixels** (Flutter `dp`); rem assumes a **16px** root (e.g. `1rem` → 16).
/// The design scale also allows **negative** spacing for breakout/overlap — use sparingly and
/// prefer explicit layout (e.g. negative margins) rather than growing this table unless design
/// publishes named negative tokens.
@immutable
class NorthstarSpacingToken {
  const NorthstarSpacingToken({
    required this.name,
    required this.rem,
    required this.logicalPixels,
  });

  /// Figma-style token id, e.g. `space-16`.
  final String name;

  /// Rem multiple (16px root), e.g. `1` for `space-16`.
  final double rem;

  /// Same as Figma **px** column at 1× — use for [EdgeInsets], [SizedBox], gaps, etc.
  final double logicalPixels;
}

/// Northstar V3 spacing scale + convenience constants.
///
/// Prefer these values over magic numbers so screens track Figma **space-*** tokens.
abstract final class NorthstarSpacing {
  NorthstarSpacing._();

  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;
  static const double space80 = 80;
  static const double space96 = 96;

  /// Ordered reference list (documentation + [NorthstarSpacingScaleTable]).
  static const List<NorthstarSpacingToken> scale = <NorthstarSpacingToken>[
    NorthstarSpacingToken(name: 'space-2', rem: 0.125, logicalPixels: space2),
    NorthstarSpacingToken(name: 'space-4', rem: 0.25, logicalPixels: space4),
    NorthstarSpacingToken(name: 'space-8', rem: 0.5, logicalPixels: space8),
    NorthstarSpacingToken(name: 'space-12', rem: 0.75, logicalPixels: space12),
    NorthstarSpacingToken(name: 'space-16', rem: 1, logicalPixels: space16),
    NorthstarSpacingToken(name: 'space-24', rem: 1.5, logicalPixels: space24),
    NorthstarSpacingToken(name: 'space-32', rem: 2, logicalPixels: space32),
    NorthstarSpacingToken(name: 'space-40', rem: 2.5, logicalPixels: space40),
    NorthstarSpacingToken(name: 'space-48', rem: 3, logicalPixels: space48),
    NorthstarSpacingToken(name: 'space-64', rem: 4, logicalPixels: space64),
    NorthstarSpacingToken(name: 'space-80', rem: 5, logicalPixels: space80),
    NorthstarSpacingToken(name: 'space-96', rem: 6, logicalPixels: space96),
  ];
}
