// Rewrites [NorthstarBaseTokens] color literals in ecosystem-platform from
// Figma Variables DTCG JSON exports (Light / Dark / White Labeled).
//
// Run from ecosystem_boilerplate root (default output: sibling ../ecosystem-platform/...):
//   dart run tool/sync_northstar_base_tokens_from_dtcg.dart \
//     --light=Light.tokens.json --dark=Dark.tokens.json \
//     --white-labeled="White Labeled.tokens.json" [--output=...] [--dry-run]
//
//   melos run sync:northstar-dtcg -- --light=... --dark=... --white-labeled=...

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  final bool dryRun = args.contains('--dry-run');
  String? lightPath;
  String? darkPath;
  String? whitePath;
  String? outputPath;
  for (final String a in args) {
    if (a == '--dry-run') {
      continue;
    }
    if (a.startsWith('--light=')) {
      lightPath = a.substring('--light='.length);
    } else if (a.startsWith('--dark=')) {
      darkPath = a.substring('--dark='.length);
    } else if (a.startsWith('--white-labeled=')) {
      whitePath = a.substring('--white-labeled='.length);
    } else if (a.startsWith('--output=')) {
      outputPath = a.substring('--output='.length);
    } else if (a.startsWith('--')) {
      stderr.writeln('Unknown flag: $a');
      exit(64);
    } else {
      stderr.writeln('Unexpected argument: $a');
      exit(64);
    }
  }
  if (lightPath == null || darkPath == null || whitePath == null) {
    stderr.writeln(
      'Usage: dart run tool/sync_northstar_base_tokens_from_dtcg.dart \\\n'
      '  --light=PATH --dark=PATH --white-labeled=PATH \\\n'
      '  [--output=PATH_TO_northstar_base_tokens.dart] [--dry-run]\n'
      '\n'
      'Default --output: ../ecosystem-platform/packages/emp_ai_ds_northstar/'
      'lib/src/northstar_base_tokens.dart (relative to this repo root).',
    );
    exit(64);
  }

  final String root = _resolveEcosystemRoot();
  outputPath ??= p.normalize(p.join(
    root,
    '..',
    'ecosystem-platform',
    'packages',
    'emp_ai_ds_northstar',
    'lib',
    'src',
    'northstar_base_tokens.dart',
  ));

  final File outFile = File(outputPath);
  if (!outFile.existsSync()) {
    stderr.writeln('Output not found: ${outFile.path}\n'
        'Pass --output= to your northstar_base_tokens.dart');
    exit(1);
  }

  final Map<String, String> lightFlat =
      _flattenDtcgColors(File(lightPath).readAsStringSync());
  final Map<String, String> darkFlat =
      _flattenDtcgColors(File(darkPath).readAsStringSync());
  final Map<String, String> whiteFlat =
      _flattenDtcgColors(File(whitePath).readAsStringSync());

  final String original = outFile.readAsStringSync();
  String content = original;
  content = _patchVariant(
    content,
    'light',
    lightFlat,
    _variantOverrides['light']!,
  );
  content = _patchVariant(
    content,
    'dark',
    darkFlat,
    _variantOverrides['dark']!,
  );
  content = _patchVariant(
    content,
    'whiteLabeledLight',
    whiteFlat,
    _variantOverrides['whiteLabeledLight']!,
  );

  if (dryRun) {
    if (content == original) {
      stdout.writeln('[--dry-run] No changes vs ${outFile.path}');
    } else {
      stdout.writeln('[--dry-run] Would update ${outFile.path} (content differs)');
    }
    return;
  }
  outFile.writeAsStringSync(content);
  stdout.writeln('Wrote ${outFile.path}');
  stdout.writeln('Run: dart format ${outFile.path}');
  stdout.writeln('Then: cd ecosystem-platform && dart analyze packages/emp_ai_ds_northstar');
}

