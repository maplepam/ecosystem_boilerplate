// Bumps ecosystem-platform (and optionally emp_ai_auth) Git refs across the repo.
//
// Run from repo root:
//   dart run tool/bump_platform_refs.dart [--platform-sha=<sha>] [<sha>] [--auth-sha=<sha>] [--dry-run] [--no-pub]
//   melos run bump:platform-refs -- [<sha>] [--auth-sha=...] [--platform-sha=...]
//
// Omit platform SHA to keep the current BOM `platform_git.ref` (auth-only bump).

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final bool dryRun = args.contains('--dry-run');
  final bool noPub = args.contains('--no-pub');
  String? platformArg;
  String? authSha;
  final List<String> pos = <String>[];
  for (final String a in args) {
    if (a == '--dry-run' || a == '--no-pub') {
      continue;
    }
    if (a.startsWith('--auth-sha=')) {
      authSha = _normalizeSha(a.split('=').skip(1).join('='));
      continue;
    }
    if (a.startsWith('--platform-sha=')) {
      platformArg = _normalizeSha(a.split('=').skip(1).join('='));
      continue;
    }
    if (a.startsWith('--')) {
      stderr.writeln('Unknown flag: $a');
      exit(64);
    }
    pos.add(a);
  }
  if (pos.isNotEmpty) {
    if (platformArg != null) {
      stderr.writeln('Use either a positional platform SHA or --platform-sha=, not both.');
      exit(64);
    }
    platformArg = _normalizeSha(pos.first);
  }
  if (authSha != null && authSha.length != 40) {
    stderr.writeln('--auth-sha must be a 40-character commit SHA.');
    exit(64);
  }

  final String root = _resolveEcosystemRoot();
  final File bomFile = File(p.join(root, 'docs', 'meta', 'platform_bom.yaml'));
  if (!bomFile.existsSync()) {
    stderr.writeln('Missing ${bomFile.path}');
    exit(1);
  }

  final dynamic bomYaml = loadYaml(await bomFile.readAsString());
  if (bomYaml is! YamlMap) {
    stderr.writeln('Invalid BOM YAML');
    exit(1);
  }
  final dynamic pg = bomYaml['platform_git'];
  if (pg is! YamlMap || pg['ref'] is! String) {
    stderr.writeln('BOM missing platform_git.ref');
    exit(1);
  }
  final String oldPlatform = (pg['ref'] as String).trim();
  if (oldPlatform.length != 40) {
    stderr.writeln(
      'Expected 40-char platform_git.ref in BOM, got: $oldPlatform',
    );
    exit(1);
  }

  String? oldAuth;
  final dynamic ag = bomYaml['auth_git'];
  if (ag is YamlMap && ag['ref'] is String) {
    oldAuth = (ag['ref'] as String).trim();
  }

  final String newPlatform = platformArg ?? oldPlatform;
  if (platformArg != null && newPlatform.length != 40) {
    stderr.writeln('Platform SHA must be 40 hex characters.');
    exit(64);
  }

  if (newPlatform == oldPlatform &&
      (authSha == null ||
          oldAuth == null ||
          oldAuth.length != 40 ||
          authSha == oldAuth)) {
    stderr.writeln(
      'Nothing to bump (platform unchanged and no auth SHA change). '
      'Pass a new 40-char platform SHA, or --auth-sha= when BOM auth_git.ref is a full SHA.',
    );
    exit(0);
  }

  if (newPlatform != oldPlatform) {
    stdout.writeln('Platform: $oldPlatform -> $newPlatform');
  }
  if (authSha != null && oldAuth != null && oldAuth.length == 40) {
    stdout.writeln('Auth:     $oldAuth -> $authSha');
  } else if (authSha != null) {
    stdout.writeln('Auth:     (--auth-sha set; BOM auth ref is not a 40-char SHA — see below)');
  }

  final List<_Patch> patches = <_Patch>[];

  if (newPlatform != oldPlatform) {
    patches.addAll(<_Patch>[
      _Patch(bomFile.path, oldPlatform, newPlatform),
      _Patch(
        p.join(root, 'apps', 'emp_ai_boilerplate_app', 'pubspec.yaml'),
        oldPlatform,
        newPlatform,
      ),
      _Patch(
        p.join(root, 'docs', 'integrations', 'emp_ai_auth_dependency.md'),
        oldPlatform,
        newPlatform,
      ),
      _Patch(
        p.join(root, 'docs', 'engineering', 'miniapp_packages_and_extract.md'),
        oldPlatform,
        newPlatform,
      ),
    ]);
  }

  if (authSha != null && oldAuth != null && oldAuth.isNotEmpty) {
    if (oldAuth.length == 40 && authSha != oldAuth) {
      patches.addAll(<_Patch>[
        _Patch(
          p.join(root, 'docs', 'meta', 'platform_bom.yaml'),
          oldAuth,
          authSha,
        ),
        _Patch(
          p.join(root, 'apps', 'emp_ai_boilerplate_app', 'pubspec.yaml'),
          oldAuth,
          authSha,
        ),
        _Patch(
          p.join(root, 'docs', 'integrations', 'emp_ai_auth_dependency.md'),
          oldAuth,
          authSha,
        ),
      ]);
    } else if (authSha != oldAuth) {
      stderr.writeln(
        'Auth ref in BOM is not a 40-char SHA ($oldAuth). '
        'Update apps/.../pubspec.yaml and docs/meta/platform_bom.yaml auth_git.ref '
        'manually, or pin auth by full SHA first.',
      );
    }
  }

  if (patches.isEmpty) {
    stderr.writeln('No file patches queued.');
    exit(0);
  }

  if (dryRun) {
    stdout.writeln('\n[--dry-run] Would patch:');
    int total = 0;
    for (final _Patch x in patches) {
      if (!File(x.path).existsSync()) {
        stdout.writeln('  (missing) ${x.path}');
        continue;
      }
      final String s = File(x.path).readAsStringSync();
      final int n = x.countIn(s);
      total += n;
      if (n > 0) {
        stdout.writeln('  $n× ${x.path}');
      }
    }
    if (total == 0) {
      stdout.writeln('  (no matching strings in files — check BOM vs disk)');
    }
    if (!noPub && total > 0) {
      stdout.writeln('  (then) flutter pub get in apps/emp_ai_boilerplate_app');
    }
    return;
  }

  int replacements = 0;
  for (final _Patch x in patches) {
    final File f = File(x.path);
    if (!f.existsSync()) {
      stderr.writeln('Skip missing: ${x.path}');
      continue;
    }
    String s = f.readAsStringSync();
    final int n = x.countIn(s);
    if (n == 0) {
      continue;
    }
    replacements += n;
    s = s.replaceAll(x.oldValue, x.newValue);
    f.writeAsStringSync(s);
    stdout.writeln('Updated $n× ${x.path}');
  }

  if (replacements == 0) {
    stdout.writeln('No matching strings — files unchanged.');
    return;
  }

  if (!noPub) {
    final appDir = p.join(root, 'apps', 'emp_ai_boilerplate_app');
    stdout.writeln('\nRunning flutter pub get in $appDir ...');
    final int code = await _run(Process.start(
      'flutter',
      const <String>['pub', 'get'],
      workingDirectory: appDir,
    ));
    if (code != 0) {
      stderr.writeln(
        'pub get failed (exit $code). If auth still pins an older emp_ai_core, '
        'bump emp_ai_core in emp-ai-flutter-auth and pass --auth-sha=... '
        'or see docs/meta/platform_bump_checklist.md',
      );
      exit(code);
    }
  }

  stdout.writeln('\nDone. Review diff, run analyze/tests, then commit.');
}

class _Patch {
  _Patch(this.path, this.oldValue, this.newValue);

  final String path;
  final String oldValue;
  final String newValue;

  int countIn(String s) => oldValue.allMatches(s).length;
}

String _normalizeSha(String s) {
  String t = s.trim().toLowerCase();
  if (t.startsWith('ref:')) {
    t = t.substring(4).trim();
  }
  return t;
}

Future<int> _run(Future<Process> start) async {
  final Process p = await start;
  await stdout.addStream(p.stdout);
  await stderr.addStream(p.stderr);
  return p.exitCode;
}

/// Same resolution as [tool/generate_miniapps.dart].
String _resolveEcosystemRoot() {
  Directory d = Directory.current;
  for (int i = 0; i < 8; i++) {
    final File yaml = File(p.join(d.path, 'miniapps_registry.yaml'));
    if (yaml.existsSync()) {
      return d.path;
    }
    final parent = d.parent;
    if (parent.path == d.path) {
      break;
    }
    d = parent;
  }

  try {
    final String scriptPath = Platform.script.toFilePath();
    if (scriptPath.endsWith('bump_platform_refs.dart')) {
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
