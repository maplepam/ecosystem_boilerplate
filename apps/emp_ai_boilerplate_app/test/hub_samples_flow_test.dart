import 'package:emp_ai_boilerplate_app/src/app/boilerplate_app.dart';
import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'support/boilerplate_auth_test_overrides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end style widget test: authenticated main shell **Hub** → Samples
/// mini-app surface (outer Apps rail is off; see [kSuperAppShowMiniAppRail]).
///
/// Uses [boilerplateAuthenticatedTestOverrides] instead of Keycloak.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shell Hub → Samples mini-app', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...boilerplateAuthenticatedTestOverrides(),
        ],
        child: const BoilerplateApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 4));

    final Finder navBar = find.byType(NavigationBar);
    expect(navBar, findsOneWidget);
    expect(find.text('Hub'), findsOneWidget);
    await tester.tap(find.text('Hub'));
    await tester.pumpAndSettle();
    // Parent tab opens the drawer; pick a Hub child route from the menu.
    await tester.tap(find.text('Samples'));
    await tester.pumpAndSettle();

    expect(find.text('Samples mini-app'), findsOneWidget);
  });
}
