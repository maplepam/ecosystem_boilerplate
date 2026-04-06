import '../testing/ds_automation_keys.dart';
import 'northstar_drawer_entry.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Material [Drawer] driven by [entries]. Navigation uses [GoRouter.go] unless
/// [onNavigate] is provided (tests or custom routers).
///
/// [automationId] sets [DsAutomationKeys.elementDrawer] on the drawer and
/// `drawer_<path>` on each row ([ListTile] / [ExpansionTile]), where [path] is
/// a stable index path (`0`, `1`, `2g_0` for first child of second group, …).
class NorthstarNavigationDrawer extends StatelessWidget {
  const NorthstarNavigationDrawer({
    super.key,
    required this.entries,
    this.header,
    this.onNavigate,
    this.closeOnNavigate = true,
    this.automationId,
  });

  final List<NorthstarDrawerEntry> entries;
  final Widget? header;

  /// Optional [DsAutomationKeys] prefix for the drawer and rows.
  final String? automationId;

  /// Override navigation (e.g. Navigator.push). Default: `context.go(location)`.
  final void Function(BuildContext context, String location)? onNavigate;

  /// Set false for embedded previews (e.g. widget catalog) where there is no
  /// modal route to pop.
  final bool closeOnNavigate;

  void _go(BuildContext context, String location) {
    final void Function(BuildContext context, String location)? cb = onNavigate;
    if (cb != null) {
      cb(context, location);
    } else {
      context.go(location);
    }
    if (closeOnNavigate) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Drawer(
      key: DsAutomationKeys.part(automationId, DsAutomationKeys.elementDrawer),
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (header != null) header!,
            ..._buildEntryList(context, entries, ''),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEntryList(
    BuildContext context,
    List<NorthstarDrawerEntry> list,
    String pathPrefix,
  ) {
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < list.length; i++) {
      final String id = pathPrefix.isEmpty ? '$i' : '${pathPrefix}_$i';
      out.add(_buildEntry(context, list[i], id));
    }
    return out;
  }

  Widget _buildEntry(
    BuildContext context,
    NorthstarDrawerEntry entry,
    String pathId,
  ) {
    final Key? rowKey =
        DsAutomationKeys.part(automationId, 'drawer_$pathId');

    return switch (entry) {
      NorthstarDrawerRouteEntry(
        :final location,
        :final label,
        :final icon,
        :final selected,
      ) =>
        ListTile(
          key: rowKey,
          leading: icon != null ? Icon(icon) : null,
          title: Text(label),
          selected: selected,
          onTap: () => _go(context, location),
        ),
      NorthstarDrawerExpansionEntry(
        :final label,
        :final icon,
        :final children,
        :final initiallyExpanded,
      ) =>
        ExpansionTile(
          key: rowKey,
          initiallyExpanded: initiallyExpanded,
          leading: icon != null ? Icon(icon) : null,
          title: Text(label),
          children: _buildEntryList(context, children, '${pathId}g'),
        ),
      NorthstarDrawerCustomEntry(:final builder) => builder(context),
    };
  }
}
