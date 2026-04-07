import 'package:emp_ai_ds_widgets/src/display/northstar_snackbar.dart';
import 'package:flutter/material.dart';

/// Short floating snack used by widget-library previews (tap / demo feedback).
void catalogPreviewSnack(BuildContext context, String message) {
  showNorthstarSnackBar(
    context,
    message: message,
    kind: NorthstarSnackbarKind.neutral,
    showClose: false,
    duration: const Duration(milliseconds: 1200),
  );
}
