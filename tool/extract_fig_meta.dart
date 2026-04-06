// Reads meta.json inside a Figma .fig export (ZIP) and prints canvas background.
// Full variable/style extraction needs Figma Variables export or API — canvas.fig
// uses the fig-kiwij binary and is not decoded here.
//
// Usage:
//   dart run tool/extract_fig_meta.dart "/path/to/V3 NORTHSTAR_ DESIGNSYSTEM.fig"

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/extract_fig_meta.dart <file.fig>\n'
      'Extracts meta.json from the ZIP (canvas background, file name).',
    );
    exit(64);
  }

  final String figPath = args.first;
  final File figFile = File(figPath);
  if (!figFile.existsSync()) {
    stderr.writeln('File not found: $figPath');
    exit(1);
  }

  final List<int> bytes = await figFile.readAsBytes();
  final Archive archive = ZipDecoder().decodeBytes(bytes);

  ArchiveFile? metaFile;
  for (final ArchiveFile f in archive.files) {
    if (f.isFile && f.name == 'meta.json') {
      metaFile = f;
      break;
    }
  }

  if (metaFile == null) {
    stderr.writeln('No meta.json in archive (not a valid .fig export?)');
    exit(1);
  }

  final String jsonText = utf8.decode(metaFile.content as List<int>);
  final Object? decoded = jsonDecode(jsonText);
  if (decoded is! Map<String, Object?>) {
    stderr.writeln('meta.json: expected object');
    exit(1);
  }

  final String? fileName = decoded['file_name'] as String?;
  final Object? clientMeta = decoded['client_meta'];
  stdout.writeln('file_name: $fileName');

  if (clientMeta is! Map<String, Object?>) {
    exit(0);
  }

  final Object? bg = clientMeta['background_color'];
  if (bg is! Map<String, Object?>) {
    stdout.writeln('No client_meta.background_color');
    exit(0);
  }

  final double r = (bg['r'] as num?)?.toDouble() ?? 0;
  final double g = (bg['g'] as num?)?.toDouble() ?? 0;
  final double b = (bg['b'] as num?)?.toDouble() ?? 0;
  final int ri = (r * 255).round().clamp(0, 255);
  final int gi = (g * 255).round().clamp(0, 255);
  final int bi = (b * 255).round().clamp(0, 255);
  final String hex =
      '#${ri.toRadixString(16).padLeft(2, '0')}${gi.toRadixString(16).padLeft(2, '0')}${bi.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
  final int argb = 0xFF000000 | (ri << 16) | (gi << 8) | bi;

  stdout.writeln('canvas_background_rgb: ($ri, $gi, $bi)');
  stdout.writeln('canvas_background_hex: $hex');
  stdout.writeln('Flutter: const Color(0x${argb.toRadixString(16).toUpperCase()});');
}
