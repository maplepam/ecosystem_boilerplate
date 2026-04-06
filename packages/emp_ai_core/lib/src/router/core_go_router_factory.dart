import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_host_mode.dart';

/// Immutable input for building a [GoRouter]. The host supplies routes;
/// this factory only applies host-mode rules (prefix, shell).
@immutable
class CoreRouterConfig {
  const CoreRouterConfig({
    required this.mode,
    required this.routes,
    this.pathPrefix = '',
    this.navigatorKey,
    this.initialLocationOverride,
    this.redirect,
    this.refreshListenable,
    this.observers,
  });

  final AppHostMode mode;

  /// Routes for this product. When [mode] is [AppHostMode.embeddedMiniApp],
  /// these routes are mounted under [effectivePrefix].
  final List<RouteBase> routes;

  /// Super-app segment for this mini-app, e.g. `shop` -> `/shop/...`.
  /// Ignored for [AppHostMode.superApp] and [AppHostMode.standaloneMiniApp].
  final String pathPrefix;

  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialLocationOverride;
  final GoRouterRedirect? redirect;
  final Listenable? refreshListenable;
  final List<NavigatorObserver>? observers;

  String get effectivePrefix {
    switch (mode) {
      case AppHostMode.superApp:
        return '';
      case AppHostMode.standaloneMiniApp:
        return '';
      case AppHostMode.embeddedMiniApp:
        final p = pathPrefix.trim();
        if (p.isEmpty) {
          return '';
        }
        return p.startsWith('/') ? p : '/$p';
    }
  }
}

/// Opinionated [GoRouter] factory — adjust here once for all apps in the org.
abstract final class CoreGoRouterFactory {
  const CoreGoRouterFactory._();

  static GoRouter create(CoreRouterConfig config) {
    final List<RouteBase> built = _withPrefix(
      config.effectivePrefix,
      config.routes,
    );

    final String initial = config.initialLocationOverride ??
        (built.isNotEmpty ? '/' : '/');

    return GoRouter(
      navigatorKey: config.navigatorKey,
      initialLocation: initial,
      routes: built,
      redirect: config.redirect,
      refreshListenable: config.refreshListenable,
      observers: config.observers ?? const <NavigatorObserver>[],
    );
  }

  static List<RouteBase> _withPrefix(String prefix, List<RouteBase> routes) {
    if (prefix.isEmpty) {
      return routes;
    }
    final String segment = prefix.startsWith('/') ? prefix.substring(1) : prefix;
    return <RouteBase>[
      GoRoute(
        path: '/$segment',
        routes: routes,
      ),
    ];
  }
}
