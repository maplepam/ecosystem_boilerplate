import 'package:meta/meta.dart';

/// Build / deployment tier (dart-define `FLAVOR` or CI matrix).
///
/// Map each value to API hosts in the host app — this enum stays generic.
enum AppBuildFlavor {
  development,
  qa,
  staging,
  production,
}

/// Parse `FLAVOR` strings like `dev`, `qa`, `staging`, `prod`, `production`.
@immutable
abstract final class AppBuildFlavorParser {
  const AppBuildFlavorParser._();

  static AppBuildFlavor parse(String raw) {
    final String s = raw.trim().toLowerCase();
    return switch (s) {
      'development' || 'dev' => AppBuildFlavor.development,
      'qa' || 'test' => AppBuildFlavor.qa,
      'staging' || 'stage' || 'stg' => AppBuildFlavor.staging,
      'production' || 'prod' => AppBuildFlavor.production,
      _ => AppBuildFlavor.development,
    };
  }

  static AppBuildFlavor fromEnvironment() {
    const String v = String.fromEnvironment(
      'FLAVOR',
      defaultValue: 'development',
    );
    return parse(v);
  }
}
