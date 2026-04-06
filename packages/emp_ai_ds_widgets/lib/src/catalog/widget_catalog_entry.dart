import 'package:flutter/widgets.dart';

/// One reusable widget documented for the library page.
class WidgetCatalogEntry {
  const WidgetCatalogEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.preview,
  });

  /// Case-insensitive title order for library lists (merges host + DS entries).
  static int compareByTitle(WidgetCatalogEntry a, WidgetCatalogEntry b) {
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  final String id;
  final String title;
  final String description;

  /// Paste-ready usage (constructor + common parameters).
  final String code;

  /// Visual sample; keep small (e.g. 280×320). Provide [Material] if needed.
  final Widget Function(BuildContext context) preview;
}
