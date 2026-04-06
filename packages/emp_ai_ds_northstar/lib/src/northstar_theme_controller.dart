import 'package:flutter/material.dart';

/// Host-owned brightness preference for [MaterialApp.themeMode]. Works without
/// Riverpod: pass [Listenable.merge] or [ListenableBuilder] around your app
/// root, or wrap this in a `Provider` in the host app.
///
/// Does not persist — add `shared_preferences` in the host if you need that.
class NorthstarThemeModeController extends ChangeNotifier {
  NorthstarThemeModeController([ThemeMode initial = ThemeMode.system])
      : _mode = initial;

  ThemeMode _mode;

  ThemeMode get themeMode => _mode;

  set themeMode(ThemeMode value) {
    if (_mode == value) {
      return;
    }
    _mode = value;
    notifyListeners();
  }

  /// Cycles system → light → dark → system.
  void cycleThemeMode() {
    themeMode = switch (_mode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }
}
