import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_button.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarButtonCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_button',
    title: 'NorthstarButton',
    description:
        'Single configurable action control: primary / secondary / tertiary / '
        'icon-only; tones standard / positive / negative; optional '
        'backgroundColor / foregroundColor; leading/trailing icons; padding, '
        'margin, width, loading. Matches Northstar Figma matrices.',
    code: '''
  NorthstarButton(
    variant: NorthstarButtonVariant.primary,
    tone: NorthstarButtonTone.positive,
    label: 'Confirm',
    trailingIcon: Icons.check,
    automationId: 'confirm_cta',
    onPressed: () {},
  )
  
  NorthstarButton(
    variant: NorthstarButtonVariant.primary,
    label: 'Saving…',
    isLoading: true,
    loadingStyle: NorthstarButtonLoadingStyle.labelWithSpinner,
    automationId: 'save_action',
    onPressed: () {},
  )
  
  NorthstarButton(
    variant: NorthstarButtonVariant.primary,
    tone: NorthstarButtonTone.negative,
    label: 'Delete',
    onPressed: () {},
  )
  
  NorthstarButton(
    variant: NorthstarButtonVariant.secondary,
    tone: NorthstarButtonTone.standard,
    label: 'Secondary',
    leadingIcon: Icons.download_outlined,
    width: 200,
    onPressed: () {},
  )
  
  NorthstarButton(
    variant: NorthstarButtonVariant.primary,
    label: 'Custom',
    backgroundColor: NorthstarColorTokens.of(context).secondary,
    foregroundColor: NorthstarColorTokens.of(context).onSecondary,
    onPressed: () {},
  )
  ''',
    preview: _northstarButtonCatalogPreview,
  );
}

