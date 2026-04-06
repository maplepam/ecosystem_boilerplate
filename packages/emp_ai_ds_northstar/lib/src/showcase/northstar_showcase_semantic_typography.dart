import 'package:flutter/material.dart';

import '../northstar_color_tokens.dart';
import '../tokens/northstar_spacing.dart';
import 'northstar_showcase_snippet.dart';

/// Material [ColorScheme] + [NorthstarColorTokens] swatches with copyable code.
class NorthstarShowcaseSemanticSection extends StatelessWidget {
  const NorthstarShowcaseSemanticSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final ThemeData theme = Theme.of(context);

    final List<({String name, Color color, String code})> materialRoles =
        <({String name, Color color, String code})>[
      (
        name: 'primary',
        color: scheme.primary,
        code: 'Theme.of(context).colorScheme.primary',
      ),
      (
        name: 'onPrimary',
        color: scheme.onPrimary,
        code: 'Theme.of(context).colorScheme.onPrimary',
      ),
      (
        name: 'primaryContainer',
        color: scheme.primaryContainer,
        code: 'Theme.of(context).colorScheme.primaryContainer',
      ),
      (
        name: 'onPrimaryContainer',
        color: scheme.onPrimaryContainer,
        code: 'Theme.of(context).colorScheme.onPrimaryContainer',
      ),
      (
        name: 'secondary',
        color: scheme.secondary,
        code: 'Theme.of(context).colorScheme.secondary',
      ),
      (
        name: 'onSecondary',
        color: scheme.onSecondary,
        code: 'Theme.of(context).colorScheme.onSecondary',
      ),
      (
        name: 'surface',
        color: scheme.surface,
        code: 'Theme.of(context).colorScheme.surface',
      ),
      (
        name: 'onSurface',
        color: scheme.onSurface,
        code: 'Theme.of(context).colorScheme.onSurface',
      ),
      (
        name: 'surfaceContainerHighest',
        color: scheme.surfaceContainerHighest,
        code: 'Theme.of(context).colorScheme.surfaceContainerHighest',
      ),
      (
        name: 'error',
        color: scheme.error,
        code: 'Theme.of(context).colorScheme.error',
      ),
      (
        name: 'onError',
        color: scheme.onError,
        code: 'Theme.of(context).colorScheme.onError',
      ),
      (
        name: 'outline',
        color: scheme.outline,
        code: 'Theme.of(context).colorScheme.outline',
      ),
      (
        name: 'outlineVariant',
        color: scheme.outlineVariant,
        code: 'Theme.of(context).colorScheme.outlineVariant',
      ),
    ];

    final List<({String name, Color color, String code})> northstarRoles =
        <({String name, Color color, String code})>[
      (
        name: 'success',
        color: ns.success,
        code: 'NorthstarColorTokens.of(context).success',
      ),
      (
        name: 'onSuccess',
        color: ns.onSuccess,
        code: 'NorthstarColorTokens.of(context).onSuccess',
      ),
      (
        name: 'warning',
        color: ns.warning,
        code: 'NorthstarColorTokens.of(context).warning',
      ),
      (
        name: 'onWarning',
        color: ns.onWarning,
        code: 'NorthstarColorTokens.of(context).onWarning',
      ),
      (
        name: 'inverseSurface',
        color: ns.inverseSurface,
        code: 'NorthstarColorTokens.of(context).inverseSurface',
      ),
      (
        name: 'onInverseSurface',
        color: ns.onInverseSurface,
        code: 'NorthstarColorTokens.of(context).onInverseSurface',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semantic roles (Material 3)',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Text(
          'Use [ColorScheme] for standard roles. Tokens come from '
          '[NorthstarTheme.buildThemeData].',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: materialRoles
              .map(
                (({String name, Color color, String code}) r) =>
                    _ColorRoleCard(name: r.name, color: r.color, code: r.code),
              )
              .toList(),
        ),
        const SizedBox(height: NorthstarSpacing.space24),
        Text(
          'Northstar extension roles',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: northstarRoles
              .map(
                (({String name, Color color, String code}) r) =>
                    _ColorRoleCard(name: r.name, color: r.color, code: r.code),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ColorRoleCard extends StatelessWidget {
  const _ColorRoleCard({
    required this.name,
    required this.color,
    required this.code,
  });

  final String name;
  final Color color;
  final String code;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              color: color,
            ),
            Padding(
              padding: const EdgeInsets.all(NorthstarSpacing.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  NorthstarShowcaseSnippet(
                    title: 'How to use',
                    code: code,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text theme samples with “how to use” lines.
class NorthstarShowcaseTypographySection extends StatelessWidget {
  const NorthstarShowcaseTypographySection({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final ThemeData theme = Theme.of(context);

    final List<({String role, TextStyle? style, String code})> rows =
        <({String role, TextStyle? style, String code})>[
      (
        role: 'displayLarge',
        style: tt.displayLarge,
        code: 'Theme.of(context).textTheme.displayLarge',
      ),
      (
        role: 'displayMedium',
        style: tt.displayMedium,
        code: 'Theme.of(context).textTheme.displayMedium',
      ),
      (
        role: 'headlineMedium',
        style: tt.headlineMedium,
        code: 'Theme.of(context).textTheme.headlineMedium',
      ),
      (
        role: 'titleLarge',
        style: tt.titleLarge,
        code: 'Theme.of(context).textTheme.titleLarge',
      ),
      (
        role: 'titleMedium',
        style: tt.titleMedium,
        code: 'Theme.of(context).textTheme.titleMedium',
      ),
      (
        role: 'bodyLarge',
        style: tt.bodyLarge,
        code: 'Theme.of(context).textTheme.bodyLarge',
      ),
      (
        role: 'bodyMedium',
        style: tt.bodyMedium,
        code: 'Theme.of(context).textTheme.bodyMedium',
      ),
      (
        role: 'labelLarge',
        style: tt.labelLarge,
        code: 'Theme.of(context).textTheme.labelLarge',
      ),
      (
        role: 'labelSmall',
        style: tt.labelSmall,
        code: 'Theme.of(context).textTheme.labelSmall',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Text(
          'Styles are built with [NorthstarTypography] + your [ColorScheme].',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space16),
        ...rows.map(
          (({String role, TextStyle? style, String code}) r) => Card(
            margin: const EdgeInsets.only(bottom: NorthstarSpacing.space12),
            child: Padding(
              padding: const EdgeInsets.all(NorthstarSpacing.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quick brown fox jumps over the lazy dog',
                    style: r.style,
                  ),
                  const SizedBox(height: NorthstarSpacing.space8),
                  NorthstarShowcaseSnippet(
                    title: r.role,
                    code: r.code,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
