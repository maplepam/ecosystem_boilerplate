import 'package:emp_ai_boilerplate_app/src/config/boilerplate_flavor_providers.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Host profile: **flavor catalog** + optional overrides.
///
/// - `FLAVOR` → [AppBuildFlavor] → [BoilerplateEnvironmentCatalog] (`apiBaseUrl`).
/// - Non-empty `--dart-define=API_BASE_URL` **overrides** the catalog (CI-friendly).
/// - `VERBOSE_LOGS` still from environment.
///
/// For tests, override [applicationHostProfileProvider] or [boilerplateBuildFlavorProvider].
final applicationHostProfileProvider = Provider<ApplicationHostProfile>(
  (Ref ref) {
    const String apiOverride = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    const bool verbose = bool.fromEnvironment(
      'VERBOSE_LOGS',
      defaultValue: false,
    );
    final String catalogApi =
        ref.watch(boilerplateFlavorEndpointsProvider).apiBaseUrl;
    final String flavorId =
        ref.watch(boilerplateBuildFlavorProvider).name;
    return ApplicationHostProfile(
      flavorId: flavorId,
      apiBaseUrl: apiOverride.trim().isEmpty
          ? catalogApi
          : apiOverride.trim(),
      enableVerboseLogs: verbose,
    );
  },
);
