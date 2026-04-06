import 'package:meta/meta.dart';

/// Read-side contract only. Implementations (Split, Firebase Remote Config,
/// static JSON) live in the host app or a thin `emp_ai_feature_flags_split`
/// package — not in the design system.
@immutable
abstract class FeatureFlagSource {
  const FeatureFlagSource();

  /// Whether the flag is on for the current user/session.
  Future<bool> isEnabled(String key);

  /// Optional string payload for complex flags.
  Future<String?> treatment(String key);
}

/// No-op for tests and local runs.
class NoOpFeatureFlagSource extends FeatureFlagSource {
  const NoOpFeatureFlagSource();

  @override
  Future<bool> isEnabled(String key) async => false;

  @override
  Future<String?> treatment(String key) async => null;
}
