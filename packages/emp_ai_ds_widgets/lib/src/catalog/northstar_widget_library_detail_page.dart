import 'dart:math' show min;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'widget_catalog_entry.dart';
import 'widget_library_snippet.dart';

/// Second step: interactive preview + optional “How to use” code (expandable).
class NorthstarWidgetLibraryDetailPage extends StatelessWidget {
  const NorthstarWidgetLibraryDetailPage({
    super.key,
    required this.entry,
    required this.onBack,
  });

  final WidgetCatalogEntry entry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to list',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: onBack,
        ),
        title: Text(entry.title),
      ),
      body: NorthstarWidgetLibraryDetailBody(entry: entry),
    );
  }
}

/// Scrollable body (preview + expandable developer section) without [Scaffold].
class NorthstarWidgetLibraryDetailBody extends StatefulWidget {
  const NorthstarWidgetLibraryDetailBody({
    super.key,
    required this.entry,
    this.codeInitiallyExpanded = false,
  });

  final WidgetCatalogEntry entry;
  final bool codeInitiallyExpanded;

  @override
  State<NorthstarWidgetLibraryDetailBody> createState() =>
      _NorthstarWidgetLibraryDetailBodyState();
}

class _NorthstarWidgetLibraryDetailBodyState
    extends State<NorthstarWidgetLibraryDetailBody> {
  late bool _codeOpen = widget.codeInitiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final WidgetCatalogEntry e = widget.entry;
    final double screenW = MediaQuery.sizeOf(context).width;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewport) {
        final double hPad =
            screenW >= 720 ? 28 : NorthstarSpacing.space16;
        final double bottomPad =
            screenW >= 720 ? NorthstarSpacing.space48 : NorthstarSpacing.space32;
        final double previewPad = screenW >= 600 ? 20 : 14;
        final double maxPreviewW =
            viewport.maxWidth.isFinite ? min(viewport.maxWidth, 960) : 960;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            hPad,
            NorthstarSpacing.space8,
            hPad,
            bottomPad,
          ),
          children: <Widget>[
            Text(
              'Try it',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space4),
            Text(
              'Tap, scroll, and use the real component below — the same one your '
              'product ships with.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space16),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxPreviewW),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(previewPad),
                    child: Theme(
                      data: theme,
                      child: e.preview(context),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'About',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space8),
            Text(
              e.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            FilledButton.tonalIcon(
              onPressed: () => setState(() => _codeOpen = !_codeOpen),
              icon: Icon(
                  _codeOpen ? Icons.expand_less_rounded : Icons.code_rounded),
              label: Text(_codeOpen
                  ? 'Hide example code'
                  : 'How to use (example code)'),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _codeOpen
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: _DeveloperCodeCard(code: e.code.trim()),
            ),
          ],
        );
      },
    );
  }
}

class _DeveloperCodeCard extends StatelessWidget {
  const _DeveloperCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NorthstarSpacing.space16,
          NorthstarSpacing.space12,
          NorthstarSpacing.space12,
          NorthstarSpacing.space12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Paste into your Flutter project — use the copy control on the right.',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            WidgetLibrarySnippet(code: code),
          ],
        ),
      ),
    );
  }
}