/// Figma display path (space-separated) -> Dart `Color(0xAARRGGBB)` literal body `0xFFrrggbb`.
const List<String> _northstarColorFields = <String>[
  'primary',
  'onPrimary',
  'primaryContainer',
  'onPrimaryContainer',
  'secondary',
  'onSecondary',
  'surface',
  'onSurface',
  'onSurfaceVariant',
  'surfaceContainerLow',
  'surfaceContainerHigh',
  'outline',
  'outlineVariant',
  'error',
  'onError',
  'success',
  'onSuccess',
  'warning',
  'onWarning',
  'inverseSurface',
  'onInverseSurface',
  'background',
  'backgroundBright',
  'backgroundDim',
  'border',
  'card0',
  'card10',
  'card20',
  'card30',
  'card40',
  'contentBlack',
  'contentGray',
  'contentGrayBright',
  'contentWhite',
  'divider',
  'errorContainer',
  'errorVariant',
  'errorHover',
  'logotype',
  'miscellaneousBlue',
  'miscellaneousBlueContainer',
  'miscellaneousBlueHover',
  'miscellaneousBlueVariant',
  'miscellaneousEmerald',
  'miscellaneousEmeraldContainer',
  'miscellaneousEmeraldHover',
  'miscellaneousEmeraldVariant',
  'miscellaneousIndigo',
  'miscellaneousIndigoContainer',
  'miscellaneousIndigoHover',
  'miscellaneousIndigoVariant',
  'miscellaneousOnBlueContainer',
  'miscellaneousOnEmeraldContainer',
  'miscellaneousOnIndigoContainer',
  'miscellaneousOnOrangeContainer',
  'miscellaneousOnPinkContainer',
  'miscellaneousOnVioletContainer',
  'miscellaneousOrange',
  'miscellaneousOrangeContainer',
  'miscellaneousOrangeHover',
  'miscellaneousOrangeVariant',
  'miscellaneousPink',
  'miscellaneousPinkContainer',
  'miscellaneousPinkHover',
  'miscellaneousPinkVariant',
  'miscellaneousViolet',
  'miscellaneousVioletContainer',
  'miscellaneousVioletHover',
  'miscellaneousVioletVariant',
  'onErrorContainer',
  'onSecondaryContainer',
  'onSuccessContainer',
  'onWarningContainer',
  'primaryHover',
  'primaryVariant',
  'secondaryContainer',
  'secondaryHover',
  'secondaryVariant',
  'successContainer',
  'successHover',
  'successVariant',
  'warningContainer',
  'warningHover',
  'warningVariant',
];

/// Per-variant Figma keys for roles that do not match [figmaPathToDartField] 1:1.
const Map<String, Map<String, String>> _variantOverrides =
    <String, Map<String, String>>{
  'light': <String, String>{
    'surface': 'Background Bright',
    'onSurface': 'Content Black',
    'onSurfaceVariant': 'Content Gray',
    'inverseSurface': 'Logotype',
    'onInverseSurface': 'Content White',
    'surfaceContainerLow': 'Background',
    'surfaceContainerHigh': 'Background Dim',
    'outline': 'Border',
    'border': 'Border',
    'outlineVariant': 'Background Dim',
    'divider': 'Divider',
    'background': 'Background',
    'backgroundBright': 'Background Bright',
    'backgroundDim': 'Background Dim',
  },
  'dark': <String, String>{
    'surface': 'Background Bright',
    'onSurface': 'Content Black',
    'onSurfaceVariant': 'Content Gray',
    'inverseSurface': 'Content Black',
    'onInverseSurface': 'Content White',
    'surfaceContainerLow': 'Background',
    'surfaceContainerHigh': 'Background Dim',
    'outline': 'Border',
    'border': 'Border',
    'divider': 'Divider',
    'background': 'Background',
    'backgroundBright': 'Background Bright',
    'backgroundDim': 'Background Dim',
  },
  'whiteLabeledLight': <String, String>{
    'surface': 'Background Bright',
    'onSurface': 'Content Black',
    'onSurfaceVariant': 'Content Gray',
    'inverseSurface': 'Logotype',
    'onInverseSurface': 'Content White',
    'surfaceContainerLow': 'Background',
    'surfaceContainerHigh': 'Background Dim',
    'outline': 'Border',
    'border': 'Border',
    'outlineVariant': 'Background Dim',
    'divider': 'Divider',
    'background': 'Background',
    'backgroundBright': 'Background Bright',
    'backgroundDim': 'Background Dim',
  },
};

