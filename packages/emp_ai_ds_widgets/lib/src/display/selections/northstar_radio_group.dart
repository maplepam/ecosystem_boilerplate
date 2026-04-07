import 'package:flutter/material.dart';

/// Vertical [RadioGroup] + [Column] for a set of [NorthstarRadioRow]s.
class NorthstarRadioGroup<T extends Object> extends StatelessWidget {
  const NorthstarRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<T>(
      groupValue: groupValue,
      onChanged: onChanged,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
