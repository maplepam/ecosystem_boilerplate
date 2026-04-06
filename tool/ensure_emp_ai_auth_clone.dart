// 1) Clones emp_ai_auth into packages/emp_ai_auth when missing.
// 2) Patches auth's pubspec.yaml: `emp_ai_ds` from path ../emp_ai_ds → Git (this workspace
//    does not vendor emp_ai_ds). Enables `flutter analyze` / IDE inside packages/emp_ai_auth
//    and allows Melos to bootstrap that package.
//
// Runs from workspace root via Melos bootstrap pre-hook.
// Private Bitbucket: configure git credentials (or use SSH URLs below).

import 'dart:io';

const String _authBranch = 'myemapta_main';
const String _authCloneUrl =
    'https://bitbucket.org/empowerteams/emp-ai-flutter-auth.git';

/// Must match your Bitbucket branch for emp-ai-flutter-design-system.
const String _dsGitUrl =
    'https://bitbucket.org/empowerteams/emp-ai-flutter-design-system.git';
const String _dsRef = 'myemapta_main';

final RegExp _pathEmpAiDsBlock = RegExp(
  r'  # Local packages\s*\n  emp_ai_ds:\s*\n    path: \.\./emp_ai_ds',
  multiLine: true,
);

String get _dsGitBlock => '''
  # ecosystem_boilerplate: ../emp_ai_ds not vendored — use Git (see tool/ensure_emp_ai_auth_clone.dart)
  emp_ai_ds:
    git:
      url: $_dsGitUrl
      ref: $_dsRef''';

Future<void> main() async {
  final String root = Directory.current.path;
  final Directory authDir = Directory('$root/packages/emp_ai_auth');
  final File pubspec = File('${authDir.path}/pubspec.yaml');

  if (!pubspec.existsSync()) {
    stderr.writeln(
      'emp_ai_boilerplate: cloning emp_ai_auth into packages/emp_ai_auth …',
    );

    if (authDir.existsSync()) {
      await authDir.delete(recursive: true);
    }

    final ProcessResult r = await Process.run(
      'git',
      <String>[
        'clone',
        '-b',
        _authBranch,
        '--depth',
        '1',
        _authCloneUrl,
        authDir.path,
      ],
      workingDirectory: root,
      runInShell: false,
    );

    if (r.exitCode != 0) {
      stderr.writeln(r.stderr);
      stderr.writeln(
        'Clone failed. Use SSH: set _authCloneUrl to '
        'git@bitbucket.org:empowerteams/emp-ai-flutter-auth.git '
        'and ensure ssh-agent has access.',
      );
      exit(r.exitCode);
    }
  }

  if (!File('${authDir.path}/pubspec.yaml').existsSync()) {
    stderr.writeln(
      'emp_ai_boilerplate: packages/emp_ai_auth/pubspec.yaml missing — '
      'add submodule or fix clone.',
    );
    exit(1);
  }

  _patchAuthPubspecForEmpAiDsGit(File('${authDir.path}/pubspec.yaml'));

  // Legacy: remove generated overrides if present (patch replaces their role).
  final File legacyOverrides = File('${authDir.path}/pubspec_overrides.yaml');
  if (legacyOverrides.existsSync()) {
    legacyOverrides.deleteSync();
  }
}

void _patchAuthPubspecForEmpAiDsGit(File pubspec) {
  final String original = pubspec.readAsStringSync();
  if (original.contains('ecosystem_boilerplate: ../emp_ai_ds not vendored')) {
    return;
  }
  if (!_pathEmpAiDsBlock.hasMatch(original)) {
    stderr.writeln(
      'emp_ai_boilerplate: emp_ai_auth/pubspec.yaml has no expected '
      '`emp_ai_ds` path block — skip patch (custom fork?).',
    );
    return;
  }
  final String next = original.replaceFirst(_pathEmpAiDsBlock, _dsGitBlock);
  pubspec.writeAsStringSync(next);
  stderr.writeln(
    'emp_ai_boilerplate: patched emp_ai_auth to use emp_ai_ds from Git.',
  );
}
