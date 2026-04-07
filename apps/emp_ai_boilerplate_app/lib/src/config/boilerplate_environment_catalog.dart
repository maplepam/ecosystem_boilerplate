import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:flutter/foundation.dart';

/// URLs, titles, and auth **non-secret** settings per [AppBuildFlavor].
///
/// **Template defaults only:** the concrete strings in [BoilerplateEnvironmentCatalog]
/// are **samples** (shaped like the emapta dev stack) so the repo runs out of the
/// box. When you **clone or fork** this boilerplate for a real product, **replace
/// every row** with your own hosts, client ids, redirects, and titles — do not ship
/// these literals to production unless they are intentionally yours.
///
/// Modeled after `emapta/lib/src/main/app_env.dart` (`EnvInfo` maps): one
/// **runtime flavor** (from `--dart-define=FLAVOR` or entrypoint) selects a row.
/// **Secrets** (e.g. `clientSecret`) never belong here — use CI secrets +
/// `--dart-define` or a private override file.
@immutable
class BoilerplateFlavorEndpoints {
  const BoilerplateFlavorEndpoints({
    required this.appTitle,
    required this.apiBaseUrl,
    required this.announcementServiceBaseUrl,
    required this.leaveManagementBaseUrl,
    required this.identityBaseUrl,
    required this.authClientIdMobile,
    required this.authClientIdWeb,
    required this.redirectUrlMobile,
    required this.redirectUrlWeb,
  });

  /// Shown in [MaterialApp.title] when using [boilerplateDisplayTitleProvider].
  final String appTitle;

  /// REST API origin (no trailing slash), e.g. for [ApplicationHostProfile.apiBaseUrl].
  final String apiBaseUrl;

  /// Emapta **announcement BFF** origin (no trailing slash), same role as
  /// `notificationConnectionStringV2` in `announcement_module` / `app_env.dart`
  /// (`…/announcement-bl`). Used for `POST …/announcement/published/list|detail`.
  final String announcementServiceBaseUrl;

  /// Emapta **leave-management** service origin (no trailing slash), same role as
  /// `leaveManagementConnectionString` in `app_env.dart`. Used for
  /// `GET …/lm/v1/employee-assignment/detail/{keycloak_sub}` → `profile_id` for
  /// announcement `recipients`.
  final String leaveManagementBaseUrl;

  /// Keycloak / IdP host prefix (no path), same role as `identityConnectionString` in emapta.
  final String identityBaseUrl;

  /// Passed to [EmpAuth].initialize `clientId` on iOS/Android.
  final String authClientIdMobile;

  /// Passed to [EmpAuth].initialize `clientId` on web.
  final String authClientIdWeb;

  /// OAuth redirect, mobile — emapta uses `redirectUrlString + '/'`.
  final String redirectUrlMobile;

  /// OAuth redirect, web — emapta `redirectUrlWebString`.
  final String redirectUrlWeb;

  String resolveAuthClientId() => kIsWeb ? authClientIdWeb : authClientIdMobile;

  String resolveRedirectUrl() => kIsWeb ? redirectUrlWeb : redirectUrlMobile;

  String get kcAuthenticationUrl => '$identityBaseUrl/auth';
  String get kcAuthorizationUrl => '$identityBaseUrl/authorization';
  String get kcUserUrl => '$identityBaseUrl/user';
}

/// Static catalog — **edit all flavors** after adopting the boilerplate.
abstract final class BoilerplateEnvironmentCatalog {
  const BoilerplateEnvironmentCatalog._();

  /// Values aligned with **emapta** `AppEnvironment` rows in `app_env.dart`.
  static BoilerplateFlavorEndpoints endpointsFor(AppBuildFlavor flavor) {
    return switch (flavor) {
      AppBuildFlavor.development => _development,
      AppBuildFlavor.qa => _qa,
      AppBuildFlavor.staging => _staging,
      AppBuildFlavor.production => _production,
    };
  }

  static const BoilerplateFlavorEndpoints _development =
      BoilerplateFlavorEndpoints(
    appTitle: '[DEV] Boilerplate',
    apiBaseUrl: 'https://dev-api.empowerteams.io',
    announcementServiceBaseUrl:
        'https://api-dev.platform.outsourcingit.com/announcement-bl',
    leaveManagementBaseUrl:
        'https://api-dev.platform.outsourcingit.com/leave-management',
    identityBaseUrl: 'https://api-dev.platform.outsourcingit.com',
    authClientIdMobile: 'EMAPTA-MYEMAPTA',
    authClientIdWeb: 'EMAPTA-MYEMAPTAWEB',
    redirectUrlMobile: 'myemaptahcmdev://authenticate/',
    redirectUrlWeb: 'https://dev-hcm.my.emapta.com/#/callback',
  );

  /// Mirrors emapta **UAT** (`AppEnvironment.uat`).
  static const BoilerplateFlavorEndpoints _qa = BoilerplateFlavorEndpoints(
    appTitle: '[UAT] Boilerplate',
    apiBaseUrl: 'https://dev-api.empowerteams.io',
    announcementServiceBaseUrl:
        'https://api-uat.platform.outsourcingit.com/announcement-bl',
    leaveManagementBaseUrl:
        'https://api-uat.platform.outsourcingit.com/leave-management',
    identityBaseUrl: 'https://api-uat.platform.outsourcingit.com',
    authClientIdMobile: 'EMAPTA-MYEMAPTA',
    authClientIdWeb: 'EMAPTA-MYEMAPTAWEB',
    redirectUrlMobile: 'myemaptahcmuat://authenticate/',
    redirectUrlWeb: 'https://uat-hcm.my.emapta.com/#/callback',
  );

  static const BoilerplateFlavorEndpoints _staging = BoilerplateFlavorEndpoints(
    appTitle: '[STG] Boilerplate',
    apiBaseUrl: 'https://dev-api.empowerteams.io',
    announcementServiceBaseUrl:
        'https://api-staging.platform.emapta.com/announcement-bl',
    leaveManagementBaseUrl:
        'https://api-dryrun.platform.emapta.com/leave-management',
    identityBaseUrl: 'https://api-staging.platform.emapta.com',
    authClientIdMobile: 'EMAPTA-MYEMAPTA',
    authClientIdWeb: 'EMAPTA-MYEMAPTAWEB',
    redirectUrlMobile: 'myemaptahcmstg://authenticate/',
    redirectUrlWeb: 'https://stg-hcm.my.emapta.com/#/callback',
  );

  static const BoilerplateFlavorEndpoints _production =
      BoilerplateFlavorEndpoints(
    appTitle: 'Boilerplate',
    apiBaseUrl: 'https://api.empowerteams.io',
    announcementServiceBaseUrl:
        'https://api.platform.emapta.com/announcement-bl',
    leaveManagementBaseUrl: 'https://api.platform.emapta.com/leave-management',
    identityBaseUrl: 'https://api.platform.emapta.com',
    authClientIdMobile: 'EMAPTA-MYEMAPTA',
    authClientIdWeb: 'EMAPTA-MYEMAPTAWEB',
    redirectUrlMobile: 'myemaptahcm://authenticate/',
    redirectUrlWeb: 'https://hcm.my.emapta.com/#/callback',
  );
}
