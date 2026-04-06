import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Paths that skip RBAC (login at `/` and `/login`, unauthorized, dev tools). Dev
/// prefix matches embedded
/// layout (`/$kEmbeddedPathPrefix/dev/...`).
final boilerplatePublicPathsProvider = Provider<List<String>>((ref) {
  final String login = ref.watch(authLoginPathProvider);
  final String unauthorized = ref.watch(authUnauthorizedPathProvider);
  final String devPrefix = switch (kBoilerplateHostMode) {
    AppHostMode.embeddedMiniApp => '/$kEmbeddedPathPrefix/dev',
    AppHostMode.superApp || AppHostMode.standaloneMiniApp => '/dev',
  };
  return <String>[
    login,
    unauthorized,
    '/',
    '/samples',
    devPrefix,
  ];
});
