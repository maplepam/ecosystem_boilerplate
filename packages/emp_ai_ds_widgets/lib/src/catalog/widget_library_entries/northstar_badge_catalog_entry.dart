import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_avatar.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_badge.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarBadgeCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_badge',
    title: 'NorthstarBadge',
    description:
        'Single widget for Figma **Badge** variants: **status** dot, **icon** '
        'circle (glyph on semantic fill), **digits** (1–2, circular), **label** '
        'pill (10px type, 3+ chars). Semantics: positive / negative / warning / '
        'info / neutral ([NorthstarColorTokens]). Optional contrasting **border** '
        'when overlapping surfaces. [NorthstarBadged] supports **inset** vs '
        '**centered-on-corner** top-end placement.',
    code: '''
  NorthstarBadge.status(
    semantic: NorthstarBadgeSemantic.positive,
    showBorder: true,
    automationId: 'live_dot',
  )
  
  NorthstarBadge.icon(
    semantic: NorthstarBadgeSemantic.negative,
    icon: Icons.priority_high,
    automationId: 'alert_icon',
  )
  
  NorthstarBadge.digits(
    semantic: NorthstarBadgeSemantic.info,
    value: '12',
    showBorder: true,
    automationId: 'notif_count',
  )
  
  NorthstarBadge.label(
    semantic: NorthstarBadgeSemantic.warning,
    text: 'NEW',
    automationId: 'pill_new',
  )
  
  NorthstarBadged(
    placement: NorthstarBadgePlacement.centeredOnCornerTopEnd,
    badge: NorthstarBadge.digits(
      semantic: NorthstarBadgeSemantic.negative,
      value: '3',
      showBorder: true,
    ),
    child: Icon(Icons.notifications_outlined, size: 28),
  )
  ''',
    preview: _northstarBadgeCatalogPreview,
  );
}

Widget _northstarBadgeCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!;

  IconData iconForSemantic(NorthstarBadgeSemantic s) {
    return switch (s) {
      NorthstarBadgeSemantic.positive => Icons.check,
      NorthstarBadgeSemantic.negative => Icons.priority_high,
      NorthstarBadgeSemantic.warning => Icons.warning_amber_rounded,
      NorthstarBadgeSemantic.info => Icons.info_outline,
      NorthstarBadgeSemantic.neutral => Icons.horizontal_rule,
    };
  }

  Widget semanticRow(
    String title,
    Widget Function(NorthstarBadgeSemantic semantic, int index) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: caption),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: <Widget>[
            for (int i = 0; i < NorthstarBadgeSemantic.values.length; i++)
              itemBuilder(NorthstarBadgeSemantic.values[i], i),
          ],
        ),
      ],
    );
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        semanticRow(
          'Status (dot)',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.status(
            semantic: s,
            automationId: 'cat_badge_st_$i',
          ),
        ),
        const SizedBox(height: 18),
        semanticRow(
          'Icon',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.icon(
            semantic: s,
            icon: iconForSemantic(s),
            automationId: 'cat_badge_ic_$i',
          ),
        ),
        const SizedBox(height: 18),
        semanticRow(
          'Digits (1–2)',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.digits(
            semantic: s,
            value: i == 1 ? '12' : '3',
            automationId: 'cat_badge_dg_$i',
          ),
        ),
        const SizedBox(height: 18),
        semanticRow(
          'Label / multi-character (pill)',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.label(
            semantic: s,
            text: 'NEW',
            automationId: 'cat_badge_lb_$i',
          ),
        ),
        const SizedBox(height: 22),
        Text('With border (overlap contrast)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.status(
                semantic: NorthstarBadgeSemantic.positive,
                showBorder: true,
                automationId: 'cat_badge_bd_st',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.icon(
                semantic: NorthstarBadgeSemantic.info,
                icon: Icons.info_outline,
                showBorder: true,
                automationId: 'cat_badge_bd_ic',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.digits(
                semantic: NorthstarBadgeSemantic.negative,
                value: '8',
                showBorder: true,
                automationId: 'cat_badge_bd_dg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.label(
                semantic: NorthstarBadgeSemantic.warning,
                text: 'BETA',
                showBorder: true,
                automationId: 'cat_badge_bd_lb',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('Corner placement · inside (inset top-end)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarBadged(
          placement: NorthstarBadgePlacement.insetTopEnd,
          inset: const EdgeInsetsDirectional.only(top: 8, end: 8),
          badge: NorthstarBadge.status(
            semantic: NorthstarBadgeSemantic.positive,
            showBorder: true,
            automationId: 'cat_badge_inset_dot',
          ),
          child: InkWell(
            onTap: () => catalogPreviewSnack(context, 'Badged row · section'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Section title (tap)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Corner placement · centered on corner (icon + count)',
            style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarBadged(
          placement: NorthstarBadgePlacement.centeredOnCornerTopEnd,
          badge: NorthstarBadge.digits(
            semantic: NorthstarBadgeSemantic.negative,
            value: '12',
            showBorder: true,
            automationId: 'cat_badge_corner_cnt',
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () =>
                    catalogPreviewSnack(context, 'Badged · notifications'),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.notifications_outlined, size: 28),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Avatar + status (inset on image, border)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            NorthstarAvatar(
              persona: NorthstarAvatarPersona.user,
              size: 48,
              showBorder: true,
              initials: 'NS',
              automationId: 'cat_badge_av',
              onTap: () =>
                  catalogPreviewSnack(context, 'Badge catalog · avatar'),
            ),
            PositionedDirectional(
              end: 2,
              bottom: 2,
              child: NorthstarBadge.status(
                semantic: NorthstarBadgeSemantic.positive,
                diameter: 12,
                showBorder: true,
                automationId: 'cat_badge_av_dot',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
