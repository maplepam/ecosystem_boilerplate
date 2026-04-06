import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_paths.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One routable destination (leaf). Used for top-level items and under
/// [ShellNavItemParent].
@immutable
final class ShellNavLeaf {
  const ShellNavLeaf({
    required this.location,
    required this.label,
    required this.icon,
    this.appBarTitle,
  });

  /// Full `GoRouter` location (e.g. [BoilerplateShellPaths.home]).
  final String location;
  final String label;
  final IconData icon;
  final String? appBarTitle;

  String get resolvedAppBarTitle => appBarTitle ?? label;

  /// True when [path] is this route or a deeper segment under it.
  bool matchesPath(String path) {
    if (path == location) {
      return true;
    }
    final String prefix = location.endsWith('/') ? location : '$location/';
    return path.startsWith(prefix);
  }
}

/// Expandable folder: **tap only toggles children** — it never calls `go()`.
/// Children carry the real [ShellNavLeaf.location] values.
@immutable
final class ShellNavParent {
  const ShellNavParent({
    required this.id,
    required this.label,
    required this.icon,
    required this.children,
  });

  /// Stable key for expanded state (e.g. `'hub'`).
  final String id;
  final String label;
  final IconData icon;
  final List<ShellNavLeaf> children;

  bool containsPath(String path) =>
      children.any((ShellNavLeaf c) => c.matchesPath(path));

  ShellNavLeaf? matchingLeaf(String path) {
    for (final ShellNavLeaf c in children) {
      if (c.matchesPath(path)) {
        return c;
      }
    }
    return null;
  }
}

/// Top-level side / bottom bar row: either a routable leaf or an expandable parent.
sealed class ShellNavItem {
  const ShellNavItem();
}

final class ShellNavTopLeaf extends ShellNavItem {
  const ShellNavTopLeaf(this.leaf);
  final ShellNavLeaf leaf;
}

final class ShellNavTopParent extends ShellNavItem {
  const ShellNavTopParent(this.parent);
  final ShellNavParent parent;
}

/// Default shell navigation for the boilerplate super-app.
///
/// Override [boilerplateShellNavConfigProvider] to add/remove groups or routes.
List<ShellNavItem> defaultBoilerplateShellNavItems() {
  return <ShellNavItem>[
    ShellNavTopLeaf(
      ShellNavLeaf(
        location: BoilerplateShellPaths.home,
        label: 'Overview',
        icon: Icons.dashboard_rounded,
      ),
    ),
    ShellNavTopLeaf(
      ShellNavLeaf(
        location: BoilerplateShellPaths.widgets,
        label: 'Components',
        icon: Icons.widgets_rounded,
      ),
    ),
    ShellNavTopLeaf(
      ShellNavLeaf(
        location: BoilerplateShellPaths.theme,
        label: 'Look & feel',
        icon: Icons.palette_rounded,
      ),
    ),
    ShellNavTopParent(
      ShellNavParent(
        id: 'hub',
        label: 'Hub',
        icon: Icons.hub_rounded,
        children: <ShellNavLeaf>[
          ShellNavLeaf(
            location: BoilerplateShellPaths.hubSamples,
            label: 'Samples',
            icon: Icons.science_outlined,
          ),
          ShellNavLeaf(
            location: BoilerplateShellPaths.hubResources,
            label: 'Resources',
            icon: Icons.folder_special_outlined,
          ),
          ShellNavLeaf(
            location: BoilerplateShellPaths.hubAnnouncements,
            label: 'Announcements',
            icon: Icons.campaign_outlined,
          ),
        ],
      ),
    ),
  ];
}

final boilerplateShellNavConfigProvider = Provider<List<ShellNavItem>>(
  (Ref ref) => defaultBoilerplateShellNavItems(),
);

/// Bottom / side **selected** index for [items] and current [path].
int shellNavSelectedIndex(List<ShellNavItem> items, String path) {
  for (int i = 0; i < items.length; i++) {
    final ShellNavItem e = items[i];
    switch (e) {
      case ShellNavTopLeaf(:final ShellNavLeaf leaf):
        if (leaf.matchesPath(path)) {
          return i;
        }
      case ShellNavTopParent(:final ShellNavParent parent):
        if (parent.containsPath(path)) {
          return i;
        }
    }
  }
  return 0;
}

/// App bar title from config, or `null` to fall back (e.g. widget catalog).
String? shellNavAppBarTitle(List<ShellNavItem> items, GoRouterState state) {
  if (state.pathParameters.containsKey('catalogId')) {
    return null;
  }
  final String path = state.uri.path;
  for (final ShellNavItem e in items) {
    switch (e) {
      case ShellNavTopLeaf(:final ShellNavLeaf leaf):
        if (leaf.matchesPath(path)) {
          return leaf.resolvedAppBarTitle;
        }
      case ShellNavTopParent(:final ShellNavParent parent):
        final ShellNavLeaf? hit = parent.matchingLeaf(path);
        if (hit != null) {
          return hit.resolvedAppBarTitle;
        }
    }
  }
  return 'Overview';
}

/// Title when the widget catalog detail route is active.
String shellNavWidgetDetailTitle(GoRouterState state) {
  final String id = state.pathParameters['catalogId']!;
  return findBoilerplateWidgetCatalogEntry(id)?.title ?? 'Component';
}

/// Parent that owns [path] for narrow **segment** UI (e.g. [WideHubSplit]).
ShellNavParent? shellNavParentOwningPath(
    List<ShellNavItem> items, String path) {
  for (final ShellNavItem e in items) {
    if (e is ShellNavTopParent && e.parent.containsPath(path)) {
      return e.parent;
    }
  }
  return null;
}
