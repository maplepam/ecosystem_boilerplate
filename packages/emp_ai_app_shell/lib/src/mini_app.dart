import 'package:go_router/go_router.dart';

/// Contract for a feature team–owned module (mini-app) in a super-app.
///
/// Compare: plugin-style registration in
/// `flutter_superapp_boilerplate` — same idea, with an explicit [entryLocation]
/// for deep links and hub navigation.
abstract class MiniApp {
  /// URL segment and [GoRoute.name], e.g. `auth`, `rewards`.
  String get id;

  String get displayName;

  /// First screen to open from a launcher (e.g. `/auth`, `/main/home`).
  String get entryLocation;

  /// Child routes only; the shell mounts this list under `/[id]/` when using
  /// [MiniAppMountStrategy.nestedUnderId].
  List<RouteBase> get routes;

  /// When non-null, the host should hide this mini-app unless the configured
  /// feature-flag source enables this key.
  String? get requiredFeatureFlagKey;
}

/// Mixin for mini-apps that are not gated by a flag.
mixin MiniAppAlwaysOn on MiniApp {
  @override
  String? get requiredFeatureFlagKey => null;
}
