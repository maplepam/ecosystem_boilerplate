import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'mini_app.dart';

/// Below this width, mini-apps use [NavigationBar]. At or above, a slim
/// hover-expand rail replaces the bottom bar (pairs with demo shell side nav).
const double kSuperAppShellWideBreakpoint = 840;

/// [NavigationBar] on narrow viewports; hover-expand rail on wide — one tab per
/// registered mini-app branch (same order as [StatefulShellRoute] branches).
///
/// Set [showMiniAppRail] to false to hide the outer Apps rail / bottom bar and
/// let the host (e.g. main shell + Hub) own navigation.
class SuperAppStatefulShellScaffold extends StatelessWidget {
  const SuperAppStatefulShellScaffold({
    super.key,
    required this.navigationShell,
    required this.miniApps,
    this.showMiniAppRail = true,
  });

  final StatefulNavigationShell navigationShell;
  final List<MiniApp> miniApps;

  /// When false, only [navigationShell] is shown (full width). Mini-app
  /// switching uses routes (e.g. `/announcements/home`) or in-app links.
  final bool showMiniAppRail;

  @override
  Widget build(BuildContext context) {
    assert(
      miniApps.length == navigationShell.route.branches.length,
      'Branch count (${navigationShell.route.branches.length}) must match '
      'enabled mini-apps (${miniApps.length})',
    );

    if (!showMiniAppRail) {
      return Scaffold(
        body: navigationShell,
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useWideRail =
            constraints.maxWidth >= kSuperAppShellWideBreakpoint;

        if (!useWideRail) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (int index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: miniApps
                  .map(
                    (MiniApp a) => NavigationDestination(
                      icon: const Icon(Icons.apps_outlined),
                      selectedIcon: const Icon(Icons.apps),
                      label: a.displayName,
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        }

        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _MiniAppHoverRail(
                miniApps: miniApps,
                selectedIndex: navigationShell.currentIndex,
                onSelect: (int index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              ),
              const VerticalDivider(width: 1),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
    );
  }
}

class _MiniAppHoverRail extends StatefulWidget {
  const _MiniAppHoverRail({
    required this.miniApps,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<MiniApp> miniApps;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  State<_MiniAppHoverRail> createState() => _MiniAppHoverRailState();
}

class _MiniAppHoverRailState extends State<_MiniAppHoverRail> {
  static const double _collapsed = 72;
  static const double _expanded = 208;

  bool _hovered = false;
  Timer? _collapseTimer;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _expand() {
    _collapseTimer?.cancel();
    setState(() => _hovered = true);
  }

  void _scheduleCollapse() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _hovered = false);
      }
    });
  }

  IconData _iconFor(int index) {
    if (widget.miniApps.length <= 2) {
      return index == 0
          ? Icons.dashboard_customize_outlined
          : Icons.science_outlined;
    }
    return Icons.apps_outlined;
  }

  IconData _selectedIconFor(int index) {
    if (widget.miniApps.length <= 2) {
      return index == 0
          ? Icons.dashboard_customize_rounded
          : Icons.science_rounded;
    }
    return Icons.apps;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double w = _hovered ? _expanded : _collapsed;

    return MouseRegion(
      onEnter: (_) => _expand(),
      onExit: (_) => _scheduleCollapse(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: w,
        color: scheme.surfaceContainerLow,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            right: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (_hovered)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      child: Text(
                        'Apps',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  for (int i = 0; i < widget.miniApps.length; i++)
                    _RailDestination(
                      expanded: _hovered,
                      selected: widget.selectedIndex == i,
                      icon: _iconFor(i),
                      selectedIcon: _selectedIconFor(i),
                      label: widget.miniApps[i].displayName,
                      onTap: () => widget.onSelect(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailDestination extends StatelessWidget {
  const _RailDestination({
    required this.expanded,
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool expanded;
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.55)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: expanded
                ? Row(
                    children: <Widget>[
                      Icon(
                        selected ? selectedIcon : icon,
                        size: 22,
                        color:
                            selected ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ],
                  )
                : Tooltip(
                    message: label,
                    child: Center(
                      child: Icon(
                        selected ? selectedIcon : icon,
                        size: 22,
                        color:
                            selected ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