String _patchVariant(
  String fileContent,
  String variantName,
  Map<String, String> figmaColors,
  Map<String, String> overrides,
) {
  final RegExp blockStart = RegExp(
    'static const NorthstarColorTokens $variantName = NorthstarColorTokens\\(',
  );
  final Match? m = blockStart.firstMatch(fileContent);
  if (m == null) {
    throw StateError('Block not found: $variantName');
  }
  final int openParen = fileContent.indexOf('(', m.start);
  int depth = 0;
  int i = openParen;
  for (; i < fileContent.length; i++) {
    final int ch = fileContent.codeUnitAt(i);
    if (ch == 0x28) {
      depth++;
    } else if (ch == 0x29) {
      depth--;
      if (depth == 0) {
        i++;
        break;
      }
    }
  }
  final int blockEnd = i;
  String slice = fileContent.substring(m.start, blockEnd);

  final List<String> missing = <String>[];
  for (final String field in _northstarColorFields) {
    String? figmaKey = overrides[field];
    figmaKey ??= _figmaKeyForDartField(field, figmaColors.keys);
    if (figmaKey == null) {
      continue;
    }
    final String? hex = figmaColors[figmaKey];
    if (hex == null) {
      missing.add('$field ← $figmaKey');
      continue;
    }
    final String argb = _toFlutterArgb(hex);
    final RegExp lineRe = RegExp(
      '(^\\s*)$field:\\s*Color\\(0x[0-9A-Fa-f]{8}\\),',
      multiLine: true,
    );
    final String replacement = '${lineRe.firstMatch(slice)?.group(1) ?? '    '}'
        '$field: Color($argb),';
    if (!lineRe.hasMatch(slice)) {
      missing.add('$field (line not found)');
      continue;
    }
    slice = slice.replaceFirst(lineRe, replacement);
  }

  if (missing.isNotEmpty) {
    stderr.writeln('[$variantName] unresolved / skipped:');
    for (final String x in missing) {
      stderr.writeln('  - $x');
    }
  }

  return fileContent.replaceRange(m.start, blockEnd, slice);
}

String? _figmaKeyForDartField(String dartField, Iterable<String> figmaKeys) {
  for (final String k in figmaKeys) {
    if (figmaPathToDartField(k) == dartField) {
      return k;
    }
  }
  return null;
}

/// "Primary Hover" -> primaryHover; "Card 10" -> card10; "Miscellaneous Orange" -> miscellaneousOrange.
String figmaPathToDartField(String figmaPath) {
  final List<String> parts =
      figmaPath.split(RegExp(r'\s+')).where((String p) => p.isNotEmpty).toList();
  if (parts.isEmpty) {
    return figmaPath;
  }
  final StringBuffer out = StringBuffer(parts.first.toLowerCase());
  for (int i = 1; i < parts.length; i++) {
    final String p = parts[i];
    if (RegExp(r'^\d+$').hasMatch(p)) {
      out.write(p);
    } else if (p.isNotEmpty) {
      out.write(p[0].toUpperCase());
      if (p.length > 1) {
        out.write(p.substring(1).toLowerCase());
      }
    }
  }
  return out.toString();
}

Map<String, String> _flattenDtcgColors(String jsonText) {
  final Object? root = json.decode(jsonText);
  if (root is! Map<String, dynamic>) {
    throw const FormatException('Root must be a JSON object');
  }
  final Map<String, String> out = <String, String>{};
  void walk(Map<String, dynamic> node, String prefix) {
    for (final MapEntry<String, dynamic> e in node.entries) {
      if (e.key.startsWith(r'$')) {
        continue;
      }
      final String path = prefix.isEmpty ? e.key : '$prefix ${e.key}';
      final Object? v = e.value;
      if (v is! Map<String, dynamic>) {
        continue;
      }
      if (v[r'$type'] == 'color' && v[r'$value'] is Map<String, dynamic>) {
        final String? hex = _readHex(v[r'$value'] as Map<String, dynamic>);
        if (hex != null) {
          out[path] = hex;
        }
      } else {
        walk(v, path);
      }
    }
  }

  walk(root, '');
  return out;
}

String? _readHex(Map<String, dynamic> valueNode) {
  final Object? hex = valueNode['hex'];
  if (hex is String && hex.startsWith('#') && hex.length >= 7) {
    return hex.toUpperCase();
  }
  return null;
}

/// `#RRGGBB` or `#AARRGGBB` -> `0xAARRGGBB` (default FF alpha).
String _toFlutterArgb(String hashHex) {
  String h = hashHex.toUpperCase().replaceFirst('#', '');
  if (h.length == 6) {
    h = 'FF$h';
  }
  if (h.length != 8) {
    throw FormatException('Bad hex: $hashHex');
  }
  return '0x$h';
}

String _resolveEcosystemRoot() {
  Directory d = Directory.current;
  for (int i = 0; i < 8; i++) {
    final File yaml = File(p.join(d.path, 'miniapps_registry.yaml'));
    if (yaml.existsSync()) {
      return d.path;
    }
    final Directory parent = d.parent;
    if (parent.path == d.path) {
      break;
    }
    d = parent;
  }

  try {
    final String scriptPath = Platform.script.toFilePath();
    if (scriptPath.endsWith('sync_northstar_base_tokens_from_dtcg.dart')) {
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
