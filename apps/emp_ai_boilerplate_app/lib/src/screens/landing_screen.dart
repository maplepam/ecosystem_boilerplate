import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Public entry: marketing-style welcome and **Sign in** (emapta-shaped).
///
/// When the router sends users here with `?continue=<encoded-uri>`, that value
/// is forwarded to `/login?redirect=` after they tap Sign in.
class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String? continueParam =
        GoRouterState.of(context).uri.queryParameters['continue'];
    final String loginBase = ref.watch(authLoginPathProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: NorthstarSpacing.space24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(flex: 2),
              Text(
                'Welcome',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: NorthstarSpacing.space12),
              Text(
                'Sign in with your organization account to open the dashboard, '
                'announcements, and workspace tools — same auth stack as emapta '
                '(Keycloak via emp_ai_auth).',
                style: textTheme.bodyLarge?.copyWith(
                  color: tokens.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 3),
              FilledButton(
                key: const ValueKey<String>('landing_sign_in'),
                onPressed: () {
                  final StringBuffer buf = StringBuffer(loginBase);
                  if (continueParam != null && continueParam.isNotEmpty) {
                    buf.write(
                      '?redirect=${Uri.encodeComponent(continueParam)}',
                    );
                  } else {
                    final String home = ref.read(authDefaultHomePathProvider);
                    buf.write('?redirect=${Uri.encodeComponent(home)}');
                  }
                  context.go(buf.toString());
                },
                child: const Text('Sign in'),
              ),
              const SizedBox(height: NorthstarSpacing.space12),
              Text(
                'Local dev: use flavor catalog client ids or AUTH_* defines — '
                'see emp_ai_auth_bootstrap.dart and docs/integrations/environment.md.',
                style: textTheme.labelSmall?.copyWith(
                  color: tokens.outline,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: NorthstarSpacing.space24),
            ],
          ),
        ),
      ),
    );
  }
}
