import 'package:emp_ai_ds_widgets/src/catalog/northstar_icon_catalog_panel.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarIconLibraryCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_icon_library',
    title: 'Northstar icons (SVG)',
    description: '**344** Northstar V3 SVGs ship in `emp_ai_ds_northstar` '
        '(`assets/northstar_icons/`). Groups mirror the Figma icon sheet; '
        'search by id, asset path, or section title. Tap an icon for '
        'copy-ready [NorthstarSvgIcon] samples. After replacing assets, run '
        '`dart run tool/generate_northstar_icon_manifest.dart` in that package.',
    code: '''
  import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
  
  NorthstarSvgIcon(
    item: NorthstarIconRegistry.tryById('user-time')!,
    size: 24,
  )
  
  NorthstarSvgIcon.fromPath(
    relativeAssetPath: 'assets/northstar_icons/Icon=user-time.svg',
    size: 24,
  )
  ''',
    preview: _northstarIconLibraryCatalogPreview,
  );
}

Widget _northstarIconLibraryCatalogPreview(BuildContext context) {
  return const SizedBox(
    height: 520,
    child: NorthstarIconCatalogPanel(),
  );
}
