import 'package:emp_ai_ds_widgets/src/catalog/northstar_typography_catalog_panel.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarTypographyRolesCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_typography_roles',
    title: 'Northstar typography (text roles)',
    description:
        'Figma V3 text roles from `emp_ai_ds_northstar` ([NorthstarTextRole]): '
        'each maps to a slot on [ThemeData.textTheme] after '
        '[NorthstarTheme.buildThemeData]. Search by role name, Figma label, '
        'or font family; tap a row for a live preview and copy-ready '
        '`NorthstarTextRole.*.style(context)` snippet.',
    code: '''
  import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
  
  Text(
    'Page heading',
    style: NorthstarTextRole.pageTitle.style(context),
  )
  
  Text(
    'Supporting copy',
    style: NorthstarTextRole.body.style(context),
  )
  ''',
    preview: _northstarTypographyCatalogPreview,
  );
}

Widget _northstarTypographyCatalogPreview(BuildContext context) {
  return const SizedBox(
    height: 520,
    child: NorthstarTypographyCatalogPanel(),
  );
}
