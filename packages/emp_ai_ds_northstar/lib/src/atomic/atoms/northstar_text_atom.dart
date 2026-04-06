import '../../tokens/northstar_text_role.dart';
import 'package:flutter/material.dart';

/// Atom: text bound to a [NorthstarTextRole] (M3 [TextTheme]).
class NorthstarTextAtom extends StatelessWidget {
  const NorthstarTextAtom(
    this.data, {
    super.key,
    required this.role,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.color,
    this.weight,
  });

  final String data;
  final NorthstarTextRole role;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Color? color;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    TextStyle base = role.style(context);
    if (color != null) {
      base = base.copyWith(color: color);
    }
    if (weight != null) {
      base = base.copyWith(fontWeight: weight);
    }
    return Text(
      data,
      style: base,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
