import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_accordion.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_divider.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarAccordionCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_accordion',
    title: 'NorthstarAccordion',
    description:
        'Collapsible section: full header hit target, animated chevron '
        '(down/up), optional [onExpansionChanged]. [NorthstarAccordionStyle.panel] '
        'for card-like rows (leave ≥8 logical px between items); '
        '[NorthstarAccordionStyle.divider] for FAQ-style stacks — insert '
        '[NorthstarDivider] between items so lines do not double. '
        'Default collapsed; [enabled] false for disabled.',
    code: '''
  NorthstarAccordion(
    style: NorthstarAccordionStyle.panel,
    title: 'Section title',
    automationId: 'faq_1',
    child: Text('Body…'),
  )
  
  NorthstarAccordion(
    style: NorthstarAccordionStyle.divider,
    title: 'Next row',
    child: Text('…'),
  )
  ''',
    preview: _northstarAccordionCatalogPreview,
  );
}

Widget _northstarAccordionCatalogPreview(BuildContext context) {
  final TextStyle? sectionLabel =
      Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          );
  return SingleChildScrollView(
    padding: const EdgeInsets.all(NorthstarSpacing.space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Panel (≥8 logical px between items)', style: sectionLabel),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.panel,
          title: 'Billing address',
          automationId: 'cat_acc_panel_1',
          child: const Text(
            'Use a card on file or add a new payment method.',
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.panel,
          title:
              'Shipping — long titles wrap across lines instead of truncating with ellipsis when possible',
          automationId: 'cat_acc_panel_2',
          child: const Text('Body copy.'),
        ),
        const SizedBox(height: NorthstarSpacing.space24),
        Text('Divider list', style: sectionLabel),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.divider,
          title: 'Question one',
          automationId: 'cat_acc_div_1',
          child: const Text('Answer text.'),
        ),
        const NorthstarDivider(),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.divider,
          title: 'Question two (disabled)',
          enabled: false,
          automationId: 'cat_acc_div_2',
          child: const Text('Tap is ignored when disabled.'),
        ),
      ],
    ),
  );
}
