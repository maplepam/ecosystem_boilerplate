import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Override or replace with persisted theme (e.g. `shared_preferences`).
final northstarThemeModeControllerProvider =
    Provider<NorthstarThemeModeController>((ref) {
  final NorthstarThemeModeController controller = NorthstarThemeModeController();
  ref.onDispose(controller.dispose);
  return controller;
});
