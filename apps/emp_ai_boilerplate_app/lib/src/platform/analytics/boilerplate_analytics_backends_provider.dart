import 'package:emp_ai_boilerplate_app/src/config/boilerplate_experimental_flags.dart';
import 'package:emp_ai_boilerplate_app/src/platform/analytics/firebase_analytics_sink.dart';
import 'package:emp_ai_boilerplate_app/src/platform/analytics/mixpanel_analytics_sink.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Mixpanel + Firebase analytics when enabled via `--dart-define` / define-from-file
/// and platform setup. Safe in tests (init failures are ignored).
final boilerplateRemoteAnalyticsSinksProvider =
    FutureProvider<List<AnalyticsSink>>((Ref ref) async {
  final List<AnalyticsSink> sinks = <AnalyticsSink>[];

  if (kBoilerplateMixpanelToken.isNotEmpty) {
    try {
      final Mixpanel mp = await Mixpanel.init(
        kBoilerplateMixpanelToken,
        trackAutomaticEvents: false,
      );
      sinks.add(MixpanelAnalyticsSink(mp));
    } on Object {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[analytics] Mixpanel init skipped (plugin or config).');
      }
    }
  }

  if (kBoilerplateEnableFirebase && Firebase.apps.isNotEmpty) {
    try {
      sinks.add(FirebaseAnalyticsSink(FirebaseAnalytics.instance));
    } on Object {
      if (kDebugMode) {
        // ignore: avoid_print
        print('[analytics] Firebase Analytics unavailable.');
      }
    }
  }

  return sinks;
});

/// Sync analytics surface for code that cannot await [boilerplateRemoteAnalyticsSinksProvider]
/// (e.g. token refresh). Uses remote sinks when ready, otherwise [DebugPrintAnalyticsSink].
final boilerplateAnalyticsSinkProvider = Provider<AnalyticsSink>(
  (Ref ref) {
    final AsyncValue<List<AnalyticsSink>> async =
        ref.watch(boilerplateRemoteAnalyticsSinksProvider);
    return async.when(
      data: (List<AnalyticsSink> sinks) => sinks.isEmpty
          ? const DebugPrintAnalyticsSink()
          : CompositeAnalyticsSink(sinks),
      loading: () => const DebugPrintAnalyticsSink(),
      error: (_, __) => const DebugPrintAnalyticsSink(),
    );
  },
);
