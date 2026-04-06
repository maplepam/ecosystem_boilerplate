import '../testing/ds_automation_keys.dart';
import 'northstar_drawer_entry.dart';
import 'northstar_navigation_drawer.dart';
import 'package:flutter/material.dart';

/// [Scaffold] with a leading menu control and [NorthstarNavigationDrawer].
///
/// Prefer composing [NorthstarNavigationDrawer] yourself when you need a custom
/// [AppBar]; this is the quick host shell pattern.
///
/// [automationId] is passed to the drawer and used for [DsAutomationKeys]
/// [elementScaffold] on the [Scaffold] (same prefix for both).
class NorthstarScaffoldWithDrawer extends StatelessWidget {
  const NorthstarScaffoldWithDrawer({
    super.key,
    required this.entries,
    required this.body,
    this.appBarTitle,
    this.drawerHeader,
    this.floatingActionButton,
    this.onDrawerNavigate,
    this.closeDrawerOnNavigate = true,
    this.automationId,
  });

  final List<NorthstarDrawerEntry> entries;
  final Widget body;

  /// Optional [DsAutomationKeys] for [Scaffold] + [NorthstarNavigationDrawer].
  final String? automationId;
  final Widget? appBarTitle;
  final Widget? drawerHeader;
  final Widget? floatingActionButton;

  /// See [NorthstarNavigationDrawer.onNavigate].
  final void Function(BuildContext context, String location)? onDrawerNavigate;

  /// See [NorthstarNavigationDrawer.closeOnNavigate].
  final bool closeDrawerOnNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: DsAutomationKeys.part(automationId, DsAutomationKeys.elementScaffold),
      appBar: AppBar(
        title: appBarTitle,
      ),
      drawer: NorthstarNavigationDrawer(
        automationId: automationId,
        header: drawerHeader,
        entries: entries,
        onNavigate: onDrawerNavigate,
        closeOnNavigate: closeDrawerOnNavigate,
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}