Widget _northstarButtonCatalogPreview(BuildContext context) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  // Match theme surface so tertiary / icon-only (onSurface ink) stay visible;
  // a fixed light grey behind dark-theme text made default states look “empty”.
  final Color matrixBg = scheme.surfaceContainerLow;
  final TextStyle headerStyle =
      Theme.of(context).textTheme.labelMedium!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          );
  final TextStyle rowLabelStyle = headerStyle.copyWith(
    color: scheme.onSurfaceVariant,
  );

  Widget cell(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(right: NorthstarSpacing.space16),
      child: child,
    );
  }

  List<Widget> matrixRow({
    required BuildContext catalogContext,
    required String sectionTitle,
    required String title,
    required NorthstarButtonVariant variant,
    required String label,
    required NorthstarButtonTone tone,
  }) {
    String msg(String state) => '$sectionTitle · $title · $state';
    return <Widget>[
      SizedBox(
        width: 72,
        child: Text(title, style: rowLabelStyle),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          onPressed: () => catalogPreviewSnack(catalogContext, msg('default')),
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          interactionPreview: NorthstarButtonInteractionPreview.hovered,
          onPressed: () =>
              catalogPreviewSnack(catalogContext, msg('hover snapshot')),
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          interactionPreview: NorthstarButtonInteractionPreview.pressed,
          onPressed: () =>
              catalogPreviewSnack(catalogContext, msg('pressed snapshot')),
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          onPressed: null,
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          isLoading: true,
          loadingStyle: variant == NorthstarButtonVariant.iconOnly
              ? NorthstarButtonLoadingStyle.spinnerOnly
              : NorthstarButtonLoadingStyle.labelWithSpinner,
          onPressed: () =>
              catalogPreviewSnack(catalogContext, msg('loading row')),
        ),
      ),
    ];
  }

  List<Widget> iconRowForTone(
    BuildContext catalogContext,
    String sectionTitle,
    NorthstarButtonTone tone,
  ) {
    String msg(String state) => '$sectionTitle · Icon-only · $state';
    return <Widget>[
      const SizedBox(width: 72),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          onPressed: () => catalogPreviewSnack(catalogContext, msg('default')),
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          interactionPreview: NorthstarButtonInteractionPreview.hovered,
          onPressed: () =>
              catalogPreviewSnack(catalogContext, msg('hover snapshot')),
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          interactionPreview: NorthstarButtonInteractionPreview.pressed,
          onPressed: () =>
              catalogPreviewSnack(catalogContext, msg('pressed snapshot')),
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          onPressed: null,
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          isLoading: true,
          onPressed: () =>
              catalogPreviewSnack(catalogContext, msg('loading row')),
        ),
      ),
    ];
  }

  List<Widget> matrixForTone(
    BuildContext ctx,
    NorthstarButtonTone tone,
    String sectionTitle,
  ) {
    return <Widget>[
      const SizedBox(height: 20),
      Text(
        sectionTitle,
        style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      const SizedBox(height: NorthstarSpacing.space12),
      Row(
        children: matrixRow(
          catalogContext: ctx,
          sectionTitle: sectionTitle,
          title: 'Primary',
          variant: NorthstarButtonVariant.primary,
          label: 'Primary',
          tone: tone,
        ),
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Row(
        children: matrixRow(
          catalogContext: ctx,
          sectionTitle: sectionTitle,
          title: 'Secondary',
          variant: NorthstarButtonVariant.secondary,
          label: 'Secondary',
          tone: tone,
        ),
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Row(
        children: matrixRow(
          catalogContext: ctx,
          sectionTitle: sectionTitle,
          title: 'Tertiary',
          variant: NorthstarButtonVariant.tertiary,
          label: 'Tertiary',
          tone: tone,
        ),
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Row(
        children: iconRowForTone(ctx, sectionTitle, tone),
      ),
    ];
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ColoredBox(
      color: matrixBg,
      child: Padding(
        padding: const EdgeInsets.all(NorthstarSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: 72),
                ...<String>[
                  'Default',
                  'Hover',
                  'Pressed',
                  'Disabled',
                  'Loading',
                ].map(
                  (String h) => cell(
                    SizedBox(
                      width: 112,
                      child: Text(h, style: headerStyle),
                    ),
                  ),
                ),
              ],
            ),
            ...matrixForTone(
              context,
              NorthstarButtonTone.standard,
              'Tone · standard (primary)',
            ),
            ...matrixForTone(
              context,
              NorthstarButtonTone.positive,
              'Tone · positive (success)',
            ),
            ...matrixForTone(
              context,
              NorthstarButtonTone.negative,
              'Tone · negative (error)',
            ),
            const SizedBox(height: 20),
            Text(
              'Custom backgroundColor / foregroundColor',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarButton(
              variant: NorthstarButtonVariant.primary,
              label: 'Custom fill',
              trailingIcon: Icons.add,
              backgroundColor: NorthstarColorTokens.of(context).secondary,
              foregroundColor: NorthstarColorTokens.of(context).onSecondary,
              onPressed: () => catalogPreviewSnack(context, 'Custom colors'),
            ),
            const SizedBox(height: 20),
            Text(
              'Optional width · leading + trailing · margin / padding',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarButton(
              variant: NorthstarButtonVariant.primary,
              label: 'Full-width primary',
              trailingIcon: Icons.add,
              width: 280,
              onPressed: () =>
                  catalogPreviewSnack(context, 'Full-width primary'),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            NorthstarButton(
              variant: NorthstarButtonVariant.secondary,
              label: 'Leading icon',
              leadingIcon: Icons.arrow_back,
              margin: const EdgeInsets.only(right: NorthstarSpacing.space12),
              onPressed: () => catalogPreviewSnack(context, 'Leading icon'),
            ),
            NorthstarButton(
              variant: NorthstarButtonVariant.tertiary,
              label: 'Both icons',
              leadingIcon: Icons.star_outline,
              trailingIcon: Icons.chevron_right,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              onPressed: () => catalogPreviewSnack(context, 'Both icons'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Interactive filter bar: menus replace [NorthstarFilterDropdown] labels; locations
/// use a multi-select bottom sheet; **All filters** shows summary + clear.
