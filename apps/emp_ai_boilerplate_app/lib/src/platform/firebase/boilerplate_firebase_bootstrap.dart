import 'package:emp_ai_boilerplate_app/src/config/boilerplate_experimental_flags.dart';
import 'package:firebase_core/firebase_core.dart';

/// Initializes Firebase when `ENABLE_FIREBASE=true`. Swallows errors so the
/// boilerplate runs without `google-services` / `GoogleService-Info.plist`
/// until the host runs `flutterfire configure`.
Future<void> bootstrapBoilerplateFirebaseIfEnabled() async {
  if (!kBoilerplateEnableFirebase) {
    return;
  }
  if (Firebase.apps.isNotEmpty) {
    return;
  }
  try {
    await Firebase.initializeApp();
  } on Object {
    // Host must add Firebase options and native config files.
  }
}
