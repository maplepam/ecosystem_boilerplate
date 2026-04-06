import '../../tokens/northstar_text_role.dart';
import 'package:flutter/material.dart';

/// Molecule: label + value row using semantic text roles.
class NorthstarLabeledValueRow extends StatelessWidget {
  const NorthstarLabeledValueRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: NorthstarTextRole.label.style(context),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: NorthstarTextRole.body.style(context),
            ),
          ),
        ],
      ),
    );
  }
}
