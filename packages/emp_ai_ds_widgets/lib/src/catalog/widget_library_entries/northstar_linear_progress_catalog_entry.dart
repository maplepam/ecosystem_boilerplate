import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_linear_progress.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarLinearProgressCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_linear_progress',
    title: 'NorthstarLinearProgress',
    description:
        'Thin horizontal bar (**square** caps): determinate [value] **0–1**, '
        'or indeterminate when [value] is null. Default height **3**; optional '
        '[trackColor] / [color]; [automationId]. Fits app bar bottom edge.',
    code: '''
  NorthstarLinearProgress(value: 0.75, automationId: 'save_job')
  
  NorthstarLinearProgress(value: null) // indeterminate
  
  NorthstarLinearProgress(
    value: 0.4,
    height: 4,
    trackColor: NorthstarColorTokens.of(context).surfaceContainerHigh,
    color: NorthstarColorTokens.of(context).primary,
  )
  ''',
    preview: (BuildContext context) =>
        const _NorthstarLinearProgressCatalogDemo(),
  );
}

class _NorthstarLinearProgressCatalogDemo extends StatefulWidget {
  const _NorthstarLinearProgressCatalogDemo();

  @override
  State<_NorthstarLinearProgressCatalogDemo> createState() =>
      _NorthstarLinearProgressCatalogDemoState();
}

class _NorthstarLinearProgressCatalogDemoState
    extends State<_NorthstarLinearProgressCatalogDemo> {
  double _value = 0.45;
  bool _indeterminate = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: SizedBox(
        width: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Indeterminate', style: tt.labelLarge),
              value: _indeterminate,
              onChanged: (bool v) => setState(() => _indeterminate = v),
            ),
            Text(
              _indeterminate
                  ? 'Indeterminate bar'
                  : 'Determinate · ${(_value * 100).round()}%',
              style: tt.labelSmall,
            ),
            const SizedBox(height: 8),
            NorthstarLinearProgress(
              value: _indeterminate ? null : _value,
              automationId: 'cat_prog_interactive',
            ),
            if (!_indeterminate) ...<Widget>[
              const SizedBox(height: 12),
              Slider(
                value: _value,
                onChanged: (double v) => setState(() => _value = v),
              ),
            ],
            const SizedBox(height: 20),
            Text('Static reference rows', style: tt.labelSmall),
            const SizedBox(height: 8),
            NorthstarLinearProgress(
              value: 0.25,
              automationId: 'cat_prog_s25',
            ),
            const SizedBox(height: 10),
            NorthstarLinearProgress(
              value: null,
              automationId: 'cat_prog_sind',
            ),
          ],
        ),
      ),
    );
  }
}
