import 'package:emp_ai_auth/core/shared/utils/general_utils.dart';
import 'package:emp_ai_auth/emp_ai_auth.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_environment_catalog.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/bootstrap/boilerplate_github_pages_logout_url.dart';
import 'package:emp_ai_core/emp_ai_core.dart';

/// Call from [main] before [runApp] to wire Keycloak / OAuth client ids.
///
/// **Precedence**
/// 1. `AUTH_CLIENT_ID` via `--dart-define` → all `AUTH_*` from environment (advanced; see `docs/integrations/environment.md` — Advanced AUTH dart-defines).
/// 2. Else → [BoilerplateEnvironmentCatalog] for [AppBuildFlavorParser.fromEnvironment]
///    (same idea as emapta `EnvInfo` + `FLAVOR` / entrypoint) — **single source of truth** for hosts + client ids.
void bootstrapEmpAiAuthIfEnabled() {
  const String envClientId = String.fromEnvironment(
    'AUTH_CLIENT_ID',
    defaultValue: '',
  );

  if (envClientId.isNotEmpty) {
    const String envLogoutUrl = String.fromEnvironment(
      'AUTH_LOGOUT_URL',
      defaultValue: '',
    );
    EmpAuth().initialize(
      clientId: envClientId,
      clientSecret: const String.fromEnvironment(
        'AUTH_CLIENT_SECRET',
        defaultValue: '',
      ).isEmpty
          ? null
          : const String.fromEnvironment('AUTH_CLIENT_SECRET'),
      kcAuthenticationUrl: const String.fromEnvironment(
        'AUTH_KC_AUTHENTICATION_URL',
      ),
      kcAuthorizationUrl: const String.fromEnvironment(
        'AUTH_KC_AUTHORIZATION_URL',
      ),
      kcUserUrl: const String.fromEnvironment(
        'AUTH_KC_USER_URL',
      ),
      redirectUrl: const String.fromEnvironment(
        'AUTH_REDIRECT_URL',
        defaultValue: '',
      ).isEmpty
          ? null
          : const String.fromEnvironment('AUTH_REDIRECT_URL'),
      logoutUrl: envLogoutUrl.isEmpty
          ? resolveMaplepamGitHubPagesLogoutUrl()
          : envLogoutUrl,
      onSuccessfulAuthentication: (dynamic e) {
        GeneralUtils.isolateDebug(
          '======AUTHENTICATION====== \n ${e.toString()}',
        );
      },
      onSuccessfulLogout: () {
        GeneralUtils.isolateDebug('======LOGOUT======');
      },
    );
    return;
  }

  final BoilerplateFlavorEndpoints catalog =
      BoilerplateEnvironmentCatalog.endpointsFor(
    AppBuildFlavorParser.fromEnvironment(),
  );
  if (catalog.resolveAuthClientId().isEmpty) {
    return;
  }

  EmpAuth().initialize(
    clientId: catalog.resolveAuthClientId(),
    clientSecret: null,
    kcAuthenticationUrl: catalog.kcAuthenticationUrl,
    kcAuthorizationUrl: catalog.kcAuthorizationUrl,
    kcUserUrl: catalog.kcUserUrl,
    redirectUrl: catalog.resolveRedirectUrl(),
    logoutUrl: resolveMaplepamGitHubPagesLogoutUrl(),
    onSuccessfulAuthentication: (dynamic e) {
      GeneralUtils.isolateDebug(
        '======AUTHENTICATION====== \n ${e.toString()}',
      );
    },
    onSuccessfulLogout: () {
      GeneralUtils.isolateDebug('======LOGOUT======');
    },
  );
}

/// `true` when [EmpAuth] was or will be initialized for this build/run.
bool isEmpAiAuthBootstrapConfigured() {
  const String envClientId = String.fromEnvironment(
    'AUTH_CLIENT_ID',
    defaultValue: '',
  );
  if (envClientId.isNotEmpty) {
    return true;
  }
  return BoilerplateEnvironmentCatalog.endpointsFor(
    AppBuildFlavorParser.fromEnvironment(),
  ).resolveAuthClientId().isNotEmpty;
}
