import 'package:emp_ai_boilerplate_app/src/theme/northstar_theme_mode_provider.dart';
import 'package:emp_ai_boilerplate_app/src/theme/user_accent_seed_notifier.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Friendly theme lab: appearance mode + accent presets.
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  static const List<Color> _accentPresets = <Color>[
    Color(0xFF046AF2),
    Color(0xFF0D9488),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFF16A34A),
    Color(0xFFE11D48),
    Color(0xFFF59E0B),
    Color(0xFF64748B),
    Color(0xFFEC4899),
    Color(0xFF0EA5E9),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final NorthstarThemeModeController mode =
        ref.watch(northstarThemeModeControllerProvider);
    final Color? currentSeed = ref.watch(userAccentSeedNotifierProvider);
    final TextTheme textTheme = theme.textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        NorthstarSpacing.space12,
        20,
        NorthstarSpacing.space40,
      ),
      children: <Widget>[
        Text(
          'Make it yours',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Text(
          'Choose how the demo feels — day, night, or follow your device. '
          'Accent colors reshape buttons and highlights while keeping '
          'Northstar structure intact.',
          style: textTheme.bodyLarge?.copyWith(
            color: tokens.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Appearance',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
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
          selected: <ThemeMode>{mode.themeMode},
          onSelectionChanged: (Set<ThemeMode> next) {
            mode.themeMode = next.first;
          },
        ),
        const SizedBox(height: NorthstarSpacing.space32),
        Text(
          'Accent color',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a swatch to preview it across the app. “Brand default” clears '
          'your choice.',
          style: textTheme.bodyMedium?.copyWith(
            color: tokens.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _AccentDot(
              label: 'Brand default',
              selected: currentSeed == null,
              builder: (bool selected) => DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      tokens.primary,
                      tokens.secondary,
                    ],
                  ),
                  border: Border.all(
                    color: selected ? tokens.onSurface : tokens.outlineVariant,
                    width: selected ? 3 : 1,
                  ),
                ),
              ),
              onTap: () =>
                  ref.read(userAccentSeedNotifierProvider.notifier).clear(),
            ),
            ..._accentPresets.map(
              (Color c) => _AccentDot(
                label: _colorLabel(c),
                selected: _sameArgb(currentSeed, c),
                builder: (bool selected) => DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c,
                    border: Border.all(
                      color:
                          selected ? tokens.onSurface : tokens.outlineVariant,
                      width: selected ? 3 : 1,
                    ),
                  ),
                ),
                onTap: () => ref
                    .read(userAccentSeedNotifierProvider.notifier)
                    .setSeed(c),
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tokens.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.tips_and_updates_outlined,
                  color: tokens.primary,
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                Expanded(
                  child: Text(
                    'Tip: combine “System” appearance with your OS dark mode to '
                    'show stakeholders both looks without touching settings twice.',
                    style: textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: tokens.onSurface.withValues(alpha: 0.88),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _colorLabel(Color c) {
    final int argb = c.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static bool _sameArgb(Color? a, Color b) {
    if (a == null) {
      return false;
    }
    return a.toARGB32() == b.toARGB32();
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.label,
    required this.selected,
    required this.builder,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Widget Function(bool selected) builder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 88,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 52,
                height: 52,
                child: builder(selected),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
