import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_divider.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarDividerCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_divider',
    title: 'NorthstarDivider',
    description:
        'Horizontal or vertical hairline with **fullWidth**, **inset** '
        '(start / top), or **middleInset**. Optional [color], [thickness], '
        '[inset] amount, [margin], [padding], [automationId].',
    code: '''
  NorthstarDivider(
    style: NorthstarDividerStyle.fullWidth,
    automationId: 'row_sep',
  )
  
  NorthstarDivider(
    style: NorthstarDividerStyle.inset,
    inset: 16,
  )
  
  NorthstarDivider(
    style: NorthstarDividerStyle.middleInset,
    margin: EdgeInsets.symmetric(vertical: 8),
  )
  
  NorthstarDivider(
    orientation: NorthstarDividerOrientation.vertical,
    style: NorthstarDividerStyle.middleInset,
    padding: EdgeInsets.only(left: 4),
  )
  ''',
    preview: _northstarDividerCatalogPreview,
  );
}

Widget _northstarDividerCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!;

  Widget hRow(String label, NorthstarDividerStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: caption),
        const SizedBox(height: 6),
        NorthstarDivider(
          style: style,
          automationId: 'cat_div_h_${style.name}',
        ),
      ],
    );
  }

  return SizedBox(
    width: 280,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        hRow('Horizontal · fullWidth', NorthstarDividerStyle.fullWidth),
        const SizedBox(height: NorthstarSpacing.space16),
        hRow('Horizontal · inset', NorthstarDividerStyle.inset),
        const SizedBox(height: NorthstarSpacing.space16),
        hRow('Horizontal · middleInset', NorthstarDividerStyle.middleInset),
        const SizedBox(height: 20),
        Text('Vertical (fixed 72px row)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        catalogPreviewSnack(context, 'Divider demo · pane A'),
                    child: Center(
                      child: Text(
                        'A (tap)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
              NorthstarDivider(
                orientation: NorthstarDividerOrientation.vertical,
                style: NorthstarDividerStyle.fullWidth,
                automationId: 'cat_div_v_full',
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        catalogPreviewSnack(context, 'Divider demo · pane B'),
                    child: Center(
                      child: Text(
                        'B (tap)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
              NorthstarDivider(
                orientation: NorthstarDividerOrientation.vertical,
                style: NorthstarDividerStyle.middleInset,
                inset: 12,
                automationId: 'cat_div_v_mid',
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        catalogPreviewSnack(context, 'Divider demo · pane C'),
                    child: Center(
                      child: Text(
                        'C (tap)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
