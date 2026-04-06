import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

/// ARGB int for [Hct] / [TonalPalette] (Material Color Utilities).
int northstarColorToArgb(Color color) {
  // ignore: deprecated_member_use
  return color.value;
}

/// M3-style tonal ramp (tones 0, 10, …, 100 per [TonalPalette.commonTones]).
TonalPalette northstarTonalPaletteFromSeed(Color seed) {
  return TonalPalette.fromHct(Hct.fromInt(northstarColorToArgb(seed)));
}
