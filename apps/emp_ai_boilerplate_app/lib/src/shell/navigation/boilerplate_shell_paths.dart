import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart';
import 'package:emp_ai_core/emp_ai_core.dart';

/// Stable shell URLs for each [AppHostMode] (main mini-app + dev tools).
///
/// Teams: replace route targets in [MainShellHomeScreen] cards with your own
/// product home, deep links, or feature flags — these paths stay the shell contract.
abstract final class BoilerplateShellPaths {
  const BoilerplateShellPaths._();

  static String get _base {
    switch (kBoilerplateHostMode) {
      case AppHostMode.superApp:
        return '/main';
      case AppHostMode.standaloneMiniApp:
        return '';
      case AppHostMode.embeddedMiniApp:
        return '/$kEmbeddedPathPrefix';
    }
  }

  static String _seg(String segment) {
    final String b = _base;
    if (b.isEmpty) {
      return '/$segment';
    }
    return '$b/$segment';
  }

  static String get home => _seg('home');

  static String get theme => _seg('theme');

  static String get widgets => _seg('widgets');

  static String get hub => _seg('hub');

  static String get hubSamples => '$hub/samples';

  static String get hubResources => '$hub/resources';

  static String get hubAnnouncements => '$hub/announcements';

  static String widgetDetail(String catalogId) =>
      '${_seg('widgets')}/$catalogId';

  /// Northstar color ramps & typography (dev route).
  static String get designSystemShowcase {
    switch (kBoilerplateHostMode) {
      case AppHostMode.embeddedMiniApp:
        return '/$kEmbeddedPathPrefix/dev/ds';
      case AppHostMode.superApp:
      case AppHostMode.standaloneMiniApp:
        return '/dev/ds';
    }
  }
}
