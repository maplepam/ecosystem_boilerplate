// Generates apps/.../miniapp_catalog.g.dart from miniapps_registry.yaml.
// Run: dart run tool/generate_miniapps.dart (from ecosystem_boilerplate), or from
// repo root — the script walks up to find miniapps_registry.yaml.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final String root = _resolveEcosystemRoot();
  final File registryFile = File(p.join(root, 'miniapps_registry.yaml'));
  if (!registryFile.existsSync()) {
    stderr.writeln(
      'Missing ${registryFile.path}\n'
      'Expected miniapps_registry.yaml next to tool/. '
      'Run from ecosystem_boilerplate or ensure the file exists.',
    );
    exit(1);
  }

  final dynamic doc = loadYaml(await registryFile.readAsString());
  if (doc is! YamlMap) {
    stderr.writeln('Invalid registry YAML');
    exit(1);
  }

  final String? output = doc['output'] as String?;
  final dynamic entries = doc['entries'];
  if (output == null || entries is! YamlList) {
    stderr.writeln('Registry must define output: and entries:');
    exit(1);
  }

  final StringBuffer imports = StringBuffer();
  final StringBuffer symbols = StringBuffer();
  final Set<String> seenImports = <String>{};

  for (final dynamic e in entries) {
    if (e is! YamlMap) {
      continue;
    }
    final String? importUri = e['import'] as String?;
    final String? symbol = e['symbol'] as String?;
    if (importUri == null || symbol == null) {
      stderr.writeln('Each entry needs import: and symbol:');
      exit(1);
    }
    if (seenImports.add(importUri)) {
      imports.writeln("import '$importUri';");
    }
    symbols.writeln('  $symbol(),');
  }

  final String outPath = p.join(root, output);
  final File outFile = File(outPath);
  await outFile.parent.create(recursive: true);

  const String header = '''
// GENERATED FILE — do not edit by hand.
// Run from ecosystem_boilerplate: melos run generate:miniapps

import 'package:emp_ai_app_shell/emp_ai_app_shell.dart';
''';

  await outFile.writeAsString(
    '$header'
    '$imports\n'
    'final List<MiniApp> kAllMiniApps = <MiniApp>[\n'
    '$symbols'
    '];\n',
  );

  stdout.writeln('Wrote ${outFile.path}');
}

/// Finds the directory that contains [miniapps_registry.yaml].
String _resolveEcosystemRoot() {
  // 1) Walk up from cwd (covers `dart run` from repo root or IDE).
  Directory d = Directory.current;
  for (var i = 0; i < 16; i++) {
    final File candidate = File(p.join(d.path, 'miniapps_registry.yaml'));
    if (candidate.existsSync()) {
      return d.path;
    }
    final Directory parent = d.parent;
    if (parent.path == d.path) {
      break;
    }
    d = parent;
  }

  // 2) Relative to this script: .../ecosystem_boilerplate/tool/generate_miniapps.dart
  try {
    final String scriptPath = Platform.script.toFilePath();
    if (scriptPath.endsWith('generate_miniapps.dart')) {
      final String toolDir = p.dirname(scriptPath);
      final String candidateRoot = p.dirname(toolDir);
      final File yaml = File(p.join(candidateRoot, 'miniapps_registry.yaml'));
      if (yaml.existsSync()) {
        return candidateRoot;
      }
    }
  } on Object {
    // ignore
  }

  return Directory.current.path;
}
