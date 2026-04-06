import 'package:emp_ai_auth/features/auth/domain/entities/state/auth_state.dart';
import 'package:emp_ai_auth/features/auth/shared/auth_providers.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/auth_navigation_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Re-run [GoRouter] redirects when `emp_ai_auth` state changes.
final authRefreshBridgeProvider = Provider<void>(
  (ref) {
    ref.listen<AuthState>(
      authNotifierProvider,
      (_, __) =>
          ref.read(authNavigationRefreshListenableProvider).notifyAuthChanged(),
    );
  },
);
