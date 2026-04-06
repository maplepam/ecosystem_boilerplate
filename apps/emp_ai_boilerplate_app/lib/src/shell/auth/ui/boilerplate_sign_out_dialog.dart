import 'package:emp_ai_boilerplate_app/src/shell/auth/boilerplate_clear_host_caches.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_route_access.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Confirmation → loading while sign-out runs; then [boilerplateClearHostCaches]
/// and navigation to [authLoginPathProvider] (success or failure).
Future<void> showBoilerplateSignOutDialog(
  BuildContext shellContext,
  WidgetRef ref,
) async {
  await showDialog<void>(
    context: shellContext,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => _SignOutDialog(
      shellContext: shellContext,
    ),
  );
}

class _SignOutDialog extends ConsumerStatefulWidget {
  const _SignOutDialog({required this.shellContext});

  final BuildContext shellContext;

  @override
  ConsumerState<_SignOutDialog> createState() => _SignOutDialogState();
}

class _SignOutDialogState extends ConsumerState<_SignOutDialog> {
  bool _loading = false;

  Future<void> _onConfirm() async {
    setState(() => _loading = true);
    try {
      await boilerplateSignOut(ref);
    } catch (e, st) {
      debugPrint('boilerplateSignOut failed: $e\n$st');
    } finally {
      await boilerplateClearHostCaches();
      ref.invalidate(boilerplateAuthSnapshotProvider);
    }
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    if (!widget.shellContext.mounted) {
      return;
    }
    GoRouter.of(widget.shellContext).go(ref.read(authLoginPathProvider));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      child: _loading ? _loadingDialog(context) : _confirmDialog(context),
    );
  }

  Widget _confirmDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Sign out?'),
      content: const Text(
        'You will need to sign in again to access the workspace.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _loading ? null : _onConfirm,
          child: const Text('Sign out'),
        ),
      ],
    );
  }

  Widget _loadingDialog(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: <Widget>[
          const SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              'Signing out…',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
