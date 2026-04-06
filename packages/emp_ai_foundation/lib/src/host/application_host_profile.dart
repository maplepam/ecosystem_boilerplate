import 'package:meta/meta.dart';

/// Product-specific runtime profile — replace via [Provider] overrides per app
/// (standalone mini-app, super-app host, embedded web shell, etc.).
@immutable
class ApplicationHostProfile {
  const ApplicationHostProfile({
    required this.flavorId,
    this.apiBaseUrl,
    this.enableVerboseLogs = false,
  });

  /// Parsed from `--dart-define=FLAVOR=...` when using [fromEnvironment].
  ///
  /// Map the string to `AppBuildFlavorParser` from `emp_ai_core` in the host
  /// (`development`, `qa`, `staging`, `production`, `dev`, `prod`, …).
  factory ApplicationHostProfile.fromEnvironment() {
    const String flavor = String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'development',
    );
    const String api = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    const bool verbose = bool.fromEnvironment(
      'VERBOSE_LOGS',
      defaultValue: false,
    );
    return ApplicationHostProfile(
      flavorId: flavor,
      apiBaseUrl: api.isEmpty ? null : api.trim(),
      enableVerboseLogs: verbose,
    );
  }

  /// Stable id: `development`, `staging`, `production`, or a white-label key.
  final String flavorId;

  /// Optional REST base (no trailing slash). Host apps map this to Dio/options.
  final String? apiBaseUrl;

  final bool enableVerboseLogs;

  bool get isProduction => flavorId == 'production';
}
