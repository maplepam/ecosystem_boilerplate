import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_chip.dart';
import 'package:emp_ai_ds_widgets/src/display/text_area/quill/northstar_text_area_quill_color.dart';
import 'package:emp_ai_ds_widgets/src/display/text_area/quill/northstar_text_area_quill_html.dart';
import 'package:emp_ai_ds_widgets/src/display/text_area/quill/northstar_text_area_quill_toolbar.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';

/// Layout / behavior preset for [NorthstarTextArea].
enum NorthstarTextAreaVariant {
  /// Multiline [TextField] only (optional character counter).
  standard,

  /// Wrapping removable tags + inline add field; scrolls after [maxHeight].
  chips,

  /// Rich-text toolbar: WYSIWYG editing (Quill) with HTML via [onRichHtmlChanged].
  richText,
}

/// Northstar **Text Area**: label (optional `*`), helper, 8px-radius shell,
/// multiline input with optional counter, error footer.
///
/// **Variants:** [NorthstarTextAreaVariant.standard], [chips] (pass [chips] +
/// [onChipsChanged]), [richText] ([NorthstarTextAreaRichToolbar] + Quill editor;
/// [onRichHtmlChanged] for HTML, [onChanged] for plain text; optional
/// [richToolbarApplyTextEdits]; [onRichToolbarAction] after each action).
///
/// **Tokens:** [ThemeData.colorScheme], [NorthstarColorTokens], [NorthstarSpacing].
/// Focus border uses [ColorScheme.primary]; at character limit the counter uses
/// Figma **rgb(255, 108, 139)**. Does not run validators — pass [errorText]
/// from the parent.
@immutable
class NorthstarTextArea extends StatefulWidget {
  const NorthstarTextArea({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.label,
    this.isRequired = false,
    this.showInfoIcon = false,
    this.onInfoTap,
    this.helperText,
    this.placeholder = 'Start typing here…',
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.variant = NorthstarTextAreaVariant.standard,
    this.characterLimit,
    this.minHeight = 56,
    this.maxHeight = 256,
    this.chips = const <String>[],
    this.onChipsChanged,
    this.chipInputHint = 'Add item',
    this.onChanged,
    this.onSubmitted,
    this.onRichToolbarAction,
    this.initialRichHtml,
    this.onRichHtmlChanged,
    this.richParagraphStyleLabel = 'Normal text',
    this.richToolbarApplyTextEdits = true,
    this.automationId,
  })  : assert(
          controller == null || initialValue == null,
          'Provide only one of controller or initialValue.',
        ),
        assert(minHeight > 0),
        assert(maxHeight >= minHeight);

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final String? label;
  final bool isRequired;
  final bool showInfoIcon;
  final VoidCallback? onInfoTap;
  final String? helperText;
  final String? placeholder;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final NorthstarTextAreaVariant variant;
  final int? characterLimit;
  final double minHeight;
  final double maxHeight;
  final List<String> chips;
  final ValueChanged<List<String>>? onChipsChanged;
  final String chipInputHint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onRichToolbarAction;

  /// Optional HTML seed when [variant] is [NorthstarTextAreaVariant.richText].
  ///
  /// Plain [initialValue] / [controller] text is used when this is null or empty.
  final String? initialRichHtml;

  /// Fired when the rich document changes; see [northstarQuillDocumentToHtml].
  final ValueChanged<String>? onRichHtmlChanged;

  /// Shown in the rich-text **paragraph style** menu trigger ([NorthstarTextAreaVariant.richText]).
  final String richParagraphStyleLabel;

  /// When true (default), toolbar actions update the Quill document (undo/redo,
  /// inline/block styles). Set false to handle actions only in [onRichToolbarAction].
  final bool richToolbarApplyTextEdits;
  final String? automationId;

  static const double _kRadius = 8;
  static const double _kGapLabelToHelper = 4;
  static const double _kGapHelperToField = 12;
  static const double _kGapFieldToFooter = 4;
  static const double _kBorderWidthDefault = 1;
  static const double _kBorderWidthFocused = 2;
  static const double _kPadH = 16;
  static const double _kPadV = 14;

  /// Figma limit / error accent for counter at **0** remaining.
  static const Color _kLimitCounterColor = Color(0xFFFF6C8B);

