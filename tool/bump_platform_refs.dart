// Bumps ecosystem-platform (and optionally emp_ai_auth) Git refs across the repo.
//
// Run from repo root:
//   dart run tool/bump_platform_refs.dart [--platform-sha=<sha>] [<sha>] [--auth-sha=<sha>]
//     [--auth-repo=<path>] [--dry-run] [--no-pub]
//   melos run bump:platform-refs -- [<sha>] [--auth-sha=...] [--platform-sha=...] [--auth-repo=...]
//
// Omit platform SHA to keep the current BOM `platform_git.ref` (auth-only bump).
//
// Optional `--auth-repo=` (or env `EMP_AI_AUTH_REPO`): path to a local **emp-ai-flutter-auth**
// clone. When set, sets `emp_ai_core` → `git` → `ref` in that repo’s **pubspec.yaml** to the
// **target platform SHA** (`newPlatform`) so Pub can resolve one `emp_ai_core` revision. Does not
// commit or push the auth repo.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final bool dryRun = args.contains('--dry-run');
  final bool noPub = args.contains('--no-pub');
  String? platformArg;
  String? authSha;
  String? authRepoPath;
  final List<String> pos = <String>[];
  for (final String a in args) {
    if (a == '--dry-run' || a == '--no-pub') {
      continue;
    }
    if (a.startsWith('--auth-sha=')) {
      authSha = _normalizeSha(a.split('=').skip(1).join('='));
      continue;
    }
    if (a.startsWith('--auth-repo=')) {
      final String expanded =
          _expandUserPath(a.substring('--auth-repo='.length).trim());
      authRepoPath = expanded.isEmpty ? null : expanded;
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
  if (authRepoPath == null) {
    final String fromEnv =
        _expandUserPath(Platform.environment['EMP_AI_AUTH_REPO']?.trim() ?? '');
    authRepoPath = fromEnv.isEmpty ? null : fromEnv;
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

  final bool noBoilerplateBump = newPlatform == oldPlatform &&
      (authSha == null ||
          oldAuth == null ||
          oldAuth.length != 40 ||
          authSha == oldAuth);
  if (noBoilerplateBump && authRepoPath == null) {
    stderr.writeln(
      'Nothing to bump (platform unchanged and no auth SHA change). '
      'Pass a new 40-char platform SHA, or --auth-sha= when BOM auth_git.ref is a full SHA, '
      'or --auth-repo= / \$EMP_AI_AUTH_REPO to sync emp_ai_core in a local auth clone.',
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

  if (patches.isEmpty && authRepoPath == null) {
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
    if (total == 0 && patches.isNotEmpty) {
      stdout.writeln('  (no matching strings in files — check BOM vs disk)');
    }
    if (authRepoPath != null) {
      _syncAuthEmpAiCorePubspec(
        authRepoRoot: authRepoPath,
        newPlatformRef: newPlatform,
        dryRun: true,
      );
    }
    if (!noPub && total > 0) {
      stdout.writeln('  (then) flutter pub get in apps/emp_ai_boilerplate_app');
    }
    if (total == 0 && authRepoPath == null) {
      stdout.writeln('  (no boilerplate file patches)');
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

  if (replacements == 0 && patches.isNotEmpty) {
    stdout.writeln('No matching strings — boilerplate files unchanged.');
  }

  if (authRepoPath != null) {
    _syncAuthEmpAiCorePubspec(
      authRepoRoot: authRepoPath,
      newPlatformRef: newPlatform,
      dryRun: false,
    );
  }

  if (replacements == 0 && authRepoPath == null) {
    return;
  }

  if (!noPub && replacements > 0) {
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
        'run again with --auth-repo=<path> (or \$EMP_AI_AUTH_REPO) to patch the auth '
        'clone, then commit/push auth and pass --auth-sha=... '
        '— see docs/meta/platform_bump_checklist.md',
      );
      exit(code);
    }
  }

  stdout.writeln('\nDone. Review diff, run analyze/tests, then commit.');
  if (authRepoPath != null) {
    stdout.writeln(
      'Auth clone updated in-place — commit and push that repo, then bump host '
      '`emp_ai_auth` ref with --auth-sha=<new-auth-commit>.',
    );
  }
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

/// Expands a leading `~/` using [HOME] / [USERPROFILE].
String _expandUserPath(String input) {
  final String t = input.trim();
  if (t.isEmpty) {
    return '';
  }
  if (t.startsWith('~/')) {
    final String? home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null || home.isEmpty) {
      return p.normalize(t);
    }
    return p.normalize(p.join(home, t.substring(2)));
  }
  return p.normalize(t);
}

/// Sets `emp_ai_core` → `ref` in **[authRepoRoot]/pubspec.yaml** to [newPlatformRef].
void _syncAuthEmpAiCorePubspec({
  required String authRepoRoot,
  required String newPlatformRef,
  required bool dryRun,
}) {
  final String pubPath = p.join(p.normalize(p.absolute(authRepoRoot)), 'pubspec.yaml');
  final File file = File(pubPath);
  if (!file.existsSync()) {
    stderr.writeln('Auth repo pubspec not found: $pubPath');
    return;
  }
  String content = file.readAsStringSync();
  final RegExp refLine = RegExp(
    r'(path:\s+packages/emp_ai_core\s*\n\s*ref:\s+)([0-9a-f]{40})\b',
    multiLine: true,
    caseSensitive: false,
  );
  final Match? match = refLine.firstMatch(content);
  if (match == null) {
    stderr.writeln(
      'Could not find emp_ai_core block (path: packages/emp_ai_core + 40-char ref) in $pubPath',
    );
    return;
  }
  final String oldRefRaw = match.group(2)!;
  if (oldRefRaw.toLowerCase() == newPlatformRef.toLowerCase()) {
    stdout.writeln('Auth emp_ai_core ref already $newPlatformRef — $pubPath');
    return;
  }
  if (dryRun) {
    stdout.writeln(
      '[dry-run] Auth emp_ai_core: $oldRefRaw -> $newPlatformRef ($pubPath)',
    );
    return;
  }
  content = content.replaceFirstMapped(
    refLine,
    (Match m) => '${m.group(1)}$newPlatformRef',
  );
  file.writeAsStringSync(content);
  stdout.writeln('Auth emp_ai_core: $oldRefRaw -> $newPlatformRef ($pubPath)');
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
