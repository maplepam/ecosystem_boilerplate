import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Shown on the right pane when the catalog is wide and no component is chosen.
class WidgetCatalogWidePlaceholder extends StatelessWidget {
  const WidgetCatalogWidePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NorthstarSpacing.space40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.swipe_rounded,
                size: 56,
                color: tokens.primary.withValues(alpha: 0.85),
              ),
              const SizedBox(height: NorthstarSpacing.space24),
              Text(
                'Choose a component',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: NorthstarSpacing.space12),
              Text(
                'Select any item in the list on the left. You will see a live '
                'preview you can use, a short description, and optional '
                'developer code — all in one place.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: tokens.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
