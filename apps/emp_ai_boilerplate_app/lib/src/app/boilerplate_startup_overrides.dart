import 'package:app_links/app_links.dart';
import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/bootstrap/emp_ai_auth_bootstrap.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_auth_config.dart';
import 'package:emp_ai_boilerplate_app/src/shell/deep_link/boilerplate_initial_app_link.dart';
import 'package:emp_ai_boilerplate_app/src/platform/firebase/boilerplate_firebase_bootstrap.dart';
import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared by `main` and integration tests: auth bootstrap, prefs, cold-start
/// URI for `DeepLinkListener`.
Future<List<Override>> loadBoilerplateStartupOverrides() async {
  if (!CachedQuery.instance.isConfigSet) {
    CachedQuery.instance.config(
      config: const GlobalQueryConfig(
        staleDuration: Duration(seconds: 30),
        cacheDuration: Duration(minutes: 10),
      ),
    );
  }
  await bootstrapBoilerplateFirebaseIfEnabled();
  bootstrapEmpAiAuthIfEnabled();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (kBoilerplateEnableAppLinks) {
    try {
      boilerplateInitialAppLink = await AppLinks().getInitialLink();
    } on Object {
      boilerplateInitialAppLink = null;
    }
  }
  return <Override>[
    sharedPreferencesProvider.overrideWithValue(prefs),
  ];
}
