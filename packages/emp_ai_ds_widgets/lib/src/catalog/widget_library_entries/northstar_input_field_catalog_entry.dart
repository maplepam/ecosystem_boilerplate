import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_input_field.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarInputFieldCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_input_field',
    title: 'NorthstarInputField',
    description:
        'Figma **Input** pattern: optional label (required `*`, info icon), '
        'helper, 8px-radius shell, leading category / prefix / icon, suffix '
        'and trailing slot, clear-on-hover, footer (error left, inline right). '
        'Sizes [NorthstarInputFieldSize.small] / [medium]; '
        '[NorthstarInputFieldPresentation.editable], [readOnly], [viewOnly]. '
        'Derives default / hover / focus / filled / error / disabled from '
        '[ThemeData.colorScheme] + focus and [errorText]. '
        'For [FormField] validation see [NorthstarInputFormField].',
    code: '''
  NorthstarInputField(
    label: 'Email address',
    isRequired: true,
    helperText: 'We use this for receipts only.',
    placeholder: 'e.g. you@company.com',
    clearable: true,
    inlineText: 'Optional',
    automationId: 'signup_email',
    onChanged: (_) {},
  )
  
  NorthstarInputField(
    label: 'Amount',
    placeholder: '0.00',
    suffixText: 'USD',
    size: NorthstarInputFieldSize.small,
  )
  
  NorthstarInputField(
    label: 'Phone',
    leadingPrefix: '+63',
    onLeadingPrefixTap: () {},
    placeholder: '9XX XXX XXXX',
    trailing: Icon(Icons.expand_more),
  )
  
  NorthstarInputField(
    presentation: NorthstarInputFieldPresentation.viewOnly,
    label: 'Department',
    initialValue: 'Engineering',
  )
  ''',
    preview: (BuildContext context) => const _NorthstarInputFieldCatalogDemo(),
  );
}

class _NorthstarInputFieldCatalogDemo extends StatefulWidget {
  const _NorthstarInputFieldCatalogDemo();

  @override
  State<_NorthstarInputFieldCatalogDemo> createState() =>
      _NorthstarInputFieldCatalogDemoState();
}

class _NorthstarInputFieldCatalogDemoState
    extends State<_NorthstarInputFieldCatalogDemo> {
  String _hint = 'Interact with the fields below.';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(NorthstarSpacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(_hint, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: NorthstarSpacing.space12),
            NorthstarInputField(
              label: 'Work email',
              isRequired: true,
              showInfoIcon: true,
              helperText: 'Helper copy wraps to the field width.',
              placeholder: 'name@company.com',
              clearable: true,
              automationId: 'lib_input_demo',
              onChanged: (String v) => setState(
                () => _hint = 'Email changed (${v.length} chars)',
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            NorthstarInputField(
              label: 'Salary',
              placeholder: '0.00',
              suffixText: 'USD',
              inlineText: 'Gross',
              automationId: 'lib_input_suffix',
              onChanged: (String v) => setState(
                () => _hint = 'Salary field: $v',
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            NorthstarInputField(
              initialValue: '',
              errorText: 'This field is required.',
              label: 'Required field',
              placeholder: 'Type something',
              automationId: 'lib_input_error',
              onChanged: (String v) => setState(
                () => _hint = 'Error field: ${v.isEmpty ? "empty" : v}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
