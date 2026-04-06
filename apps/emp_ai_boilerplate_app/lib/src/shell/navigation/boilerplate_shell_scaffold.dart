import 'dart:async';

import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_sign_out_dialog.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_nav_config.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/shell_nav_bottom_destinations.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/shell_nav_expansion.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_mobile_drawer_nav.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/widgets/shell_web_side_nav.dart';
import 'package:emp_ai_boilerplate_app/src/theme/northstar_theme_mode_provider.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart' show AuthSnapshot;
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wide: full-height **side rail** (hover-expand); the **title bar** only spans
/// the content column to the right of the rail (not above the rail). Narrow:
/// [NavigationBar] or [Drawer] for those routes — matches
/// [kSuperAppShellWideBreakpoint] so mini-app chrome stays consistent.
///
/// Side / drawer / bottom destinations come from [boilerplateShellNavConfigProvider].
/// [ShellNavTopParent] rows **only** expand or collapse; they never call `go()`.
///
/// **Structure:** UI pieces live under `navigation/widgets/`; parent expansion
/// state in [ShellNavExpansionCoordinator] (`shell_nav_expansion.dart`).
class BoilerplateShellScaffold extends ConsumerStatefulWidget {
  const BoilerplateShellScaffold({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<BoilerplateShellScaffold> createState() =>
      _BoilerplateShellScaffoldState();
}

class _BoilerplateShellScaffoldState
    extends ConsumerState<BoilerplateShellScaffold> {
  static const double _collapsedNav = 72;
  static const double _expandedNav = 280;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ShellNavExpansionCoordinator _expansion =
      ShellNavExpansionCoordinator();

  bool _sideNavHovered = false;
  Timer? _collapseTimer;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _expandSideNav() {
    _collapseTimer?.cancel();
    setState(() => _sideNavHovered = true);
  }

  void _scheduleSideNavCollapse() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() => _sideNavHovered = false);
      }
    });
  }

  void _goToLeaf(
    ShellNavLeaf leaf,
    ShellNavParent? owningParent,
    List<ShellNavItem> items,
  ) {
    setState(() {
      _expansion.prepareLeafNavigation(owningParent, items);
    });
    GoRouter.of(context).go(leaf.location);
  }

  void _onBottomDestination(
    int index,
    List<ShellNavItem> items,
    String path,
  ) {
    if (index < 0 || index >= items.length) {
      return;
    }
    final ShellNavItem item = items[index];
    switch (item) {
      case ShellNavTopLeaf(:final ShellNavLeaf leaf):
        _goToLeaf(leaf, null, items);
      case ShellNavTopParent(:final ShellNavParent parent):
        setState(() {
          _expansion.openParentForDrawer(parent.id);
        });
        _scaffoldKey.currentState?.openDrawer();
    }
  }

  String _title(GoRouterState state, List<ShellNavItem> nav) {
    if (state.pathParameters.containsKey('catalogId')) {
      return shellNavWidgetDetailTitle(state);
    }
    return shellNavAppBarTitle(nav, state) ?? 'Overview';
  }

  @override
  Widget build(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String path = state.uri.path;
    final List<ShellNavItem> nav = ref.watch(boilerplateShellNavConfigProvider);
    final int navIndex = shellNavSelectedIndex(nav, path);

    if (path != _expansion.lastExpansionPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (_expansion.syncToPath(path, nav)) {
          setState(() {});
        }
      });
    }

    final bool isWidgetDetail = state.pathParameters.containsKey('catalogId');
    final NorthstarThemeModeController themeCtrl =
        ref.watch(northstarThemeModeControllerProvider);
    final AuthSnapshot auth = ref.watch(boilerplateAuthSnapshotProvider);
    final String loginPath = ref.watch(authLoginPathProvider);
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);

    final List<Widget> appBarActions = <Widget>[
      if (!isWidgetDetail) ...<Widget>[
        IconButton(
          tooltip: 'Cycle light · dark · system',
          onPressed: themeCtrl.cycleThemeMode,
          icon: Icon(
            switch (themeCtrl.themeMode) {
              ThemeMode.dark => Icons.dark_mode_rounded,
              ThemeMode.light => Icons.light_mode_rounded,
              ThemeMode.system => Icons.brightness_auto_rounded,
            },
          ),
        ),
        TextButton(
          onPressed: () async {
            if (auth.isAuthenticated) {
              await showBoilerplateSignOutDialog(context, ref);
            } else {
              GoRouter.of(context).go(loginPath);
            }
          },
          child: Text(auth.isAuthenticated ? 'Sign out' : 'Sign in'),
        ),
      ],
    ];

    final bool avoidBottomBarStack =
        kBoilerplateHostMode == AppHostMode.superApp &&
            kSuperAppUseStatefulShell &&
            kSuperAppShowMiniAppRail;

    final bool navHasParents =
        nav.any((ShellNavItem e) => e is ShellNavTopParent);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useWideSideNav =
            constraints.maxWidth >= kSuperAppShellWideBreakpoint;

        if (useWideSideNav) {
          final double navW = _sideNavHovered ? _expandedNav : _collapsedNav;

          return SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                MouseRegion(
                  onEnter: (_) => _expandSideNav(),
                  onExit: (_) => _scheduleSideNavCollapse(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: navW,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: tokens.surfaceContainerLow,
                    ),
                    child: ShellWebSideNav(
                      expanded: _sideNavHovered,
                      tokens: tokens,
                      items: nav,
                      shellPath: path,
                      parentExpanded: _expansion.expanded,
                      onLeaf: (ShellNavLeaf leaf, ShellNavParent? parent) =>
                          _goToLeaf(leaf, parent, nav),
                      onParentToggle: (String id) {
                        setState(() {
                          _expansion.toggleParent(id, nav, path);
                        });
                      },
                    ),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: tokens.outlineVariant,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (!isWidgetDetail)
                        Material(
                          elevation: 0,
                          color: tokens.surface,
                          child: SizedBox(
                            height: kToolbarHeight,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: NorthstarSpacing.space16,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        _title(state, nav),
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: tokens.onSurface,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                ...appBarActions,
                                const SizedBox(width: NorthstarSpacing.space8),
                              ],
                            ),
                          ),
                        ),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (avoidBottomBarStack) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: isWidgetDetail
                ? null
                : AppBar(
                    title: Text(_title(state, nav)),
                    actions: appBarActions,
                  ),
            drawer: isWidgetDetail
                ? null
                : Drawer(
                    child: ShellMobileDrawerNav(
                      items: nav,
                      currentPath: path,
                      parentExpanded: _expansion.expanded,
                      onLeaf: (ShellNavLeaf leaf, ShellNavParent? parent) {
                        Navigator.of(context).pop();
                        _goToLeaf(leaf, parent, nav);
                      },
                      onParentToggle: (String id) {
                        setState(() {
                          _expansion.toggleParent(id, nav, path);
                        });
                      },
                    ),
                  ),
            body: widget.child,
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: isWidgetDetail
              ? null
              : AppBar(
                  title: Text(_title(state, nav)),
                  actions: appBarActions,
                ),
          drawer: isWidgetDetail || !navHasParents
              ? null
              : Drawer(
                  child: ShellMobileDrawerNav(
                    items: nav,
                    currentPath: path,
                    parentExpanded: _expansion.expanded,
                    onLeaf: (ShellNavLeaf leaf, ShellNavParent? parent) {
                      Navigator.of(context).pop();
                      _goToLeaf(leaf, parent, nav);
                    },
                    onParentToggle: (String id) {
                      setState(() {
                        _expansion.toggleParent(id, nav, path);
                      });
                    },
                  ),
                ),
          body: widget.child,
          bottomNavigationBar: isWidgetDetail
              ? null
              : NavigationBar(
                  selectedIndex: navIndex,
                  onDestinationSelected: (int i) =>
                      _onBottomDestination(i, nav, path),
                  destinations: shellNavigationBarDestinations(nav),
                ),
        );
      },
    );
  }
}
