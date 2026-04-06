import 'package:emp_ai_boilerplate_app/src/config/application_host_profile_provider.dart';
import 'package:emp_ai_boilerplate_app/src/platform/analytics/boilerplate_analytics_backends_provider.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AnalyticsSink _composeAnalyticsSink({
  required ApplicationHostProfile profile,
  required List<AnalyticsSink> remote,
}) {
  final List<AnalyticsSink> parts = <AnalyticsSink>[
    if (profile.enableVerboseLogs) const DebugPrintAnalyticsSink(),
    ...remote,
  ];
  if (parts.isEmpty) {
    return const NoOpAnalyticsSink();
  }
  if (parts.length == 1) {
    return parts.single;
  }
  return CompositeAnalyticsSink(parts);
}

/// Console when `VERBOSE_LOGS` / [ApplicationHostProfile.enableVerboseLogs];
/// plus Mixpanel (`MIXPANEL_TOKEN`) and Firebase when enabled — see
/// `boilerplate_experimental_flags.dart` and `docs/platform/HOST_SERVICES.md`.
final analyticsSinkProvider = Provider<AnalyticsSink>(
  (ref) {
    final ApplicationHostProfile profile =
        ref.watch(applicationHostProfileProvider);
    final AsyncValue<List<AnalyticsSink>> remote =
        ref.watch(boilerplateRemoteAnalyticsSinksProvider);
    return remote.when(
      data: (List<AnalyticsSink> sinks) =>
          _composeAnalyticsSink(profile: profile, remote: sinks),
      loading: () => _composeAnalyticsSink(profile: profile, remote: const []),
      error: (_, __) =>
          _composeAnalyticsSink(profile: profile, remote: const []),
    );
  },
);

/// Replace with Crashlytics / Sentry in production hosts.
final crashReportingSinkProvider = Provider<CrashReportingSink>(
  (ref) => const NoOpCrashReportingSink(),
);