  @override
  State<NorthstarTextArea> createState() => _NorthstarTextAreaState();
}

class _NorthstarTextAreaState extends State<NorthstarTextArea> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocus;
  late final TextEditingController _chipInputController;
  late final FocusNode _chipFocus;
  bool _hovering = false;

  QuillController? _quillController;
  ScrollController? _quillScrollController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _ownedController!;

  FocusNode get _effectiveFocus => widget.focusNode ?? _ownedFocus!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: widget.initialValue ?? '');
    }
    if (widget.focusNode == null) {
      _ownedFocus = FocusNode();
    }
    _chipInputController = TextEditingController();
    _chipFocus = FocusNode();
    _effectiveFocus.addListener(_repaint);
    _effectiveController.addListener(_repaint);
  }

  @override
  void didUpdateWidget(covariant NorthstarTextArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller!.removeListener(_repaint);
      } else {
        _ownedController?.removeListener(_repaint);
      }
      if (widget.controller != null) {
        _ownedController?.dispose();
        _ownedController = null;
        widget.controller!.addListener(_repaint);
      } else {
        final String seed = oldWidget.controller?.text ??
            _ownedController?.text ??
            widget.initialValue ??
            '';
        _ownedController?.dispose();
        _ownedController = TextEditingController(text: seed);
        _ownedController!.addListener(_repaint);
      }
    }
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode != null) {
        oldWidget.focusNode!.removeListener(_repaint);
      } else {
        _ownedFocus?.removeListener(_repaint);
      }
      if (widget.focusNode != null) {
        _ownedFocus?.dispose();
        _ownedFocus = null;
        widget.focusNode!.addListener(_repaint);
      } else {
        _ownedFocus ??= FocusNode();
        _ownedFocus!.addListener(_repaint);
      }
    }
    if (oldWidget.variant == NorthstarTextAreaVariant.richText &&
        widget.variant != NorthstarTextAreaVariant.richText) {
      _disposeQuill(syncPlainToExternalController: true);
    }
  }

  @override
  void dispose() {
    _disposeQuill();
    _effectiveFocus.removeListener(_repaint);
    _effectiveController.removeListener(_repaint);
    _ownedFocus?.dispose();
    _ownedController?.dispose();
    _chipInputController.dispose();
    _chipFocus.dispose();
    super.dispose();
  }

  void _repaint() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.trim().isNotEmpty;

  bool get _effectiveEditable => widget.enabled && !widget.readOnly;

  List<TextInputFormatter> get _formatters {
    final int? lim = widget.characterLimit;
    if (lim == null ||
        widget.variant == NorthstarTextAreaVariant.chips ||
        widget.variant == NorthstarTextAreaVariant.richText) {
      return const <TextInputFormatter>[];
    }
    return <TextInputFormatter>[
      LengthLimitingTextInputFormatter(lim),
    ];
  }

  void _addChip(String raw) {
    final String t = raw.trim();
    if (t.isEmpty || widget.onChipsChanged == null) {
      return;
    }
    widget.onChipsChanged!(<String>[...widget.chips, t]);
    _chipInputController.clear();
  }

  void _removeChip(int index) {
    if (widget.onChipsChanged == null) {
      return;
    }
    final List<String> next = List<String>.from(widget.chips)..removeAt(index);
    widget.onChipsChanged!(next);
  }

  bool get _isRichVariant =>
      widget.variant == NorthstarTextAreaVariant.richText;

  int _richPlainCharCount() {
    final QuillController? c = _quillController;
    if (c == null) {
      return 0;
    }
    return c.document.toPlainText().length;
  }

  void _disposeQuill({bool syncPlainToExternalController = false}) {
    final QuillController? c = _quillController;
    if (c == null) {
      return;
    }
    if (syncPlainToExternalController && widget.controller != null) {
      widget.controller!.text = c.document.toPlainText();
    }
    c.removeListener(_onQuillChanged);
    c.dispose();
    _quillController = null;
    _quillScrollController?.dispose();
    _quillScrollController = null;
  }

  Document _createRichSeedDocument() {
    final String? html = widget.initialRichHtml;
    if (html != null && html.trim().isNotEmpty) {
      try {
        final Delta delta = HtmlToDelta().convert(html);
        return Document.fromDelta(delta);
      } on Object {
        // Fall through to plain seed.
      }
    }
    final String plain = widget.controller?.text ?? widget.initialValue ?? '';
    if (plain.isEmpty) {
      return Document();
    }
    final Document doc = Document();
    doc.insert(0, plain);
    return doc;
  }

  void _ensureQuillController() {
    if (!_isRichVariant) {
      return;
    }
    if (_quillController != null) {
      _quillController!.readOnly = !_effectiveEditable;
      return;
    }
    _quillScrollController = ScrollController();
    _quillController = QuillController(
      document: _createRichSeedDocument(),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: !_effectiveEditable,
      onReplaceText: _quillOnReplaceText,
    );
    _quillController!.addListener(_onQuillChanged);
  }

  bool _quillOnReplaceText(int index, int len, Object? data) {
    final int? lim = widget.characterLimit;
    if (lim == null) {
      return true;
    }
    if (data is Delta) {
      return true;
    }
    final String before = _quillController!.document.toPlainText();
    int insertLen = 0;
    if (data is String) {
      insertLen = data.length;
    } else {
      insertLen = 1;
    }
    final int nextLen = before.length - len + insertLen;
    return nextLen <= lim;
  }

  void _onQuillChanged() {
    final QuillController? c = _quillController;
    if (c == null) {
      return;
    }
    widget.onChanged?.call(c.document.toPlainText());
    widget.onRichHtmlChanged?.call(northstarQuillDocumentToHtml(c.document));
    _repaint();
  }

  void _handleRichToolbarAction(String id) {
    if (_isRichVariant && _quillController != null) {
      applyNorthstarRichToolbarToQuill(
        _quillController!,
        id,
        applyEdits: widget.richToolbarApplyTextEdits,
      );
    }
    widget.onRichToolbarAction?.call(id);
    if (_isRichVariant) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _ensureQuillController();
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final bool focused =
        (_effectiveFocus.hasFocus || _chipFocus.hasFocus) && widget.enabled;
    final String bodyText = _effectiveController.text;
    final int len = _isRichVariant && _quillController != null
        ? _richPlainCharCount()
        : bodyText.length;
    final int? lim = widget.characterLimit;
    final int remaining = lim == null ? 0 : (lim - len).clamp(0, lim);
    final bool atLimit = lim != null && remaining == 0 && len >= lim;

    final TextStyle labelStyle =
        NorthstarTextRole.label.style(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.2,
              color: focused ? scheme.primary : scheme.onSurface,
            );

    final TextStyle helperStyle =
        NorthstarTextRole.body.style(context).copyWith(
              fontSize: 14,
              height: 1.3,
              color: scheme.onSurfaceVariant,
            );

    final TextStyle inputStyle = TextStyle(
      fontSize: 14,
      height: 1.35,
      color: widget.enabled ? scheme.onSurface : scheme.onSurfaceVariant,
    );

    final TextStyle hintStyle = inputStyle.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Color borderColor;
    double borderWidth = NorthstarTextArea._kBorderWidthDefault;
    if (!widget.enabled) {
      borderColor = scheme.outlineVariant;
    } else if (_hasError) {
      borderColor = scheme.error;
    } else if (focused) {
      borderColor = scheme.primary;
      borderWidth = NorthstarTextArea._kBorderWidthFocused;
    } else if (_hovering) {
      borderColor = scheme.outline;
    } else {
      borderColor = scheme.outlineVariant;
    }

    Color fillColor;
    if (!widget.enabled) {
      fillColor = ns.surfaceContainerLow;
    } else if (_hasError) {
      fillColor = Color.alphaBlend(
        scheme.error.withValues(alpha: 0.06),
        scheme.surface,
      );
    } else {
      fillColor = scheme.surface;
    }

    final Widget body = _buildBody(
      context,
      scheme: scheme,
      inputStyle: inputStyle,
      hintStyle: hintStyle,
    );

    final bool showCounter =
        lim != null && widget.variant != NorthstarTextAreaVariant.chips;
    final double bottomPad =
        showCounter ? NorthstarTextArea._kPadV + 18 : NorthstarTextArea._kPadV;

    final Widget shell = MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(NorthstarTextArea._kRadius),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(
                NorthstarTextArea._kPadH,
                NorthstarTextArea._kPadV,
                NorthstarTextArea._kPadH,
                bottomPad,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: widget.minHeight,
                  maxHeight: widget.maxHeight,
                ),
                child: body,
              ),
            ),
            if (showCounter)
              Positioned(
                right: NorthstarTextArea._kPadH,
                bottom: NorthstarSpacing.space8,
                child: Text(
                  '$len/$lim',
                  style: helperStyle.copyWith(
                    fontSize: 12,
                    color: atLimit
                        ? NorthstarTextArea._kLimitCounterColor
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final bool showFooter = _hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text.rich(
                  key: DsAutomationKeys.part(
                    widget.automationId,
                    DsAutomationKeys.elementTextAreaLabel,
                  ),
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
            SizedBox(height: NorthstarTextArea._kGapLabelToHelper),
            Text(
              widget.helperText!,
              key: DsAutomationKeys.part(
                widget.automationId,
                DsAutomationKeys.elementTextAreaHelper,
              ),
              style: _hasError
                  ? helperStyle.copyWith(color: scheme.error)
                  : helperStyle,
            ),
          ],
          SizedBox(height: NorthstarTextArea._kGapHelperToField),
        ] else if (widget.helperText != null &&
            widget.helperText!.trim().isNotEmpty) ...<Widget>[
          Text(
            widget.helperText!,
            key: DsAutomationKeys.part(
              widget.automationId,
              DsAutomationKeys.elementTextAreaHelper,
            ),
            style: _hasError
                ? helperStyle.copyWith(color: scheme.error)
                : helperStyle,
          ),
          SizedBox(height: NorthstarTextArea._kGapHelperToField),
        ],
        shell,
        if (showFooter) ...<Widget>[
          SizedBox(height: NorthstarTextArea._kGapFieldToFooter),
          Text(
            widget.errorText!,
            key: DsAutomationKeys.part(
              widget.automationId,
              DsAutomationKeys.elementTextAreaError,
            ),
            style: helperStyle.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required ColorScheme scheme,
    required TextStyle inputStyle,
    required TextStyle hintStyle,
  }) {
    switch (widget.variant) {
      case NorthstarTextAreaVariant.chips:
        return _buildChipsBody(
          context,
          scheme: scheme,
          inputStyle: inputStyle,
          hintStyle: hintStyle,
        );
      case NorthstarTextAreaVariant.richText:
        final QuillController quill = _quillController!;
        final ScrollController quillScroll = _quillScrollController!;
        final DefaultStyles quillStyles =
            DefaultStyles.getInstance(context).merge(
          DefaultStyles(
            paragraph: DefaultTextBlockStyle(
              inputStyle,
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
            placeHolder: DefaultTextBlockStyle(
              hintStyle,
              HorizontalSpacing.zero,
              VerticalSpacing.zero,
              VerticalSpacing.zero,
              null,
            ),
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NorthstarTextAreaRichToolbar(
              enabled: _effectiveEditable,
              paragraphStyleLabel: widget.richParagraphStyleLabel,
              onAction: _handleRichToolbarAction,
              automationId: widget.automationId,
              quillController: quill,
            ),
            const SizedBox(height: NorthstarSpacing.space8),
            Expanded(
              child: Localizations.override(
                context: context,
                delegates: const <LocalizationsDelegate<dynamic>>[
                  FlutterQuillLocalizations.delegate,
                ],
                child: QuillEditor(
                  key: DsAutomationKeys.part(
                    widget.automationId,
                    DsAutomationKeys.elementTextAreaField,
                  ),
                  focusNode: _effectiveFocus,
                  scrollController: quillScroll,
                  controller: quill,
                  config: QuillEditorConfig(
                    placeholder: widget.placeholder,
                    padding: EdgeInsets.zero,
                    customStyles: quillStyles,
                    minHeight: widget.minHeight,
                    maxHeight: widget.maxHeight,
                    scrollPhysics: const BouncingScrollPhysics(),
                  ),
                ),
              ),
            ),
          ],
        );
      case NorthstarTextAreaVariant.standard:
        return _buildPlainField(
          scheme: scheme,
          inputStyle: inputStyle,
          hintStyle: hintStyle,
        );
    }
  }

  Widget _buildPlainField({
    required ColorScheme scheme,
    required TextStyle inputStyle,
    required TextStyle hintStyle,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      key: DsAutomationKeys.part(
        widget.automationId,
        DsAutomationKeys.elementTextAreaField,
      ),
      controller: _effectiveController,
      focusNode: _effectiveFocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: null,
      minLines: 2,
      textAlign: textAlign,
      inputFormatters: _formatters,
      style: inputStyle,
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.placeholder,
        hintStyle: hintStyle,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }

  Widget _buildChipsBody(
    BuildContext context, {
    required ColorScheme scheme,
    required TextStyle inputStyle,
    required TextStyle hintStyle,
  }) {
    final bool canEdit = _effectiveEditable && widget.onChipsChanged != null;

    return Scrollbar(
      child: SingleChildScrollView(
        child: Wrap(
          spacing: NorthstarSpacing.space8,
          runSpacing: NorthstarSpacing.space8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            for (int i = 0; i < widget.chips.length; i++)
              NorthstarChip(
                useCase: NorthstarChipUseCase.input,
                label: widget.chips[i],
                showCloseButton: true,
                selected: true,
                disabled: !canEdit,
                onClose: canEdit ? () => _removeChip(i) : null,
                automationId: widget.automationId == null
                    ? null
                    : '${widget.automationId}_chip_$i',
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 120, maxWidth: 200),
              child: TextField(
                key: DsAutomationKeys.part(
                  widget.automationId,
                  DsAutomationKeys.elementTextAreaChipsInput,
                ),
                controller: _chipInputController,
                focusNode: _chipFocus,
                enabled: canEdit,
                style: inputStyle,
                cursorColor: scheme.primary,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.chipInputHint,
                  hintStyle: hintStyle,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: canEdit ? _addChip : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rich-text formatting strip for [NorthstarTextArea] ([NorthstarTextAreaVariant.richText]).
///
/// Includes undo/redo, **paragraph style** menu, inline format actions, lists,
/// **alignment** menu, indent, clear formatting, and overflow **more**. Styling
/// follows the Northstar spec: light toolbar band **rgb(248, 250, 252)** in light
/// mode; elevated dark strip in dark mode with high-contrast icons (see Figma).
///
/// [onAction] receives stable ids (`bold`, `style_h1`, `align_center`, `color`, …).
/// When used inside [NorthstarTextArea] ([NorthstarTextAreaVariant.richText]) with
/// [quillController] set, bold/italic/underline/strike show pressed state from the
/// selection (including toggled typing style), and **Text color** opens a picker.
/// [onAction] still runs for each control (unless [NorthstarTextArea.richToolbarApplyTextEdits]
/// prevents Quill updates for toolbar-driven formats).
class NorthstarTextAreaRichToolbar extends StatelessWidget {
  const NorthstarTextAreaRichToolbar({
    super.key,
    required this.enabled,
    this.paragraphStyleLabel = 'Normal text',
    this.onAction,
    this.automationId,
    this.quillController,
  });

  final bool enabled;
  final String paragraphStyleLabel;
  final ValueChanged<String>? onAction;
  final String? automationId;

  /// When set (rich mode), inline toggles reflect [QuillController] state and
  /// the text-color control applies Quill color attributes.
  final QuillController? quillController;

  static const Color _kToolbarBgLight = Color(0xFFF8FAFC);

  static void _emit(ValueChanged<String>? onAction, String id) {
    onAction?.call(id);
  }

  static bool _isQuillToggleOn(QuillController? c, Attribute attr) {
    if (c == null) {
      return false;
    }
    return c.getSelectionStyle().attributes.containsKey(attr.key);
  }

  Widget _iconButton(
    BuildContext context, {
    required IconData icon,
    required String id,
    required Color iconColor,
    required ColorScheme scheme,
    String? tooltip,
    bool selected = false,
  }) {
    final VoidCallback? onTap =
        enabled ? () => _emit(onAction, id) : null;
    final Widget iconWidget = Icon(icon, size: 20);
    final Key? btnKey = DsAutomationKeys.part(
      automationId,
      '${DsAutomationKeys.elementTextAreaToolbar}_$id',
    );
    if (selected) {
      return IconButton.filled(
        key: btnKey,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        style: IconButton.styleFrom(
          foregroundColor: scheme.primary,
          backgroundColor: scheme.primary.withValues(alpha: 0.22),
          hoverColor: scheme.primary.withValues(alpha: 0.28),
          highlightColor: scheme.primary.withValues(alpha: 0.32),
        ),
        tooltip: tooltip ?? id,
        onPressed: onTap,
        icon: iconWidget,
      );
    }
    return IconButton(
      key: btnKey,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      style: IconButton.styleFrom(
        foregroundColor: iconColor,
        hoverColor: iconColor.withValues(alpha: 0.12),
        highlightColor: iconColor.withValues(alpha: 0.18),
      ),
      icon: iconWidget,
      tooltip: tooltip ?? id,
      onPressed: onTap,
    );
  }

  Widget _textColorButton(
    BuildContext context, {
    required ColorScheme scheme,
    required Color iconColor,
  }) {
    final QuillController? c = quillController;
    final Map<String, Attribute> attrs =
        c?.getSelectionStyle().attributes ?? <String, Attribute>{};
    final bool hasColor = attrs.containsKey(Attribute.color.key);
    final String? hex =
        attrs[Attribute.color.key]?.value as String?;
    final Color? tint = northstarColorFromQuillHex(hex);
    final Color fg = tint ?? (hasColor ? scheme.primary : iconColor);
    final Key? btnKey = DsAutomationKeys.part(
      automationId,
      '${DsAutomationKeys.elementTextAreaToolbar}_color',
    );
    if (hasColor) {
      return IconButton.filled(
        key: btnKey,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 34, height: 34),
        style: IconButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: scheme.primary.withValues(alpha: 0.22),
          hoverColor: scheme.primary.withValues(alpha: 0.28),
          highlightColor: scheme.primary.withValues(alpha: 0.32),
        ),
        tooltip: 'Text color',
        onPressed: enabled && c != null
            ? () async {
                final bool applied =
                    await showNorthstarTextAreaTextColorPicker(
                  context: context,
                  controller: c,
                );
                if (applied) {
                  _emit(onAction, 'color');
                }
              }
            : null,
        icon: Icon(Icons.format_color_text, size: 20, color: fg),
      );
    }
    return IconButton(
      key: btnKey,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
      style: IconButton.styleFrom(
        foregroundColor: iconColor,
        hoverColor: iconColor.withValues(alpha: 0.12),
        highlightColor: iconColor.withValues(alpha: 0.18),
      ),
      icon: Icon(Icons.format_color_text, size: 20),
      tooltip: 'Text color',
      onPressed: enabled && c != null
          ? () async {
              final bool applied =
                  await showNorthstarTextAreaTextColorPicker(
                context: context,
                controller: c,
              );
              if (applied) {
                _emit(onAction, 'color');
              }
            }
          : null,
    );
  }

  Widget _toolbarScrollRow(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;
    final Color iconColor = isDark
        ? scheme.onSurface.withValues(alpha: 0.92)
        : scheme.onSurfaceVariant;
    final TextStyle labelStyle = theme.textTheme.labelMedium!.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: iconColor,
    );
    final QuillController? q = quillController;

    return Row(
      children: <Widget>[
        _iconButton(
          context,
          icon: Icons.undo_rounded,
          id: 'undo',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Undo',
        ),
        _iconButton(
          context,
          icon: Icons.redo_rounded,
          id: 'redo',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Redo',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NorthstarSpacing.space4,
          ),
          child: PopupMenuButton<String>(
            key: DsAutomationKeys.part(
              automationId,
              '${DsAutomationKeys.elementTextAreaToolbar}_style_menu',
            ),
            enabled: enabled,
            tooltip: 'Text style',
            onSelected: (String id) => _emit(onAction, id),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'style_normal',
                  child: Text(
                    'Normal text',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'style_h1',
                  child: Text(
                    'Heading 1',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'style_h2',
                  child: Text(
                    'Heading 2',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'style_quote',
                  child: Text(
                    'Quote',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: NorthstarSpacing.space8,
                vertical: NorthstarSpacing.space4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(paragraphStyleLabel, style: labelStyle),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 22,
                    color: iconColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        _iconButton(
          context,
          icon: Icons.format_bold,
          id: 'bold',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Bold',
          selected: _isQuillToggleOn(q, Attribute.bold),
        ),
        _iconButton(
          context,
          icon: Icons.format_italic,
          id: 'italic',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Italic',
          selected: _isQuillToggleOn(q, Attribute.italic),
        ),
        _iconButton(
          context,
          icon: Icons.format_underlined,
          id: 'underline',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Underline',
          selected: _isQuillToggleOn(q, Attribute.underline),
        ),
        _iconButton(
          context,
          icon: Icons.format_strikethrough,
          id: 'strikethrough',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Strikethrough',
          selected: _isQuillToggleOn(q, Attribute.strikeThrough),
        ),
        _textColorButton(context, scheme: scheme, iconColor: iconColor),
        _iconButton(
          context,
          icon: Icons.link_rounded,
          id: 'link',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Insert link',
        ),
        _iconButton(
          context,
          icon: Icons.format_list_bulleted,
          id: 'bullet',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Bulleted list',
        ),
        _iconButton(
          context,
          icon: Icons.format_list_numbered,
          id: 'numbered',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Numbered list',
        ),
        PopupMenuButton<String>(
          key: DsAutomationKeys.part(
            automationId,
            '${DsAutomationKeys.elementTextAreaToolbar}_align_menu',
          ),
          enabled: enabled,
          tooltip: 'Alignment',
          onSelected: (String id) => _emit(onAction, id),
          itemBuilder: (BuildContext menuContext) {
            final Color fg =
                Theme.of(menuContext).colorScheme.onSurface;
            return <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'align_left',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.format_align_left, size: 20, color: fg),
                    const SizedBox(width: NorthstarSpacing.space12),
                    Text('Align left', style: TextStyle(color: fg)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'align_center',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.format_align_center,
                        size: 20, color: fg),
                    const SizedBox(width: NorthstarSpacing.space12),
                    Text('Align center', style: TextStyle(color: fg)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'align_right',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.format_align_right, size: 20, color: fg),
                    const SizedBox(width: NorthstarSpacing.space12),
                    Text('Align right', style: TextStyle(color: fg)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'align_justify',
                child: Row(
                  children: <Widget>[
                    Icon(Icons.format_align_justify,
                        size: 20, color: fg),
                    const SizedBox(width: NorthstarSpacing.space12),
                    Text('Justify', style: TextStyle(color: fg)),
                  ],
                ),
              ),
            ];
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(
              Icons.format_align_left,
              size: 20,
              color: enabled
                  ? iconColor
                  : iconColor.withValues(alpha: 0.38),
            ),
          ),
        ),
        _iconButton(
          context,
          icon: Icons.format_indent_decrease,
          id: 'outdent',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Decrease indent',
        ),
        _iconButton(
          context,
          icon: Icons.format_indent_increase,
          id: 'indent',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Increase indent',
        ),
        _iconButton(
          context,
          icon: Icons.format_clear,
          id: 'clear',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'Clear formatting',
        ),
        _iconButton(
          context,
          icon: Icons.more_vert,
          id: 'more',
          iconColor: iconColor,
          scheme: scheme,
          tooltip: 'More',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color barBg = isDark
        ? scheme.surfaceContainerHighest
        : NorthstarTextAreaRichToolbar._kToolbarBgLight;
    final Color dividerColor =
        isDark ? scheme.outline.withValues(alpha: 0.28) : scheme.outlineVariant;

    final Widget row = quillController == null
        ? _toolbarScrollRow(context)
        : ListenableBuilder(
            listenable: quillController!,
            builder: (BuildContext ctx, Widget? _) => _toolbarScrollRow(ctx),
          );

    return Material(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementTextAreaRichToolbar,
      ),
      color: barBg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: NorthstarSpacing.space8,
              vertical: 6,
            ),
            child: row,
          ),
          Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ),
    );
  }
}
