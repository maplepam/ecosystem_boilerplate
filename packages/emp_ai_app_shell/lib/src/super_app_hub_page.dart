import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'mini_app.dart';

/// Simple launcher listing registered [MiniApp]s. Replace with product shell
/// (rail, bottom nav, feature flags) in real apps.
class SuperAppHubPage extends StatelessWidget {
  const SuperAppHubPage({
    super.key,
    required this.miniApps,
    this.title = 'SuperApp',
  });

  final List<MiniApp> miniApps;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        itemCount: miniApps.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int i) {
          final MiniApp app = miniApps[i];
          return ListTile(
            title: Text(app.displayName),
            subtitle: Text(app.entryLocation),
            onTap: () => context.go(app.entryLocation),
          );
        },
      ),
    );
  }
}
