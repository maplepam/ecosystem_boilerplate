import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_breadcrumb.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarBreadcrumbCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_breadcrumb',
    title: 'NorthstarBreadcrumb',
    description:
        'Hierarchical **breadcrumb** trail with `/` separators: [primary] links '
        '(hover underline, press darkens), bold **current** page, optional '
        '**overflow** (`…` menu) when more than three links precede the current '
        'page, and **24**-char truncation with tooltip. **Small** (~14) and '
        '**Large** (~16) sizes. Uses [NorthstarColorTokens] only — no raw hex.',
    code: '''
  NorthstarBreadcrumb(
    size: NorthstarBreadcrumbSize.small,
    automationId: 'page_trail',
    items: <NorthstarBreadcrumbItem>[
      NorthstarBreadcrumbItem(label: 'Home', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'Components', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'Breadcrumb'),
    ],
  )
  
  NorthstarBreadcrumb(
    size: NorthstarBreadcrumbSize.large,
    items: <NorthstarBreadcrumbItem>[
      NorthstarBreadcrumbItem(label: 'Home', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'A', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'B', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'C', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'D', onTap: () {}),
      NorthstarBreadcrumbItem(label: 'Current'),
    ],
  )
  ''',
    preview: _northstarBreadcrumbCatalogPreview,
  );
}

Widget _northstarBreadcrumbCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!.copyWith(
        fontWeight: FontWeight.w600,
      );

  return Material(
    color: NorthstarColorTokens.of(context).surface,
    child: Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space12),
      child: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Small · short trail', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              size: NorthstarBreadcrumbSize.small,
              automationId: 'cat_crumb_small',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () => catalogPreviewSnack(context, 'Crumb: Home'),
                ),
                NorthstarBreadcrumbItem(
                  label: 'Components',
                  onTap: () =>
                      catalogPreviewSnack(context, 'Crumb: Components'),
                ),
                const NorthstarBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            Text('Large · same trail', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              size: NorthstarBreadcrumbSize.large,
              automationId: 'cat_crumb_large',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () => catalogPreviewSnack(context, 'Large · Home'),
                ),
                NorthstarBreadcrumbItem(
                  label: 'Components',
                  onTap: () =>
                      catalogPreviewSnack(context, 'Large · Components'),
                ),
                const NorthstarBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            Text('Overflow · tap … for hidden levels', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              size: NorthstarBreadcrumbSize.small,
              automationId: 'cat_crumb_overflow',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () =>
                      catalogPreviewSnack(context, 'Overflow trail · Home'),
                ),
                NorthstarBreadcrumbItem(
                  label: 'Hidden A',
                  onTap: () => catalogPreviewSnack(context, 'Hidden A'),
                ),
                NorthstarBreadcrumbItem(
                  label: 'Hidden B',
                  onTap: () => catalogPreviewSnack(context, 'Hidden B'),
                ),
                NorthstarBreadcrumbItem(
                  label: 'Visible Y',
                  onTap: () => catalogPreviewSnack(context, 'Visible Y'),
                ),
                NorthstarBreadcrumbItem(
                  label: 'Visible Z',
                  onTap: () => catalogPreviewSnack(context, 'Visible Z'),
                ),
                const NorthstarBreadcrumbItem(label: 'Current page'),
              ],
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            Text('Truncation · hover for full label', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              maxLabelLength: 24,
              automationId: 'cat_crumb_trunc',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () => catalogPreviewSnack(context, 'Trunc · Home'),
                ),
                NorthstarBreadcrumbItem(
                  label:
                      'Extraordinarily long workspace name that exceeds limit',
                  onTap: () =>
                      catalogPreviewSnack(context, 'Long workspace crumb'),
                ),
                const NorthstarBreadcrumbItem(label: 'Details'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
