import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/platform/feature_flags/boilerplate_feature_flags.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/samples_home_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Feature-isolated mini-app with domain/data/presentation folders.
final class SamplesMiniApp extends MiniApp {
  SamplesMiniApp();

  @override
  String get id => 'samples';

  @override
  String get displayName => 'Samples';

  @override
  String get entryLocation => '/samples/demo';

  @override
  String? get requiredFeatureFlagKey => BoilerplateFeatureFlagKeys.miniappSamples;

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: 'demo',
          builder: (BuildContext context, GoRouterState state) =>
              const SamplesHomeScreen(),
        ),
      ];
}
