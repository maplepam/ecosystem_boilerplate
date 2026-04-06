import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Optional user-chosen primary seed (persisted). Merged into [NorthstarBranding.seedColor].
final userAccentSeedNotifierProvider =
    NotifierProvider<UserAccentSeedNotifier, Color?>(
  UserAccentSeedNotifier.new,
);

final class UserAccentSeedNotifier extends Notifier<Color?> {
  static const String _prefsKey = 'boilerplate_user_accent_argb';

  @override
  Color? build() {
    final int? v = ref.watch(sharedPreferencesProvider).getInt(_prefsKey);
    if (v == null) {
      return null;
    }
    return Color(v);
  }

  Future<void> setSeed(Color color) async {
    // ignore: deprecated_member_use
    final int argb = color.value;
    await ref.read(sharedPreferencesProvider).setInt(_prefsKey, argb);
    state = color;
  }

  Future<void> clear() async {
    await ref.read(sharedPreferencesProvider).remove(_prefsKey);
    state = null;
  }
}
