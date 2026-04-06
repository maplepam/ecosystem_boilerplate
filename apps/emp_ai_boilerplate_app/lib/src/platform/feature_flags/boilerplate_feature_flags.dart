import 'package:emp_ai_foundation/emp_ai_foundation.dart';

/// Keys used with [isEnabled] (booleans).
abstract final class BoilerplateFeatureFlagKeys {
  static const String miniappSamples = 'miniapp_samples_enabled';

  /// Samples screen: show an extra “Try layout” button (UI-only demo).
  static const String samplesShowExtrasButton = 'samples_show_extras_button';
}

/// Keys used with [treatment] (string payloads: variants, JSON, etc.).
abstract final class BoilerplateFeatureFlagTreatments {
  /// Values: `compact` | `full` | `experimental` (parse in UI or map to enum).
  static const String samplesDashboardLayout = 'samples_dashboard_layout';
}

/// Static [FeatureFlagSource] for the host: maps string keys to bools and optional
/// [treatment] strings (multi-variant flags).
///
/// Registered via [boilerplateFeatureFlagsProvider] / [featureFlagSourceProvider]
/// in `lib/src/platform/feature_flags/feature_flag_provider.dart`.
///
/// See docs/integrations/feature_flags.md.
final class BoilerplateFeatureFlags extends FeatureFlagSource {
  const BoilerplateFeatureFlags({
    this.samplesMiniAppEnabled = true,
    this.samplesShowExtrasButton = true,
    this.samplesDashboardLayout = 'full',
  });

  /// When false, [SamplesMiniApp] is filtered out via [MiniApp.requiredFeatureFlagKey].
  final bool samplesMiniAppEnabled;

  /// When false, hide the optional button on the Samples demo screen.
  final bool samplesShowExtrasButton;

  /// Layout variant for Samples (`compact`, `full`, `experimental`).
  final String samplesDashboardLayout;

  @override
  Future<bool> isEnabled(String key) async {
    if (key == BoilerplateFeatureFlagKeys.miniappSamples) {
      return samplesMiniAppEnabled;
    }
    if (key == BoilerplateFeatureFlagKeys.samplesShowExtrasButton) {
      return samplesShowExtrasButton;
    }
    return false;
  }

  @override
  Future<String?> treatment(String key) async {
    if (key == BoilerplateFeatureFlagTreatments.samplesDashboardLayout) {
      return samplesDashboardLayout;
    }
    return null;
  }
}
