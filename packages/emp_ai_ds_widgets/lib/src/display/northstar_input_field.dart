import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../testing/ds_automation_keys.dart';

/// Visual density for [NorthstarInputField] (Figma `size-small` / `size-medium`).
enum NorthstarInputFieldSize {
  /// Compact vertical padding; slightly smaller type.
  small,

  /// Default spacing (padding ~14 vertical, 20 horizontal).
  medium,
}

/// How the field is presented (Figma `state-read-only` / `state-view-only` / editable).
enum NorthstarInputFieldPresentation {
  /// Normal text entry with hover / focus / error chrome.
  editable,

  /// Same shell as editable but text cannot be changed ([TextField.readOnly]).
  readOnly,

  /// No box: label row + value text only (use for display-dense rows).
  viewOnly,
}

/// Northstar **Input** pattern: optional label (required asterisk, info), helper,
/// rounded container (8 logical px) with optional leading / prefix / suffix / trailing,
/// and a footer row (error left, inline / counter right).
///
/// **Validation:** this widget does **not** run validators. It only **displays**
/// whatever you pass as [errorText]. [isRequired] adds the red `*` but does not
/// enforce input — use parent logic to set [errorText], or prefer
/// [NorthstarInputFormField] with [FormField.validator] and [AutovalidateMode].
///
/// **Tokens:** uses [ThemeData.colorScheme], [NorthstarColorTokens.of] for surfaces,
/// and [NorthstarSpacing]. Focus ring follows [ColorScheme.primary]; errors use
/// [ColorScheme.error]. Icons stay neutral ([ColorScheme.onSurfaceVariant]) unless
/// in error state.
///
/// **States** are derived from [enabled], [errorText], focus, hover ([MouseRegion]),
/// and whether the controller has text (filled). Optional [clearable] shows a clear
/// control when hovered or focused; when [errorText] is set, hover still prefers clear
/// over the error icon if there is text (per Figma clearing guidelines).
@immutable
class NorthstarInputField extends StatefulWidget {
  const NorthstarInputField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.onInfoTap,
    this.helperText,
    this.placeholder,
    this.inlineText,
    this.errorText,
    this.leading,
    this.leadingPrefix,
    this.onLeadingPrefixTap,
    this.leadingCategoryLabel,
    this.onLeadingCategoryTap,
    this.suffixText,
    this.trailing,
    this.size = NorthstarInputFieldSize.medium,
    this.presentation = NorthstarInputFieldPresentation.editable,
    this.enabled = true,
    this.clearable = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.automationId,
  }) : assert(
          controller == null || initialValue == null,
          'Provide only one of controller or initialValue.',
        );

  /// When null, an internal [TextEditingController] is created (optionally from
  /// [initialValue]) and disposed with this widget.
  final TextEditingController? controller;

  /// Seed text when [controller] is null. Ignored when [controller] is non-null.
  final String? initialValue;

  final FocusNode? focusNode;

  /// Optional label above the field (title case recommended in copy).
  final String? label;

  /// When true, appends a red `*` after [label].
  final bool isRequired;

  /// Shows a trailing info control on the label row.
  final bool showInfoIcon;

  final VoidCallback? onInfoTap;

  /// Shown between label and field; wraps to the field width.
  final String? helperText;

  /// Hint when the value is empty.
  final String? placeholder;

  /// Right-aligned footer line (e.g. character hint); hidden if null.
  final String? inlineText;

  /// Left-aligned footer; also drives error border / trailing error icon when non-empty.
  final String? errorText;

  /// Custom leading widget inside the box (icon, avatar, etc.).
  final Widget? leading;

  /// Static prefix before the editable area (e.g. `+63`), with a vertical divider.
  final String? leadingPrefix;

  final VoidCallback? onLeadingPrefixTap;

  /// “Category” strip: label + chevron; tap handled by [onLeadingCategoryTap].
  final String? leadingCategoryLabel;

  final VoidCallback? onLeadingCategoryTap;

  /// Static suffix inside the box (e.g. `USD`).
  final String? suffixText;

  /// Trailing widget inside the box (dropdown chevron, calendar, etc.).
  final Widget? trailing;

  final NorthstarInputFieldSize size;

  final NorthstarInputFieldPresentation presentation;

  final bool enabled;

  /// When true, shows clear when hovered/focused (and on error hover when text exists).
  final bool clearable;

  final bool obscureText;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onEditingComplete;

  final int? maxLines;

  final int? minLines;

  final int? maxLength;

  final List<TextInputFormatter>? inputFormatters;

  final Iterable<String>? autofillHints;

  final TextCapitalization textCapitalization;

  /// Passed to [DsAutomationKeys] for the field subtree.
  final String? automationId;

  static const double _kRadius = 8;
  static const double _kGapLabelToHelper = 4;
  static const double _kGapHelperToField = 10;
  static const double _kGapFieldToFooter = 4;
  static const double _kBorderWidthDefault = 1;
  static const double _kBorderWidthFocused = 2;
  /// Figma `padding-top-14` / `padding-bottom-14` (not on [NorthstarSpacing] scale).
  static const double _kPadVMedium = 14;
  /// Figma `padding-left-20` / `padding-right-20`.
  static const double _kPadHMedium = 20;

  @override
  State<NorthstarInputField> createState() => _NorthstarInputFieldState();
}

