import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';
import 'package:flutter/material.dart';

/// [NavigationBar] destinations derived from [boilerplateShellNavConfigProvider].
List<NavigationDestination> shellNavigationBarDestinations(
  List<ShellNavItem> nav,
) {
  final List<NavigationDestination> out = <NavigationDestination>[];
  for (final ShellNavItem e in nav) {
    switch (e) {
      case ShellNavTopLeaf(:final ShellNavLeaf leaf):
        out.add(
          NavigationDestination(
            icon: Icon(leaf.icon),
            selectedIcon: Icon(leaf.icon),
            label: leaf.label,
          ),
        );
      case ShellNavTopParent(:final ShellNavParent parent):
        out.add(
          NavigationDestination(
            icon: Icon(parent.icon),
            selectedIcon: Icon(parent.icon),
            label: parent.label,
          ),
        );
    }
  }
  return out;
}
