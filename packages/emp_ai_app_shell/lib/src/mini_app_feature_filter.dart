import 'package:emp_ai_foundation/emp_ai_foundation.dart';

import 'mini_app.dart';

/// Returns mini-apps that pass feature-flag gating (null key = always on).
Future<List<MiniApp>> filterMiniAppsByFeatureFlags(
  List<MiniApp> all,
  FeatureFlagSource flags,
) async {
  final List<MiniApp> out = <MiniApp>[];
  for (final MiniApp app in all) {
    final String? key = app.requiredFeatureFlagKey;
    if (key == null || await flags.isEnabled(key)) {
      out.add(app);
    }
  }
  return out;
}
