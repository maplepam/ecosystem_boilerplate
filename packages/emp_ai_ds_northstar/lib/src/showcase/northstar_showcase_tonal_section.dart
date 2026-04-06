import '../tokens/northstar_spacing.dart';
import 'northstar_showcase_color_utils.dart';
import 'northstar_showcase_snippet.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/palettes/tonal_palette.dart';

/// Horizontal row of M3 tonal steps (0–100) for one seed color.
class NorthstarShowcaseTonalSection extends StatelessWidget {
  const NorthstarShowcaseTonalSection({
    super.key,
    required this.title,
    required this.seed,
    required this.snippetCode,
    this.snippetSubtitle,
  });

  final String title;
  final Color seed;
  final String snippetCode;
  final String? snippetSubtitle;

  @override
  Widget build(BuildContext context) {
    final TonalPalette palette = northstarTonalPaletteFromSeed(seed);
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: NorthstarSpacing.space16),
      child: Padding(
        padding: const EdgeInsets.all(NorthstarSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: TonalPalette.commonTones.map((int tone) {
                  final Color c = Color(palette.get(tone));
                  return Padding(
                    padding: const EdgeInsets.only(right: NorthstarSpacing.space8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: NorthstarSpacing.space4),
                        Text(
                          '$tone',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            NorthstarShowcaseSnippet(
              title: 'How to use',
              subtitle: snippetSubtitle,
              code: snippetCode,
            ),
          ],
        ),
      ),
    );
  }
}