class _NorthstarInputFieldState extends State<NorthstarInputField> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;
  late bool _hovering;

  TextEditingController get _effectiveController =>
      widget.controller ?? _ownedController!;

  FocusNode get _effectiveFocus => widget.focusNode ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    _hovering = false;
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: widget.initialValue ?? '');
    }
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _effectiveFocus.addListener(_onFocusChange);
    _effectiveController.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(covariant NorthstarInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller!.removeListener(_onTextChange);
      } else {
        _ownedController?.removeListener(_onTextChange);
      }
      if (widget.controller != null) {
        widget.controller!.addListener(_onTextChange);
      } else {
        _ownedController?.addListener(_onTextChange);
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode != null) {
        oldWidget.focusNode!.removeListener(_onFocusChange);
      } else {
        _ownedFocus?.removeListener(_onFocusChange);
      }
      if (widget.focusNode != null) {
        widget.focusNode!.addListener(_onFocusChange);
      } else {
        _ownedFocus?.addListener(_onFocusChange);
      }
    }
  }

  @override
  void dispose() {
    _effectiveFocus.removeListener(_onFocusChange);
    _effectiveController.removeListener(_onTextChange);
    _ownedFocus?.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.trim().isNotEmpty;

  bool get _isEditable =>
      widget.presentation == NorthstarInputFieldPresentation.editable;

  bool get _isViewOnly =>
      widget.presentation == NorthstarInputFieldPresentation.viewOnly;

  bool get _readOnlyField =>
      widget.presentation == NorthstarInputFieldPresentation.readOnly;

  EdgeInsets _contentPadding() {
    final double h = widget.size == NorthstarInputFieldSize.medium
        ? NorthstarInputField._kPadHMedium
        : NorthstarSpacing.space16;
    final double v = widget.size == NorthstarInputFieldSize.medium
        ? NorthstarInputField._kPadVMedium
        : NorthstarSpacing.space12;
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  double _inputFontSize() {
    return widget.size == NorthstarInputFieldSize.medium ? 16 : 14;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final bool effectiveEnabled =
        widget.enabled && (_isEditable || _readOnlyField);
    final bool focused = _effectiveFocus.hasFocus && effectiveEnabled;
    final String valueText = _effectiveController.text;
    final bool filled = valueText.isNotEmpty;

    if (_isViewOnly) {
      return _ViewOnlyColumn(
        label: widget.label,
        isRequired: widget.isRequired,
        showInfoIcon: widget.showInfoIcon,
        onInfoTap: widget.onInfoTap,
        helperText: widget.helperText,
        valueText: valueText.isEmpty ? (widget.placeholder ?? '') : valueText,
        placeholderStyle: valueText.isEmpty,
        scheme: scheme,
        automationId: widget.automationId,
      );
    }

    final TextStyle labelStyle = NorthstarTextRole.label
        .style(context)
        .copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
          color: focused ? scheme.primary : scheme.onSurface,
        );

    final TextStyle helperStyle = NorthstarTextRole.body
        .style(context)
        .copyWith(
          fontSize: 14,
          height: 1.3,
          color: scheme.onSurfaceVariant,
        );

    final TextStyle inputStyle = TextStyle(
      fontSize: _inputFontSize(),
      height: 1.25,
      color: effectiveEnabled ? scheme.onSurface : scheme.onSurfaceVariant,
    );

    final TextStyle hintStyle = inputStyle.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Color borderColor;
    double borderWidth = NorthstarInputField._kBorderWidthDefault;
    if (!effectiveEnabled) {
      borderColor = scheme.outlineVariant;
    } else if (_hasError) {
      borderColor = scheme.error;
    } else if (focused) {
      borderColor = scheme.primary;
      borderWidth = NorthstarInputField._kBorderWidthFocused;
    } else if (_hovering) {
      borderColor = scheme.outline;
    } else {
      borderColor = scheme.outlineVariant;
    }

    Color fillColor;
    if (!effectiveEnabled) {
      fillColor = ns.surfaceContainerLow;
    } else if (_readOnlyField) {
      fillColor = ns.surfaceContainerLow;
    } else if (_hasError) {
      fillColor = Color.alphaBlend(
        scheme.error.withValues(alpha: 0.06),
        scheme.surface,
      );
    } else {
      fillColor = scheme.surface;
    }

    final Widget? resolvedTrailing = _buildTrailing(
      context,
      scheme: scheme,
      effectiveEnabled: effectiveEnabled,
      filled: filled,
    );

    final Widget fieldCore = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.leadingCategoryLabel != null) ...<Widget>[
          _LeadingCategory(
            label: widget.leadingCategoryLabel!,
            enabled: effectiveEnabled && _isEditable,
            onTap: widget.onLeadingCategoryTap,
            scheme: scheme,
            size: widget.size,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: scheme.outlineVariant,
          ),
        ],
        if (widget.leading != null) ...<Widget>[
          IconTheme.merge(
            data: IconThemeData(
              size: 20,
              color: effectiveEnabled
                  ? scheme.onSurfaceVariant
                  : scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            child: widget.leading!,
          ),
          SizedBox(
            width: widget.size == NorthstarInputFieldSize.medium
                ? NorthstarSpacing.space12
                : NorthstarSpacing.space8,
          ),
        ],
        if (widget.leadingPrefix != null) ...<Widget>[
          _LeadingPrefix(
            text: widget.leadingPrefix!,
            onTap: widget.onLeadingPrefixTap,
            enabled: effectiveEnabled,
            scheme: scheme,
            style: inputStyle,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: scheme.outlineVariant,
          ),
        ],
        Expanded(
          child: TextField(
            key: DsAutomationKeys.part(widget.automationId, 'text_field'),
            controller: _effectiveController,
            focusNode: _effectiveFocus,
            enabled: effectiveEnabled && _isEditable,
            readOnly: _readOnlyField,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            autofillHints: widget.autofillHints,
            textCapitalization: widget.textCapitalization,
            style: inputStyle,
            cursorColor: scheme.primary,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: widget.placeholder,
              hintStyle: hintStyle,
              counterText: '',
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            onEditingComplete: widget.onEditingComplete,
          ),
        ),
        if (widget.suffixText != null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(left: NorthstarSpacing.space8),
            child: Text(
              widget.suffixText!,
              style: inputStyle.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
        if (resolvedTrailing != null) ...<Widget>[
          SizedBox(
            width: widget.size == NorthstarInputFieldSize.medium
                ? NorthstarSpacing.space8
                : NorthstarSpacing.space4,
          ),
          resolvedTrailing,
        ],
      ],
    );

    final Widget decoratedField = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(NorthstarInputField._kRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: Padding(
          padding: _contentPadding(),
          child: fieldCore,
        ),
      ),
    );

    final bool showFooter =
        (widget.inlineText != null && widget.inlineText!.isNotEmpty) || _hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  key: DsAutomationKeys.part(widget.automationId, 'label'),
                  TextSpan(
                    style: labelStyle,
                    children: <InlineSpan>[
                      TextSpan(text: widget.label),
                      if (widget.isRequired)
                        TextSpan(
                          text: ' *',
                          style: labelStyle.copyWith(color: scheme.error),
                        ),
                    ],
                  ),
                ),
              ),
              if (widget.showInfoIcon)
                IconButton(
                  key: DsAutomationKeys.part(
                    widget.automationId,
                    DsAutomationKeys.elementInputInfo,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: widget.onInfoTap,
                  tooltip: 'Info',
                ),
            ],
          ),
          if (widget.helperText != null &&
              widget.helperText!.trim().isNotEmpty) ...<Widget>[
            SizedBox(height: NorthstarInputField._kGapLabelToHelper),
            Text(
              widget.helperText!,
              key: DsAutomationKeys.part(widget.automationId, 'helper'),
              style: _hasError
                  ? helperStyle.copyWith(color: scheme.error)
                  : helperStyle,
            ),
          ],
          SizedBox(height: NorthstarInputField._kGapHelperToField),
        ] else if (widget.helperText != null &&
            widget.helperText!.trim().isNotEmpty) ...<Widget>[
          Text(
            widget.helperText!,
            key: DsAutomationKeys.part(widget.automationId, 'helper'),
            style: _hasError
                ? helperStyle.copyWith(color: scheme.error)
                : helperStyle,
          ),
          SizedBox(height: NorthstarInputField._kGapHelperToField),
        ],
        decoratedField,
        if (showFooter) ...<Widget>[
          SizedBox(height: NorthstarInputField._kGapFieldToFooter),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _hasError
                    ? Text(
                        widget.errorText!,
                        key: DsAutomationKeys.part(
                          widget.automationId,
                          'error',
                        ),
                        style: helperStyle.copyWith(color: scheme.error),
                      )
                    : const SizedBox.shrink(),
              ),
              if (widget.inlineText != null &&
                  widget.inlineText!.isNotEmpty)
                Text(
                  widget.inlineText!,
                  key: DsAutomationKeys.part(widget.automationId, 'inline'),
                  style: helperStyle,
                  textAlign: TextAlign.right,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildTrailing(
    BuildContext context, {
    required ColorScheme scheme,
    required bool effectiveEnabled,
    required bool filled,
  }) {
    final bool preferClear = widget.clearable &&
        filled &&
        effectiveEnabled &&
        _isEditable &&
        (_hovering || _effectiveFocus.hasFocus);

    if (preferClear) {
      return IconButton(
        key: DsAutomationKeys.part(
          widget.automationId,
          DsAutomationKeys.elementInputClear,
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        icon: Icon(Icons.close, size: 20, color: scheme.onSurfaceVariant),
        onPressed: () {
          _effectiveController.clear();
          widget.onChanged?.call('');
          setState(() {});
        },
        tooltip: 'Clear',
      );
    }

    if (_hasError) {
      return Icon(
        Icons.error_outline,
        key: DsAutomationKeys.part(widget.automationId, 'error_icon'),
        size: 20,
        color: scheme.error,
      );
    }

    return widget.trailing;
  }
}

class _ViewOnlyColumn extends StatelessWidget {
  const _ViewOnlyColumn({
    required this.label,
    required this.isRequired,
    required this.showInfoIcon,
    required this.onInfoTap,
    required this.helperText,
    required this.valueText,
    required this.placeholderStyle,
    required this.scheme,
    required this.automationId,
  });

  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final VoidCallback? onInfoTap;
  final String? helperText;
  final String valueText;
  final bool placeholderStyle;
  final ColorScheme scheme;
  final String? automationId;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = NorthstarTextRole.label
        .style(context)
        .copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.2,
          color: scheme.onSurface,
        );

    final TextStyle valueStyle = NorthstarTextRole.bodyLarge
        .style(context)
        .copyWith(
          fontSize: 16,
          height: 1.35,
          color: placeholderStyle
              ? scheme.onSurfaceVariant
              : scheme.onSurface,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (label != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  key: DsAutomationKeys.part(automationId, 'label'),
                  TextSpan(
                    style: labelStyle,
                    children: <InlineSpan>[
                      TextSpan(text: label),
                      if (isRequired)
                        TextSpan(
                          text: ' *',
                          style: labelStyle.copyWith(color: scheme.error),
                        ),
                    ],
                  ),
                ),
              ),
              if (showInfoIcon)
                IconButton(
                  key: DsAutomationKeys.part(
                    automationId,
                    DsAutomationKeys.elementInputInfo,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: onInfoTap,
                  tooltip: 'Info',
                ),
            ],
          ),
        if (helperText != null && helperText!.trim().isNotEmpty) ...<Widget>[
          SizedBox(height: NorthstarInputField._kGapLabelToHelper),
          Text(
            helperText!,
            key: DsAutomationKeys.part(automationId, 'helper'),
            style: NorthstarTextRole.body
                .style(context)
                .copyWith(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
        if (label != null || (helperText != null && helperText!.isNotEmpty))
          SizedBox(height: NorthstarInputField._kGapHelperToField),
        Text(
          valueText,
          key: DsAutomationKeys.part(automationId, 'view_value'),
          style: valueStyle,
        ),
      ],
    );
  }
}

class _LeadingPrefix extends StatelessWidget {
  const _LeadingPrefix({
    required this.text,
    required this.onTap,
    required this.enabled,
    required this.scheme,
    required this.style,
  });

  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final ColorScheme scheme;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final Widget child = Padding(
      padding: const EdgeInsets.only(right: NorthstarSpacing.space8),
      child: Text(
        text,
        style: style.copyWith(color: scheme.onSurfaceVariant),
      ),
    );

    if (onTap != null && enabled) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: child,
      );
    }
    return child;
  }
}

class _LeadingCategory extends StatelessWidget {
  const _LeadingCategory({
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.scheme,
    required this.size,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final NorthstarInputFieldSize size;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      fontSize: size == NorthstarInputFieldSize.medium ? 14 : 13,
      color: scheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    final Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: style),
        const SizedBox(width: NorthstarSpacing.space4),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );

    if (onTap != null && enabled) {
      return Padding(
        padding: const EdgeInsets.only(right: NorthstarSpacing.space8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: row,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: NorthstarSpacing.space8),
      child: row,
    );
  }
}
