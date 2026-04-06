import 'package:flutter/material.dart';

/// Short floating snack used by widget-library previews (tap / demo feedback).
void catalogPreviewSnack(BuildContext context, String message) {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1100),
    ),
  );
}
