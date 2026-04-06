import 'package:emp_ai_boilerplate_app/src/platform/feature_flags/boilerplate_feature_flags.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typed host flags (defaults + fields for [isEnabled] / [treatment]).
/// Use this in UI when you need **synchronous** reads; keep
/// [featureFlagSourceProvider] for [MiniAppGate] and generic code.
final boilerplateFeatureFlagsProvider = Provider<BoilerplateFeatureFlags>(
  (ref) => const BoilerplateFeatureFlags(),
);

/// Host [FeatureFlagSource]. Override in tests or [ProviderScope] to swap
/// implementations (e.g. remote config). Defaults: [BoilerplateFeatureFlags].
final featureFlagSourceProvider = Provider<FeatureFlagSource>(
  (ref) => ref.watch(boilerplateFeatureFlagsProvider),
);
