import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Call [notifyAuthChanged] after login/logout so [GoRouter] re-runs redirects.
final class AuthNavigationRefreshListenable extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}

final authNavigationRefreshListenableProvider =
    Provider<AuthNavigationRefreshListenable>((Ref ref) {
  final AuthNavigationRefreshListenable listenable =
      AuthNavigationRefreshListenable();
  ref.onDispose(listenable.dispose);
  return listenable;
});
