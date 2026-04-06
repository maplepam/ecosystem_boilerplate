import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_input_form_field.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarInputFormFieldCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_input_form_field',
    title: 'NorthstarInputFormField',
    description: 'Wraps [NorthstarInputField] in a [FormField<String>]. Supply '
        '[FormField.validator] for required / regex / custom rules; use '
        '[AutovalidateMode] to control when validation runs. '
        '[NorthstarInputFormField.nonEmpty] is a small helper for required '
        'trimmed text. Error chrome follows [FormFieldState.errorText] and '
        'clears when the validator returns null.',
    code: '''
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  Form(
    key: formKey,
    child: NorthstarInputFormField(
      label: 'Email',
      isRequired: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: NorthstarInputFormField.nonEmpty,
      placeholder: 'you@company.com',
      onSaved: (v) => model.email = v ?? '',
    ),
  );
  
  // Submit:
  formKey.currentState?.validate();
  
  // Custom:
  validator: (value) {
    if (value == null || !value.contains('@')) return 'Invalid email';
    return null;
  }
  ''',
    preview: (BuildContext context) => Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Form(
        child: NorthstarInputFormField(
          label: 'Required (live validation)',
          isRequired: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: NorthstarInputFormField.nonEmpty,
          helperText: 'Type to clear the error.',
          placeholder: 'Fill me',
          automationId: 'lib_input_form_preview',
        ),
      ),
    ),
  );
}
