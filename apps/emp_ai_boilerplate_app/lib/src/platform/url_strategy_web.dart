import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Hash routes (`#/login`) so the GitHub Pages path prefix is not part of
/// [GoRouter] locations, and icon fonts resolve under `--base-href`.
void configureBoilerplateUrlStrategy() {
  setUrlStrategy(const HashUrlStrategy());
}
