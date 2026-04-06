import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/miniapp_catalog.dart';

/// **Single merge point** for all [MiniApp] instances the super-app loads.
///
/// ## Onboarding an external Dart package (submodule or separate repo)
///
/// 1. Add the dependency in `pubspec.yaml` (`path:` or `git:`).
/// 2. Import that package’s **registration** library (exact name from the team):
///    `import 'package:<package_name>/<package_name>_miniapp_registration.dart';`
/// 3. Append `...<packageName>MiniappRegistrations` to the list below.
///
/// ## Onboarding a WebView-only partner
///
/// Import `hosted_web_miniapp.dart` and add a [HostedWebMiniApp] entry (see
/// [docs/engineering/miniapp_packages_and_extract.md]).
///
/// **Do not** edit `miniapp_catalog.g.dart` (codegen). [MiniAppGate] reads this list, not [kAllMiniApps] alone.
///
/// Copy-paste when onboarding:
/// `import 'package:emp_ai_boilerplate_app/src/miniapps/webview_shell/hosted_web_miniapp.dart';`
/// `import 'package:<your_package>/<your_package>_miniapp_registration.dart';`

List<MiniApp> get kHostMiniAppsCatalog => <MiniApp>[
      ...kAllMiniApps,
      // ...acmeLeaveMiniappRegistrations,
      // HostedWebMiniApp(
      //   id: 'partner_portal',
      //   displayName: 'Partner portal',
      //   initialUrl: Uri.parse('https://example.com/app'),
      // ),
    ];
