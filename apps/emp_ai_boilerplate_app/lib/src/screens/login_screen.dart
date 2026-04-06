import 'package:emp_ai_auth/emp_ai_auth.dart';
import 'package:emp_ai_auth/features/auth/domain/entities/state/auth_state.dart';
import 'package:emp_ai_auth/features/auth/shared/auth_providers.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Sign-in: [EmpAuth] + `AuthenticationApp` when configured; otherwise explains
/// missing `AUTH_*` / flavor catalog wiring.
///
/// Honors `?redirect=` from [createRouteAccessRedirect].
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!boilerplateEmpAiAuthRuntimeConfigured()) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sign in')),
        body: const Padding(
          padding: EdgeInsets.all(NorthstarSpacing.space24),
          child: Text(
            'emp_ai_auth is not configured: set AUTH_CLIENT_ID (dart-define) '
            'or flavor catalog client ids — see emp_ai_auth_bootstrap.dart and '
            'docs/integrations/environment.md.',
          ),
        ),
      );
    }

    ref.listen(authNotifierProvider, (AuthState? prev, AuthState next) {
      if (!context.mounted) {
        return;
      }
      bool isAuthed(AuthState s) => s.maybeWhen(
            authenticated: (_) => true,
            successExchangeAuthCode: (_) => true,
            orElse: () => false,
          );
      final bool now = isAuthed(next);
      final bool was = prev != null && isAuthed(prev);
      if (!now || was) {
        return;
      }
      final String? redirect =
          GoRouterState.of(context).uri.queryParameters['redirect'];
      final String fallback = ref.read(authDefaultHomePathProvider);
      context.go(
        redirect != null && redirect.isNotEmpty ? redirect : fallback,
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: EmpAuth().login,
    );
  }
}
