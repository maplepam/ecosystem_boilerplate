import 'package:flutter/material.dart';

/// Outlined search field aligned with Northstar / Material 3 density.
@immutable
class NorthstarSearchField extends StatelessWidget {
  const NorthstarSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.automationId,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  /// Optional stable key for integration tests.
  final String? automationId;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: automationId != null ? ValueKey<String>(automationId!) : null,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
