import 'dart:convert';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Serializes a Quill [Document] to a compact HTML fragment (no `<html>` / `<body>`).
///
/// Supports inline styles used by [NorthstarTextArea] rich toolbar: bold, italic,
/// underline, strikethrough, link, color; block: paragraph, h1–h2, blockquote,
/// bullet/ordered lists, text alignment, indent.
String northstarQuillDocumentToHtml(Document document) {
  final List<Operation> ops = document.toDelta().operations;
  final StringBuffer out = StringBuffer();
  final List<({String text, Map<String, dynamic>? attrs})> lineRuns =
      <({String text, Map<String, dynamic>? attrs})>[];
  bool inUl = false;
  bool inOl = false;

  void closeLists() {
    if (inUl) {
      out.write('</ul>');
      inUl = false;
    }
    if (inOl) {
      out.write('</ol>');
      inOl = false;
    }
  }

  String blockOpenTag(Map<String, dynamic>? block) {
    if (block == null) {
      return 'p';
    }
    final dynamic header = block['header'];
    if (header == 1) {
      return 'h1';
    }
    if (header == 2) {
      return 'h2';
    }
    return 'p';
  }

  String blockStyle(Map<String, dynamic>? block) {
    if (block == null) {
      return '';
    }
    final List<String> parts = <String>[];
    final dynamic align = block['align'];
    if (align is String && align.isNotEmpty) {
      parts.add('text-align:${_cssEscape(align)}');
    }
    final dynamic indent = block['indent'];
    if (indent is int && indent > 0) {
      parts.add('margin-left:${indent * 24}px');
    }
    return parts.join(';');
  }

  void flushLine(Map<String, dynamic>? blockAttrs) {
    String content = lineRuns
        .map(
          (({String text, Map<String, dynamic>? attrs}) r) =>
              _inlineToHtml(r.text, r.attrs),
        )
        .join();
    lineRuns.clear();
    if (content.isEmpty) {
      content = '<br>';
    }

    final Map<String, dynamic>? block = blockAttrs;
    final String? listVal = block?['list'] as String?;

    if (listVal == 'bullet') {
      if (!inUl) {
        closeLists();
        out.write('<ul>');
        inUl = true;
      }
      inOl = false;
      out.write('<li>');
      out.write(content);
      out.write('</li>');
      return;
    }
    if (listVal == 'ordered') {
      if (!inOl) {
        closeLists();
        out.write('<ol>');
        inOl = true;
      }
      inUl = false;
      out.write('<li>');
      out.write(content);
      out.write('</li>');
      return;
    }

    closeLists();

    final String tag = blockOpenTag(block);
    final String style = blockStyle(block);
    final String styleAttr = style.isEmpty ? '' : ' style="${_cssEscape(style)}"';
    final bool quote = block?['blockquote'] == true;

    void writeTagged() {
      out.write('<$tag$styleAttr>');
      out.write(content);
      out.write('</$tag>');
    }

    if (quote) {
      out.write('<blockquote>');
      writeTagged();
      out.write('</blockquote>');
    } else {
      writeTagged();
    }
  }

  for (final Operation op in ops) {
    if (!op.isInsert) {
      continue;
    }
    final Object? data = op.data;
    if (data is! String) {
      closeLists();
      out.write('<span data-embed="1"></span>');
      continue;
    }
    final Map<String, dynamic>? attrs = op.attributes;
    if (data == '\n') {
      flushLine(attrs);
      continue;
    }
    final List<String> parts = data.split('\n');
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        lineRuns.add((text: parts[i], attrs: attrs));
      }
      if (i < parts.length - 1) {
        flushLine(null);
      }
    }
  }

  closeLists();
  if (lineRuns.isNotEmpty) {
    flushLine(null);
  }

  return out.toString();
}

String _cssEscape(String s) {
  return s.replaceAll('&', '&amp;').replaceAll('"', '&quot;');
}

String _inlineToHtml(String text, Map<String, dynamic>? attrs) {
  String out = htmlEscape.convert(text);
  if (attrs == null || attrs.isEmpty) {
    return out;
  }
  if (attrs['bold'] == true) {
    out = '<strong>$out</strong>';
  }
  if (attrs['italic'] == true) {
    out = '<em>$out</em>';
  }
  if (attrs['underline'] == true) {
    out = '<u>$out</u>';
  }
  if (attrs['strike'] == true) {
    out = '<s>$out</s>';
  }
  final dynamic link = attrs['link'];
  if (link is String && link.isNotEmpty) {
    final String safe = htmlEscape.convert(link);
    out = '<a href="$safe">$out</a>';
  }
  final dynamic color = attrs['color'];
  if (color is String && color.isNotEmpty) {
    final String c = _cssEscape(color);
    out = '<span style="color:$c">$out</span>';
  }
  return out;
}
