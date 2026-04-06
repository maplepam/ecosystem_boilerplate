import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarSpacingScaleTableCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_spacing_scale_table',
    title: 'NorthstarSpacing / NorthstarSpacingScaleTable',
    description:
        'Figma V3 spacing scale (space-2 … space-96) as [NorthstarSpacing] '
        'constants plus [NorthstarSpacingToken] metadata. '
        '[NorthstarSpacingScaleTable] is a reusable token/rem/px/swatch reference.',
    code: '''
  const EdgeInsets pad = EdgeInsets.all(NorthstarSpacing.space16);
  
  NorthstarSpacing.scale // List<NorthstarSpacingToken>
  
  const NorthstarSpacingScaleTable()
  ''',
    preview: (BuildContext context) => const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: NorthstarSpacingScaleTable(
        padding: EdgeInsets.all(NorthstarSpacing.space24),
      ),
    ),
  );
}
