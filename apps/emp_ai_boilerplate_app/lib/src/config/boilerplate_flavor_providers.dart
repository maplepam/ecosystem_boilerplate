import 'package:emp_ai_boilerplate_app/src/config/boilerplate_environment_catalog.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parsed from `--dart-define=FLAVOR` (see [AppBuildFlavorParser]).
final boilerplateBuildFlavorProvider = Provider<AppBuildFlavor>(
  (Ref ref) => AppBuildFlavorParser.fromEnvironment(),
);

/// Endpoints + titles for the current flavor.
final boilerplateFlavorEndpointsProvider = Provider<BoilerplateFlavorEndpoints>(
  (Ref ref) => BoilerplateEnvironmentCatalog.endpointsFor(
    ref.watch(boilerplateBuildFlavorProvider),
  ),
);

/// [MaterialApp.title] / window name.
final boilerplateDisplayTitleProvider = Provider<String>(
  (Ref ref) => ref.watch(boilerplateFlavorEndpointsProvider).appTitle,
);
