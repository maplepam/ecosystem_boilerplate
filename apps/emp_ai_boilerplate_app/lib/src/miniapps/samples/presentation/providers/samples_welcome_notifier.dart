import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/entities/sample_message.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/providers/samples_providers.dart';
import 'package:emp_ai_boilerplate_app/src/platform/analytics/observability_providers.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Presentation controller: calls [SamplesRepository] only (no Dio / DB).
final class SamplesWelcomeNotifier extends AsyncNotifier<SampleMessage> {
  @override
  Future<SampleMessage> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<SampleMessage> _load() async {
    final AppResult<SampleMessage> result =
        await ref.read(samplesRepositoryProvider).loadWelcome();
    return switch (result) {
      AppSuccess(:final value) => value,
      final AppFailure<SampleMessage> failure => _reportAndThrow(failure),
    };
  }

  Never _reportAndThrow(AppFailure<SampleMessage> failure) {
    final CrashReportingSink crash = ref.read(crashReportingSinkProvider);
    crash.log('samples_welcome_failed: ${failure.code}');
    final Object? cause = failure.cause;
    if (cause != null) {
      crash.recordError(
        cause,
        StackTrace.current,
        reason: failure.message,
      );
    }
    throw failure;
  }
}

final samplesWelcomeNotifierProvider =
    AsyncNotifierProvider<SamplesWelcomeNotifier, SampleMessage>(
  SamplesWelcomeNotifier.new,
);
