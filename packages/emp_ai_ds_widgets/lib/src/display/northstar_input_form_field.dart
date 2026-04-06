import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:emp_ai_ds_widgets/src/display/northstar_input_field.dart';

/// [FormField] wrapper around [NorthstarInputField] with [FormField.validator]
/// support and [AutovalidateMode].
///
/// ## When validation runs
///
/// | [AutovalidateMode] | When [validate] / [FormState.validate] runs |
/// |--------------------|---------------------------------------------|
/// | [AutovalidateMode.disabled] | Only when you call [FormFieldState.validate] (e.g. submit button calls [FormState.validate]). |
/// | [AutovalidateMode.always] | On every text change after [didChange] (error clears as soon as [validator] returns null). |
/// | [AutovalidateMode.onUserInteraction] | On every text change once the value diverges from the initial [TextEditingController] sync (typically each keystroke / paste). |
/// | [AutovalidateMode.onUnfocus] | When the field loses focus ([FocusNode] listener). |
///
/// ## Error → normal state
///
/// After a failed validation, the field stays in error until [validator] returns
/// `null`. With [AutovalidateMode.always] or [onUserInteraction], the next
/// rebuild runs [validator] again on the current text, so a **required** field
/// returns to the default/focused look as soon as the user enters non‑empty text.
///
/// [isRequired] only draws the `*` — it does **not** enforce validation unless
/// you pass a [validator] (e.g. [NorthstarInputFormField.nonEmpty]).
class NorthstarInputFormField extends FormField<String> {
  NorthstarInputFormField({
    super.key,
    String? initialValue,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.onSaved,
    super.enabled = true,
    this.focusNode,
    this.onChanged,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.onInfoTap,
    this.helperText,
    this.placeholder,
    this.inlineText,
    this.leading,
    this.leadingPrefix,
    this.onLeadingPrefixTap,
    this.leadingCategoryLabel,
    this.onLeadingCategoryTap,
    this.suffixText,
    this.trailing,
    this.size = NorthstarInputFieldSize.medium,
    this.presentation = NorthstarInputFieldPresentation.editable,
    this.clearable = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onEditingComplete,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.automationId,
  })  : _externalFocus = focusNode,
        super(
          initialValue: initialValue ?? '',
          builder: (FormFieldState<String> _) => const SizedBox.shrink(),
        );

  /// Optional shared [FocusNode]; if null, one is created and disposed by the state.
  final FocusNode? focusNode;

  /// Fires after the form value updates (each meaningful text change).
  final ValueChanged<String>? onChanged;

  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final VoidCallback? onInfoTap;
  final String? helperText;
  final String? placeholder;
  final String? inlineText;
  final Widget? leading;
  final String? leadingPrefix;
  final VoidCallback? onLeadingPrefixTap;
  final String? leadingCategoryLabel;
  final VoidCallback? onLeadingCategoryTap;
  final String? suffixText;
  final Widget? trailing;
  final NorthstarInputFieldSize size;
  final NorthstarInputFieldPresentation presentation;
  final bool clearable;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final String? automationId;

  final FocusNode? _externalFocus;

  /// Trimmed non-empty check for [validator].
  static String? nonEmpty(String? value, [String message = 'This field is required.']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  @override
  FormFieldState<String> createState() => _NorthstarInputFormFieldState();
}

class _NorthstarInputFormFieldState extends FormFieldState<String> {
  late final TextEditingController _controller;
  FocusNode? _ownedFocus;

  @override
  NorthstarInputFormField get widget => super.widget as NorthstarInputFormField;

  FocusNode get _effectiveFocus =>
      widget._externalFocus ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: value ?? '');
    _controller.addListener(_handleControllerChanged);
    if (widget._externalFocus == null) {
      _ownedFocus = FocusNode();
    }
    _effectiveFocus.addListener(_handleFocusChange);
    if (widget.autovalidateMode == AutovalidateMode.always) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          validate();
        }
      });
    }
  }

  @override
  void dispose() {
    _effectiveFocus.removeListener(_handleFocusChange);
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) {
      return;
    }
    if (!_effectiveFocus.hasFocus &&
        widget.autovalidateMode == AutovalidateMode.onUnfocus) {
      validate();
    }
    setState(() {});
  }

  void _handleControllerChanged() {
    final String next = _controller.text;
    final String current = value ?? '';
    if (next != current) {
      didChange(next);
    }
    _maybeAutovalidate();
    widget.onChanged?.call(_controller.text);
  }

  void _maybeAutovalidate() {
    if (!mounted) {
      return;
    }
    switch (widget.autovalidateMode) {
      case AutovalidateMode.always:
      case AutovalidateMode.onUserInteraction:
        validate();
      case AutovalidateMode.disabled:
      case AutovalidateMode.onUnfocus:
        break;
    }
  }

  @override
  void reset() {
    super.reset();
    _controller.value = TextEditingValue(
      text: widget.initialValue ?? '',
      selection: TextSelection.collapsed(offset: (widget.initialValue ?? '').length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NorthstarInputField(
      controller: _controller,
      focusNode: _effectiveFocus,
      errorText: errorText,
      label: widget.label,
      isRequired: widget.isRequired,
      showInfoIcon: widget.showInfoIcon,
      onInfoTap: widget.onInfoTap,
      helperText: widget.helperText,
      placeholder: widget.placeholder,
      inlineText: widget.inlineText,
      leading: widget.leading,
      leadingPrefix: widget.leadingPrefix,
      onLeadingPrefixTap: widget.onLeadingPrefixTap,
      leadingCategoryLabel: widget.leadingCategoryLabel,
      onLeadingCategoryTap: widget.onLeadingCategoryTap,
      suffixText: widget.suffixText,
      trailing: widget.trailing,
      size: widget.size,
      presentation: widget.presentation,
      enabled: widget.enabled,
      clearable: widget.clearable,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      textCapitalization: widget.textCapitalization,
      automationId: widget.automationId,
    );
  }
}
