import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Quill stores colors as `#AARRGGBB` (see flutter_quill [colorToHex]).
String northstarColorToQuillHex(Color color) {
  int channel(double x) => (x * 255.0).round() & 0xff;
  final String raw =
      '${channel(color.a).toRadixString(16).padLeft(2, '0')}'
      '${channel(color.r).toRadixString(16).padLeft(2, '0')}'
      '${channel(color.g).toRadixString(16).padLeft(2, '0')}'
      '${channel(color.b).toRadixString(16).padLeft(2, '0')}'
      .toUpperCase();
  return '#$raw';
}

Color? northstarColorFromQuillHex(String? hex) {
  if (hex == null || hex.isEmpty) {
    return null;
  }
  String s = hex.replaceFirst('#', '');
  if (s.length == 6) {
    s = 'FF$s';
  }
  if (s.length != 8) {
    return null;
  }
  final int? v = int.tryParse(s, radix: 16);
  if (v == null) {
    return null;
  }
  return Color(v);
}

/// Preset swatches + default (removes attribute) for the text-area toolbar.
///
/// Returns `true` if a color was applied or reset to default; `false` if dismissed.
Future<bool> showNorthstarTextAreaTextColorPicker({
  required BuildContext context,
  required QuillController controller,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Text color'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (final Color c in _kPresetTextColors)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      controller.formatSelection(
                        ColorAttribute(northstarColorToQuillHex(c)),
                      );
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(dialogContext).dividerColor,
                        ),
                      ),
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              controller.formatSelection(
                Attribute.clone(Attribute.color, null),
              );
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Default'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  ).then((bool? v) => v ?? false);
}

const List<Color> _kPresetTextColors = <Color>[
  Color(0xFF000000),
  Color(0xFF424242),
  Color(0xFFB71C1C),
  Color(0xFFE65100),
  Color(0xFFF9A825),
  Color(0xFF2E7D32),
  Color(0xFF0277BD),
  Color(0xFF283593),
  Color(0xFF6A1B9A),
  Color(0xFFC2185B),
  Color(0xFFFFFFFF),
];
