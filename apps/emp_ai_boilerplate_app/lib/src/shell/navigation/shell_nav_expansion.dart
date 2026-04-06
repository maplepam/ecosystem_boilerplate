import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';

/// Owns main-shell **parent expanded** state and “user collapsed while still
/// on child” tracking. Used by [BoilerplateShellScaffold]; no UI.
final class ShellNavExpansionCoordinator {
  Map<String, bool> expanded = <String, bool>{};
  final Set<String> userCollapsedParentIds = <String>{};
  String lastExpansionPath = '';

  ShellNavParent? _parentById(List<ShellNavItem> items, String id) {
    for (final ShellNavItem e in items) {
      if (e is ShellNavTopParent && e.parent.id == id) {
        return e.parent;
      }
    }
    return null;
  }

  /// Call when [path] changes. Returns whether [expanded] was updated.
  bool syncToPath(String path, List<ShellNavItem> items) {
    if (path == lastExpansionPath) {
      return false;
    }
    lastExpansionPath = path;
    userCollapsedParentIds.removeWhere(
      (String id) {
        final ShellNavParent? p = _parentById(items, id);
        return p == null || !p.containsPath(path);
      },
    );
    bool changed = false;
    final Map<String, bool> next = Map<String, bool>.from(expanded);
    for (final ShellNavItem e in items) {
      if (e is ShellNavTopParent) {
        final String id = e.parent.id;
        final bool under = e.parent.containsPath(path);
        final bool open = under && !userCollapsedParentIds.contains(id);
        if (next[id] != open) {
          next[id] = open;
          changed = true;
        }
      }
    }
    if (changed) {
      expanded = next;
    }
    return changed;
  }

  void closeAllParentsInPlace(List<ShellNavItem> items) {
    for (final ShellNavItem e in items) {
      if (e is ShellNavTopParent) {
        expanded[e.parent.id] = false;
      }
    }
    userCollapsedParentIds.clear();
  }

  void toggleParent(String id, List<ShellNavItem> items, String currentPath) {
    final ShellNavParent? p = _parentById(items, id);
    if (p == null) {
      return;
    }
    final bool under = p.containsPath(currentPath);
    final bool wasOpen = expanded[id] ?? false;
    expanded[id] = !wasOpen;
    if (under) {
      if (wasOpen) {
        userCollapsedParentIds.add(id);
      } else {
        userCollapsedParentIds.remove(id);
      }
    }
  }

  void prepareLeafNavigation(
    ShellNavParent? owningParent,
    List<ShellNavItem> items,
  ) {
    if (owningParent != null) {
      expanded[owningParent.id] = true;
      userCollapsedParentIds.remove(owningParent.id);
    } else {
      closeAllParentsInPlace(items);
    }
  }

  void openParentForDrawer(String id) {
    expanded[id] = true;
    userCollapsedParentIds.remove(id);
  }
}
