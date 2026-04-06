import 'package:flutter/material.dart';

/// Host composes a tree of drawer rows. Navigation vs custom content is data,
/// not separate widgets, so apps can mix routes, nested items, and static rows
/// (e.g. version label) in one list.
sealed class NorthstarDrawerEntry {
  const NorthstarDrawerEntry();
}

/// Single destination — tap navigates to [location] (e.g. `/main/home`).
final class NorthstarDrawerRouteEntry extends NorthstarDrawerEntry {
  const NorthstarDrawerRouteEntry({
    required this.location,
    required this.label,
    this.icon,
    this.selected = false,
  });

  final String location;
  final String label;
  final IconData? icon;
  final bool selected;
}

/// Expandable group; children can be routes or more nesting / custom rows.
final class NorthstarDrawerExpansionEntry extends NorthstarDrawerEntry {
  const NorthstarDrawerExpansionEntry({
    required this.label,
    required this.children,
    this.icon,
    this.initiallyExpanded = false,
  });

  final String label;
  final IconData? icon;
  final List<NorthstarDrawerEntry> children;
  final bool initiallyExpanded;
}

/// Non-navigation row (version, divider copy, toggle, etc.).
final class NorthstarDrawerCustomEntry extends NorthstarDrawerEntry {
  const NorthstarDrawerCustomEntry({required this.builder});

  final WidgetBuilder builder;
}
