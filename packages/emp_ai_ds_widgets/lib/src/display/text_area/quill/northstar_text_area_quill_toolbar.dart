import 'package:flutter_quill/flutter_quill.dart';

bool _isToggleOn(QuillController c, Attribute attr) {
  final Map<String, Attribute> attrs = c.getSelectionStyle().attributes;
  if (attr.key == Attribute.list.key ||
      attr.key == Attribute.header.key ||
      attr.key == Attribute.script.key ||
      attr.key == Attribute.align.key) {
    final Attribute? a = attrs[attr.key];
    if (a == null) {
      return false;
    }
    return a.value == attr.value;
  }
  return attrs.containsKey(attr.key);
}

void _toggleFormat(QuillController c, Attribute attr) {
  final bool on = _isToggleOn(c, attr);
  c.formatSelection(
    on ? Attribute.clone(attr, null) : attr,
  );
}

void _clearFormatting(QuillController c) {
  final List<Style> styles = c.getAllSelectionStyles();
  final Set<Attribute> attributes = <Attribute>{};
  for (final Style style in styles) {
    for (final Attribute attr in style.attributes.values) {
      attributes.add(attr);
    }
  }
  for (final Attribute attribute in attributes) {
    c.formatSelection(Attribute.clone(attribute, null));
  }
}

/// Applies [NorthstarTextAreaRichToolbar] action [id] to [controller].
void applyNorthstarRichToolbarToQuill(
  QuillController controller,
  String id, {
  required bool applyEdits,
}) {
  if (!applyEdits) {
    return;
  }
  switch (id) {
    case 'undo':
      controller.undo();
      return;
    case 'redo':
      controller.redo();
      return;
    case 'more':
    case 'color':
    case 'link':
      return;
    case 'bold':
      _toggleFormat(controller, Attribute.bold);
      return;
    case 'italic':
      _toggleFormat(controller, Attribute.italic);
      return;
    case 'underline':
      _toggleFormat(controller, Attribute.underline);
      return;
    case 'strikethrough':
      _toggleFormat(controller, Attribute.strikeThrough);
      return;
    case 'bullet':
      _toggleFormat(controller, Attribute.ul);
      return;
    case 'numbered':
      _toggleFormat(controller, Attribute.ol);
      return;
    case 'style_normal':
      controller.formatSelection(Attribute.header);
      controller.formatSelection(Attribute.clone(Attribute.list, null));
      controller.formatSelection(Attribute.clone(Attribute.blockQuote, null));
      return;
    case 'style_h1':
      controller.formatSelection(Attribute.h1);
      return;
    case 'style_h2':
      controller.formatSelection(Attribute.h2);
      return;
    case 'style_quote':
      controller.formatSelection(Attribute.blockQuote);
      return;
    case 'align_left':
      controller.formatSelection(Attribute.leftAlignment);
      return;
    case 'align_center':
      controller.formatSelection(Attribute.centerAlignment);
      return;
    case 'align_right':
      controller.formatSelection(Attribute.rightAlignment);
      return;
    case 'align_justify':
      controller.formatSelection(Attribute.justifyAlignment);
      return;
    case 'indent':
      controller.indentSelection(true);
      return;
    case 'outdent':
      controller.indentSelection(false);
      return;
    case 'clear':
      _clearFormatting(controller);
      return;
    default:
      return;
  }
}
