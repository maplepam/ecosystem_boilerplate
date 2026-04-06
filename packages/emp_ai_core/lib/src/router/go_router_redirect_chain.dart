import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Run redirects in order; first non-null wins.
GoRouterRedirect chainGoRouterRedirects(
  List<GoRouterRedirect?> redirects,
) {
  return (BuildContext context, GoRouterState state) async {
    for (final GoRouterRedirect? r in redirects) {
      if (r == null) {
        continue;
      }
      final String? target = await r(context, state);
      if (target != null) {
        return target;
      }
    }
    return null;
  };
}
