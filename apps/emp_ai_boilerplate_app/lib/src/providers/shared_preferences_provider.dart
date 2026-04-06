import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loaded in [main] and overridden with [ProviderScope].
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError(
    'Load SharedPreferences in main() and override sharedPreferencesProvider.',
  ),
);
