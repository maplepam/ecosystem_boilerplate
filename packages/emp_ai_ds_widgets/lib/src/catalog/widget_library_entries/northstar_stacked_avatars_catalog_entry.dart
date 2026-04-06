import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_avatar.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_stacked_avatars.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarStackedAvatarsCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_stacked_avatars',
    title: 'NorthstarStackedAvatars',
    description:
        'Overlapping avatars (−20 px gap). Behaviors: show up to five; '
        'four + remainder chip (total−4, e.g. 80→76; 103→99; >103→99+); '
        'four + ellipsis.',
    code: '''
  NorthstarStackedAvatars(
    behavior: NorthstarStackedAvatarsBehavior.showAllMaxFive,
    automationId: 'team',
    avatars: [
      NorthstarAvatar(showBorder: true, initials: 'A', automationId: 'team_m1'),
      NorthstarAvatar(showBorder: true, initials: 'B', automationId: 'team_m2'),
    ],
  )
  
  NorthstarStackedAvatars(
    behavior: NorthstarStackedAvatarsBehavior.overflowNumeric,
    totalMemberCount: 48,
    avatars: [ /* four NorthstarAvatar */ ],
  )
  // total 48 → chip shows 44 (48 − 4). total 103 → 99. total 104+ → 99+.
  
  NorthstarStackedAvatars(
    behavior: NorthstarStackedAvatarsBehavior.overflowIndeterminate,
    avatars: [ /* four+ */ ],
  )
  ''',
    preview: _northstarStackedAvatarsCatalogPreview,
  );
}

Widget _northstarStackedAvatarsCatalogPreview(BuildContext context) {
  NorthstarAvatar face(String initials, String automationId) {
    return NorthstarAvatar(
      showBorder: true,
      initials: initials,
      size: 40,
      automationId: automationId,
      onTap: () => catalogPreviewSnack(context, 'Stack · $initials'),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('≤5 (show all)', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      NorthstarStackedAvatars(
        behavior: NorthstarStackedAvatarsBehavior.showAllMaxFive,
        automationId: 'cat_stack_five',
        tooltip: 'Core team',
        avatars: <Widget>[
          face('A', 'cat_s5_a'),
          face('B', 'cat_s5_b'),
          face('C', 'cat_s5_c'),
        ],
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Text('>4 numeric (48 total → chip 44; 103 → 99; 104+ → 99+)',
          style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      NorthstarStackedAvatars(
        behavior: NorthstarStackedAvatarsBehavior.overflowNumeric,
        totalMemberCount: 48,
        automationId: 'cat_stack_num',
        avatars: <Widget>[
          face('A', 'cat_sn_a'),
          face('B', 'cat_sn_b'),
          face('C', 'cat_sn_c'),
          face('D', 'cat_sn_d'),
        ],
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Text('Indeterminate (…)', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      NorthstarStackedAvatars(
        behavior: NorthstarStackedAvatarsBehavior.overflowIndeterminate,
        totalMemberCount: 120,
        automationId: 'cat_stack_el',
        avatars: <Widget>[
          face('A', 'cat_se_a'),
          face('B', 'cat_se_b'),
          face('C', 'cat_se_c'),
          face('D', 'cat_se_d'),
        ],
      ),
    ],
  );
}
