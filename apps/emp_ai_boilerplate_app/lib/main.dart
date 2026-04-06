import 'package:emp_ai_boilerplate_app/src/app/boilerplate_app.dart';
import 'package:emp_ai_boilerplate_app/src/app/boilerplate_startup_overrides.dart';
import 'package:emp_ai_boilerplate_app/src/platform/url_strategy_stub.dart'
    if (dart.library.html) 'package:emp_ai_boilerplate_app/src/platform/url_strategy_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  configureBoilerplateUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  final List<Override> overrides = await loadBoilerplateStartupOverrides();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const BoilerplateApp(),
    ),
  );
}
