import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/entities/sample_message.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/repositories/samples_repository.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/providers/samples_providers.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cached server-state for the samples welcome line (see `SAMPLES_CACHED_QUERY`).
final samplesWelcomeQueryProvider = Provider<Query<String>>(
  (ref) {
    final SamplesRepository repo = ref.watch(samplesRepositoryProvider);
    return Query<String>(
      key: 'samples_welcome_message',
      queryFn: () async {
        final AppResult<SampleMessage> r = await repo.loadWelcome();
        return r.fold(
          onSuccess: (SampleMessage m) => m.text,
          onFailure: (AppFailure<SampleMessage> f) => throw f,
        );
      },
    );
  },
);
