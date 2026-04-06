import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:emp_ai_boilerplate_app/src/config/boilerplate_auth_config.dart';
import 'package:emp_ai_boilerplate_app/src/shell/deep_link/boilerplate_initial_app_link.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Applies [boilerplateInitialAppLink] after first frame, then listens to
/// [AppLinks.uriLinkStream]. Pass the same [GoRouter] used by [MaterialApp.router].
///
/// Gated by [kBoilerplateEnableAppLinks]. For product setup and docs, see
/// `docs/onboarding/getting_started.md` (deep links subsection under host snippets).
class DeepLinkListener extends StatefulWidget {
  const DeepLinkListener({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  @override
  State<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends State<DeepLinkListener> {
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    if (!kBoilerplateEnableAppLinks) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apply(boilerplateInitialAppLink);
    });
    _sub = AppLinks().uriLinkStream.listen(_apply);
  }

  void _apply(Uri? uri) {
    if (uri == null || !mounted) {
      return;
    }
    final String? path = mapAppLinkToLocation(uri);
    if (path == null || path.isEmpty) {
      return;
    }
    widget.router.go(path);
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Maps `https://host/app/samples/demo` or `myapp://samples/demo` to a
/// [GoRouter] location. Override behavior per product if you use custom hosts.
String? mapAppLinkToLocation(Uri uri) {
  if (uri.path.isNotEmpty && uri.path != '/') {
    return uri.path.startsWith('/') ? uri.path : '/${uri.path}';
  }
  if (uri.pathSegments.isNotEmpty) {
    return '/${uri.pathSegments.join('/')}';
  }
  return null;
}
