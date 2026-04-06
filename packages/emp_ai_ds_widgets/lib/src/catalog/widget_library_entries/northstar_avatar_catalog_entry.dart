import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_avatar.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarAvatarCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_avatar',
    title: 'NorthstarAvatar',
    description:
        'Configurable avatar: user (circle) vs entity (rounded square); '
        'image → initials → icon; optional border and status badge; optional '
        'label row with hover / press surface and tooltip.',
    code: '''
  NorthstarAvatar(
    persona: NorthstarAvatarPersona.user,
    size: 40,
    initials: 'AL',
    showBorder: true,
    statusBadgeColor: NorthstarColorTokens.of(context).success,
    automationId: 'header_user',
  )
  
  NorthstarAvatar(
    persona: NorthstarAvatarPersona.entity,
    size: 40,
    showBorder: true,
    initials: 'A',
    automationId: 'org',
  )
  
  NorthstarAvatar(
    title: 'Aaron Leyte',
    subtitle: 'Engineering',
    showExpandChevron: true,
    tooltip: 'Open profile',
    initials: 'AL',
    automationId: 'nav_user',
    onTap: () {},
  )
  ''',
    preview: _northstarAvatarCatalogPreview,
  );
}

Widget _northstarAvatarCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!;
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Glyphs', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            Row(
              children: <Widget>[
                NorthstarAvatar(
                  persona: NorthstarAvatarPersona.user,
                  initials: 'AL',
                  automationId: 'cat_glyph_user',
                  onTap: () => catalogPreviewSnack(context, 'User avatar'),
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                NorthstarAvatar(
                  persona: NorthstarAvatarPersona.entity,
                  initials: 'A',
                  automationId: 'cat_glyph_entity',
                  onTap: () => catalogPreviewSnack(context, 'Entity avatar'),
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                NorthstarAvatar(
                  showBorder: true,
                  initials: 'B',
                  automationId: 'cat_glyph_border',
                  onTap: () => catalogPreviewSnack(context, 'Border avatar'),
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                NorthstarAvatar(
                  initials: 'S',
                  statusBadgeColor: NorthstarColorTokens.of(context).success,
                  automationId: 'cat_glyph_badge',
                  onTap: () => catalogPreviewSnack(context, 'Badge avatar'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: NorthstarSpacing.space24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Avatar + labels', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarAvatar(
              title: 'Preview User',
              subtitle: 'Role · Team',
              showExpandChevron: true,
              tooltip: 'Account menu',
              initials: 'PU',
              automationId: 'cat_nav_row',
              onTap: () => catalogPreviewSnack(context, 'Avatar + labels row'),
            ),
          ],
        ),
      ],
    ),
  );
}
