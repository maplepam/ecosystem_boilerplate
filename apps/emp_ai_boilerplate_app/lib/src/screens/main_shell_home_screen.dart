import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_boilerplate_app/src/config/application_host_profile_provider.dart';
import 'package:emp_ai_boilerplate_app/src/config/host_mode.dart';
import 'package:emp_ai_boilerplate_app/src/shell/navigation/boilerplate_shell_paths.dart';
import 'package:emp_ai_boilerplate_app/src/network/boilerplate_api_client.dart';
import 'package:emp_ai_boilerplate_app/src/platform/feature_flags/feature_flag_provider.dart';
import 'package:emp_ai_core/emp_ai_core.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Default **main shell** home: cards into catalog, theme, DS showcase, Hub.
///
/// Replace this screen or trim cards when you ship your product landing page.
class MainShellHomeScreen extends ConsumerWidget {
  const MainShellHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final AuthSnapshot auth = ref.watch(boilerplateAuthSnapshotProvider);
    final dio = ref.watch(boilerplateDioProvider);
    final flags = ref.watch(featureFlagSourceProvider);
    final ApplicationHostProfile host = ref.watch(applicationHostProfileProvider);
    final AppBuildFlavor flavor = AppBuildFlavorParser.parse(host.flavorId);
    final double width = MediaQuery.sizeOf(context).width;
    final bool narrow = width < 520;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              NorthstarSpacing.space12,
              20,
              NorthstarSpacing.space8,
            ),
            child: _HeroIntro(tokens: tokens),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: NorthstarSpacing.space8,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: narrow ? 1 : 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: narrow ? 2.4 : 1.05,
            ),
            delegate: SliverChildListDelegate(
              <Widget>[
                _ShellHomeCard(
                  icon: Icons.widgets_rounded,
                  title: 'Browse components',
                  subtitle: 'Every Northstar control in one place — tap to try.',
                  accent: tokens.primary,
                  onAccent: tokens.onPrimary,
                  onTap: () => context.go(BoilerplateShellPaths.widgets),
                ),
                _ShellHomeCard(
                  icon: Icons.palette_rounded,
                  title: 'Look & feel',
                  subtitle: 'Light, dark, system, and accent colors.',
                  accent: tokens.secondary,
                  onAccent: tokens.onSecondary,
                  onTap: () => context.go(BoilerplateShellPaths.theme),
                ),
                _ShellHomeCard(
                  icon: Icons.gradient_rounded,
                  title: 'Color ramps',
                  subtitle: 'See how primary, success, and neutrals scale.',
                  accent: tokens.success,
                  onAccent: tokens.onSuccess,
                  onTap: () => context.go(BoilerplateShellPaths.designSystemShowcase),
                ),
                if (kBoilerplateHostMode == AppHostMode.superApp)
                  _ShellHomeCard(
                    icon: Icons.hub_rounded,
                    title: 'Hub',
                    subtitle:
                        'Samples, Resources, and Announcements in one place.',
                    accent: tokens.primaryContainer,
                    onAccent: tokens.onPrimaryContainer,
                    onTap: () => context.go(BoilerplateShellPaths.hubSamples),
                  ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              NorthstarSpacing.space24,
              20,
              NorthstarSpacing.space12,
            ),
            child: Text(
              'Behind the scenes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TechAccordion(
              auth: auth,
              dio: dio,
              flags: flags,
              flavor: flavor,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: NorthstarSpacing.space40),
        ),
      ],
    );
  }
}

class _HeroIntro extends StatelessWidget {
  const _HeroIntro({
    required this.tokens,
  });

  final NorthstarColorTokens tokens;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            tokens.primary,
            tokens.primary.withValues(alpha: 0.78),
            tokens.inverseSurface,
          ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: tokens.primary.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome',
              style: textTheme.headlineMedium?.copyWith(
                color: tokens.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Starter overview: open the widget catalog, theme lab, or Hub '
              '(samples, resources, announcements). Swap this copy for your '
              'product welcome when you are ready.',
              style: textTheme.bodyLarge?.copyWith(
                color: tokens.onPrimary.withValues(alpha: 0.92),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShellHomeCard extends StatelessWidget {
  const _ShellHomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onAccent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final Color onAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: tokens.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: onAccent, size: 26),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(
                  color: tokens.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: NorthstarSpacing.space8),
              Row(
                children: <Widget>[
                  Text(
                    'Open',
                    style: textTheme.labelLarge?.copyWith(
                      color: tokens.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: tokens.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechAccordion extends StatelessWidget {
  const _TechAccordion({
    required this.auth,
    required this.dio,
    required this.flags,
    required this.flavor,
  });

  final AuthSnapshot auth;
  final Dio dio;
  final FeatureFlagSource flags;
  final AppBuildFlavor flavor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.outlineVariant),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space16,
          vertical: NorthstarSpacing.space4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          NorthstarSpacing.space16,
          0,
          NorthstarSpacing.space16,
          NorthstarSpacing.space16,
        ),
        title: Text(
          'For engineers & QA',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Auth, networking, flags, and host mode',
          style: theme.textTheme.bodySmall?.copyWith(
            color: tokens.onSurfaceVariant,
          ),
        ),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Auth: ${auth.isAuthenticated ? "signed in" : "signed out"}\n'
              'Host: $kBoilerplateHostMode · flavor ${flavor.name}\n'
              'API base: ${dio.options.baseUrl}',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          FutureBuilder<bool>(
            future: flags.isEnabled('demo_flag'),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return Text(
                'Feature flag demo_flag → ${snapshot.data ?? "…"}',
                style: theme.textTheme.bodySmall,
              );
            },
          ),
        ],
      ),
    );
  }
}
