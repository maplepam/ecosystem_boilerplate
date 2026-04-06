import 'package:flutter/foundation.dart';

/// Tiny surface so packages avoid scattering `kIsWeb` / `dart:io` checks.
enum AppPlatformKind { web, ios, android, macos, windows, linux, unknown }

/// Resolved once at app start-up; defaults to [kIsWeb] ? web : unknown unless
/// the host calls [overrideKind].
abstract final class RuntimeAppPlatform {
  static AppPlatformKind _kind = _resolveDefault();

  static AppPlatformKind get kind => _kind;

  static void overrideKind(AppPlatformKind value) {
    _kind = value;
  }

  static AppPlatformKind _resolveDefault() {
    if (kIsWeb) {
      return AppPlatformKind.web;
    }
    return AppPlatformKind.unknown;
  }
}
