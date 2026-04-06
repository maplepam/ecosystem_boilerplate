import 'package:emp_ai_boilerplate_app/src/app/boilerplate_app.dart';
import 'package:emp_ai_boilerplate_app/src/providers/shared_preferences_provider.dart';
import 'support/boilerplate_auth_test_overrides.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Boilerplate renders', (WidgetTester tester) async {
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
    await tester.pumpAndSettle();
    expect(find.textContaining('Welcome'), findsOneWidget);
  });
}
