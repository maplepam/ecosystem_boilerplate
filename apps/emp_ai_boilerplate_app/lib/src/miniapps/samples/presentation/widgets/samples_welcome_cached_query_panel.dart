import 'dart:async';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/providers/samples_welcome_query_provider.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Welcome line + refetch using [QueryBuilder] ([cached_query]).
class SamplesWelcomeCachedQueryPanel extends ConsumerWidget {
  const SamplesWelcomeCachedQueryPanel({
    super.key,
    this.layoutLabel,
  });

  /// Optional layout label (e.g. from host feature flags) for demos.
  final String? layoutLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Query<String> q = ref.watch(samplesWelcomeQueryProvider);

    return QueryBuilder<QueryStatus<String>>(
      query: q,
      builder: (BuildContext context, QueryStatus<String> state) {
        return switch (state) {
          QuerySuccess<String>(:final data) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (layoutLabel != null) ...[
                  Chip(label: Text('Layout: $layoutLabel')),
                  const SizedBox(height: NorthstarSpacing.space12),
                ],
                Text(
                  data,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                FilledButton.tonal(
                  onPressed: () {
                    unawaited(q.refetch());
                  },
                  child: const Text('Refetch (cached_query)'),
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to hub'),
                ),
              ],
            ),
          QueryError<String>(:final error) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                const SizedBox(height: NorthstarSpacing.space16),
                FilledButton.tonal(
                  onPressed: () {
                    unawaited(q.refetch());
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to hub'),
                ),
              ],
            ),
          QueryLoading<String>(:final data) when data != null => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                const CircularProgressIndicator(),
              ],
            ),
          _ => const CircularProgressIndicator(),
        };
      },
    );
  }
}
