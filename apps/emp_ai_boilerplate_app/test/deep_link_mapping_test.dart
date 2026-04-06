import 'package:emp_ai_boilerplate_app/src/shell/deep_link/deep_link_listener.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapAppLinkToLocation', () {
    test('uses path when non-empty', () {
      expect(
        mapAppLinkToLocation(Uri.parse('https://app.example/samples/demo')),
        '/samples/demo',
      );
    });

    test('custom scheme with empty host uses absolute path', () {
      expect(
        mapAppLinkToLocation(Uri.parse('myapp:///samples/demo')),
        '/samples/demo',
      );
    });

    test('falls back to path segments when path is root-only', () {
      expect(
        mapAppLinkToLocation(Uri.parse('myapp:///main/home')),
        '/main/home',
      );
    });
  });
}
