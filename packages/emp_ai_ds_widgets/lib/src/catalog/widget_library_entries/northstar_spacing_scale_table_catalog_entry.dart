import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarSpacingScaleTableCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_spacing_scale_table',
    title: 'NorthstarSpacing / NorthstarSpacingScaleTable',
    description:
        'Northstar V3 spacing: map Figma **space-16** → **[NorthstarSpacing.space16]** '
        '(and **space-2** … **space-96** the same way). Use those constants for '
        'padding, gaps, and [SizedBox] in product UI. ',
    code: r'''
  // space-16 in Figma → space16 in code:
  const EdgeInsets pad = EdgeInsets.all(NorthstarSpacing.space16);
  const SizedBox(height: NorthstarSpacing.space24);
  ''',
    preview: (BuildContext context) => const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: NorthstarSpacingScaleTable(
        padding: EdgeInsets.all(NorthstarSpacing.space24),
      ),
    ),
  );
}
