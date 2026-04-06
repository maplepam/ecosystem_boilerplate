import 'package:emp_ai_boilerplate_app/src/shell/auth/token_refresh/auth_refresh_bridge_provider.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_flavor_providers.dart';
import 'package:emp_ai_boilerplate_app/src/shell/deep_link/deep_link_listener.dart';
import 'package:emp_ai_boilerplate_app/src/shell/router/boilerplate_router.dart';
import 'package:emp_ai_boilerplate_app/src/theme/acme_brand_tokens.dart';
import 'package:emp_ai_boilerplate_app/src/theme/northstar_theme_mode_provider.dart';
import 'package:emp_ai_boilerplate_app/src/theme/user_accent_seed_notifier.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root widget: Northstar themes + [MaterialApp.router].
class BoilerplateApp extends ConsumerWidget {
  const BoilerplateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authRefreshBridgeProvider);
    final GoRouter router = ref.watch(boilerplateGoRouterProvider);
    final String appTitle = ref.watch(boilerplateDisplayTitleProvider);
    final NorthstarThemeModeController themeMode =
        ref.watch(northstarThemeModeControllerProvider);
    final Color? accent = ref.watch(userAccentSeedNotifierProvider);
    final NorthstarBranding branding = NorthstarBranding(
      lightTokens: AcmeBrandTokens.light,
      darkTokens: AcmeBrandTokens.dark,
      seedColor: accent,
    );

    return DeepLinkListener(
      router: router,
      child: ListenableBuilder(
        listenable: themeMode,
        builder: (BuildContext context, Widget? _) {
          return MaterialApp.router(
            title: appTitle,
            theme: branding.theme(Brightness.light),
            darkTheme: branding.theme(Brightness.dark),
            themeMode: themeMode.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
