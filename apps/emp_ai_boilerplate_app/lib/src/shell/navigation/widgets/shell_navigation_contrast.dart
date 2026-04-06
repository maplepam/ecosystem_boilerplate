import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Secondary nav labels on [ColorScheme.surface] (drawer + rail). Seed-derived
/// themes can make [ColorScheme.outline] / variant roles very light; blending
/// [NorthstarColorTokens.onSurface] keeps inactive items readable without
/// looking disabled.
Color shellNavInactiveForeground(BuildContext context) {
  final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
  final Color surface = Theme.of(context).colorScheme.surface;
  return Color.alphaBlend(
    tokens.onSurface.withValues(alpha: 0.74),
    surface,
  );
}
