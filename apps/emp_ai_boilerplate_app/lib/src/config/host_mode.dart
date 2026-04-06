import 'package:emp_ai_core/emp_ai_core.dart';

/// Flip this when prototyping how the same module mounts in the super-app.
///
/// - [AppHostMode.superApp]: public **login** at `/` (same as `/login` UX),
///   launcher hub at `/hub`,
///   [MiniApp]s under `/main/...`, `/announcements/...`, etc. (see
///   `miniapp_catalog.dart`).
/// - [AppHostMode.standaloneMiniApp]: single mini-product at `/home`.
/// - [AppHostMode.embeddedMiniApp]: tree mounted under `/[kEmbeddedPathPrefix]/`.
const AppHostMode kBoilerplateHostMode = AppHostMode.superApp;

/// When true, super-app uses [StatefulShellRoute] + bottom [NavigationBar] for
/// mini-app branches. When false, flat [GoRoute] tree (hub + segments only).
const bool kSuperAppUseStatefulShell = true;

/// When false, the outer **Apps** rail (and mini-app [NavigationBar] on narrow)
/// is hidden; use the main shell + Hub for Samples / Resources / Announcements.
/// Deep links to `/announcements/...`, `/samples/...`, etc. still work.
const bool kSuperAppShowMiniAppRail = false;

/// Used only when [kBoilerplateHostMode] is [AppHostMode.embeddedMiniApp].
const String kEmbeddedPathPrefix = 'demo';
