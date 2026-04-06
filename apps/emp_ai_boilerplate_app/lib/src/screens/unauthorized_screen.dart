import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Shown when the user is signed in but fails role / permission checks.
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access denied'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(NorthstarSpacing.space24),
        child: Text(
          'You do not have permission to open this page. '
          'Adjust RouteAccessPolicy or your IdP claims.',
        ),
      ),
    );
  }
}
