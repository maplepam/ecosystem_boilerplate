import 'package:emp_ai_boilerplate_app/src/config/boilerplate_experimental_flags.dart';
import 'package:emp_ai_boilerplate_app/src/platform/feature_flags/boilerplate_feature_flags.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/domain/entities/sample_message.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/providers/samples_welcome_notifier.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/samples/presentation/widgets/samples_welcome_cached_query_panel.dart';
import 'package:emp_ai_boilerplate_app/src/platform/feature_flags/feature_flag_provider.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Presentation: [SamplesWelcomeNotifier] by default, or [cached_query] when
/// `SAMPLES_CACHED_QUERY=true`. See `docs/platform/HOST_SERVICES.md`.
///
/// Replace or extend this screen when your product owns the Samples tab.
class SamplesHomeScreen extends ConsumerWidget {
  const SamplesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BoilerplateFeatureFlags flags = ref.watch(
      boilerplateFeatureFlagsProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Samples mini-app'),
        bottom: kSamplesWelcomeUseCachedQuery
            ? const PreferredSize(
                preferredSize: Size.fromHeight(36),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: NorthstarSpacing.space16,
                      bottom: NorthstarSpacing.space8,
                    ),
                    child: Text(
                      'SAMPLES_CACHED_QUERY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(NorthstarSpacing.space24),
          child: kSamplesWelcomeUseCachedQuery
              ? SamplesWelcomeCachedQueryPanel(
                  layoutLabel: flags.samplesDashboardLayout,
                )
              : _SamplesWelcomeNotifierBody(ref: ref),
        ),
      ),
    );
  }
}

class _SamplesWelcomeNotifierBody extends StatelessWidget {
  const _SamplesWelcomeNotifierBody({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SampleMessage> asyncMsg =
        ref.watch(samplesWelcomeNotifierProvider);
    final BoilerplateFeatureFlags flags = ref.watch(
      boilerplateFeatureFlagsProvider,
    );

    return asyncMsg.when(
      data: (SampleMessage msg) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.view_quilt, size: 18),
                label: Text(
                  'Layout: ${flags.samplesDashboardLayout} '
                  '(${BoilerplateFeatureFlagTreatments.samplesDashboardLayout})',
                ),
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          Text(msg.text, textAlign: TextAlign.center),
          const SizedBox(height: NorthstarSpacing.space16),
          FilledButton.tonal(
            onPressed: () =>
                ref.read(samplesWelcomeNotifierProvider.notifier).refresh(),
            child: const Text('Refresh (use case)'),
          ),
          if (flags.samplesShowExtrasButton) ...[
            const SizedBox(height: NorthstarSpacing.space12),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Gated by samples_show_extras_button',
                    ),
                  ),
                );
              },
              child: const Text('Extra action (feature flag)'),
            ),
          ],
          const SizedBox(height: NorthstarSpacing.space16),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Back to home'),
          ),
        ],
      ),
      loading: () => const CircularProgressIndicator(),
      error: (Object e, _) => Text('Error: $e'),
    );
  }
}
