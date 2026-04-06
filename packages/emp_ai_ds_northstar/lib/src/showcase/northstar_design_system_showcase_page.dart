import 'package:flutter/material.dart';

import '../northstar_color_tokens.dart';
import '../northstar_theme.dart';
import '../tokens/northstar_spacing.dart';
import 'northstar_showcase_semantic_typography.dart';
import 'northstar_showcase_snippet.dart';
import 'northstar_showcase_tonal_section.dart';
import 'northstar_spacing_scale_table.dart';

/// In-app **visual catalog** for Northstar: tonal ramps (M3 0–100), semantic
/// roles, typography, and copyable Dart snippets.
///
/// Wrap your app (or a dev route) with the same [NorthstarTheme] you ship.
/// The page has its own **preview** [ThemeMode] control (light / dark /
/// system) that only affects this subtree — not the host [MaterialApp.themeMode].
class NorthstarDesignSystemShowcasePage extends StatefulWidget {
  const NorthstarDesignSystemShowcasePage({
    super.key,
    required this.lightTokens,
    required this.darkTokens,
    this.fontFamily,
  });

  final NorthstarColorTokens lightTokens;
  final NorthstarColorTokens darkTokens;
  final String? fontFamily;

  @override
  State<NorthstarDesignSystemShowcasePage> createState() =>
      _NorthstarDesignSystemShowcasePageState();
}

class _NorthstarDesignSystemShowcasePageState
    extends State<NorthstarDesignSystemShowcasePage> {
  ThemeMode _previewMode = ThemeMode.system;

  Brightness _effectiveBrightness(BuildContext context) {
    return switch (_previewMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
  }

  NorthstarColorTokens _tokensFor(Brightness b) {
    return b == Brightness.dark ? widget.darkTokens : widget.lightTokens;
  }

  @override
  Widget build(BuildContext context) {
    final Brightness previewBrightness = _effectiveBrightness(context);
    final ThemeData previewTheme = NorthstarTheme.buildThemeData(
      brightness: previewBrightness,
      tokens: _tokensFor(previewBrightness),
      fontFamily: widget.fontFamily,
    );

    return Theme(
      data: previewTheme,
      child: Builder(
        builder: (BuildContext innerContext) {
          final NorthstarColorTokens t = _tokensFor(previewBrightness);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Northstar · design system'),
            ),
            body: ListView(
              padding: const EdgeInsets.all(NorthstarSpacing.space16),
              children: [
                Text(
                  'Preview appearance',
                  style: Theme.of(innerContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: NorthstarSpacing.space8),
                SegmentedButton<ThemeMode>(
                  segments: const <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                  ],
                  selected: <ThemeMode>{_previewMode},
                  onSelectionChanged: (Set<ThemeMode> next) {
                    setState(() => _previewMode = next.first);
                  },
                ),
                const NorthstarShowcaseSnippet(
                  title: 'Host app: global theme mode',
                  subtitle:
                      'Use NorthstarThemeModeController + ListenableBuilder on MaterialApp.',
                  code: 'themeMode: themeCtrl.themeMode,\n'
                      'theme: NorthstarBranding(...).theme(Brightness.light),\n'
                      'darkTheme: NorthstarBranding(...).theme(Brightness.dark),',
                ),
                const Divider(height: NorthstarSpacing.space32),
                Text(
                  'Tonal palettes (Material 3)',
                  style: Theme.of(innerContext).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: NorthstarSpacing.space8),
                Text(
                  'Generated with material_color_utilities from your semantic '
                  'seed colors (same idea as Figma “0–100” ramps).',
                  style: Theme.of(innerContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(innerContext).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                NorthstarShowcaseTonalSection(
                  title: 'Primary ramp (from primary)',
                  seed: t.primary,
                  snippetCode: "import 'package:material_color_utilities/hct/hct.dart';\n"
                      "import 'package:material_color_utilities/palettes/tonal_palette.dart';\n\n"
                      'final TonalPalette p = TonalPalette.fromHct(\n'
                      '  Hct.fromInt(0xFF046AF2), // your primary\n'
                      ');\n'
                      'final Color tone40 = Color(p.get(40));',
                  snippetSubtitle:
                      'Tones follow TonalPalette.commonTones (0,10,…,100).',
                ),
                NorthstarShowcaseTonalSection(
                  title: 'Secondary ramp (from secondary)',
                  seed: t.secondary,
                  snippetCode: 'final TonalPalette s = TonalPalette.fromHct(\n'
                      '  Hct.fromInt(/* secondary ARGB */),\n'
                      ');',
                ),
                NorthstarShowcaseTonalSection(
                  title: 'Neutral-ish ramp (from surface)',
                  seed: t.surface,
                  snippetCode: 'final TonalPalette n = TonalPalette.fromHct(\n'
                      '  Hct.fromInt(/* surface seed */),\n'
                      ');',
                ),
                NorthstarShowcaseTonalSection(
                  title: 'Success ramp',
                  seed: t.success,
                  snippetCode: 'NorthstarColorTokens.of(context).success',
                ),
                NorthstarShowcaseTonalSection(
                  title: 'Error ramp',
                  seed: t.error,
                  snippetCode: 'Theme.of(context).colorScheme.error',
                ),
                NorthstarShowcaseTonalSection(
                  title: 'Warning ramp',
                  seed: t.warning,
                  snippetCode: 'NorthstarColorTokens.of(context).warning',
                ),
                const Divider(height: NorthstarSpacing.space32),
                const NorthstarShowcaseSemanticSection(),
                const Divider(height: NorthstarSpacing.space32),
                const NorthstarShowcaseSnippet(
                  title: 'Default token bundles',
                  code: 'NorthstarBaseTokens.light\nNorthstarBaseTokens.dark\n'
                      'NorthstarBaseTokens.whiteLabeledLight',
                ),
                const Divider(height: NorthstarSpacing.space32),
                const NorthstarShowcaseTypographySection(),
                const Divider(height: NorthstarSpacing.space32),
                Text(
                  'Spacing scale',
                  style: Theme.of(innerContext).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: NorthstarSpacing.space8),
                Text(
                  'Figma space-* tokens as logical px (16px = 1rem). '
                  'Use NorthstarSpacing in code and NorthstarSpacingScaleTable for docs.',
                  style: Theme.of(innerContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(innerContext).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                const NorthstarSpacingScaleTable(),
              ],
            ),
          );
        },
      ),
    );
  }
}
