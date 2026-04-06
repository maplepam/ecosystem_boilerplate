import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_profile_id_notifier.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/screens/mobile/announcements_home_mobile_screen.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/screens/web/announcements_home_web_screen.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/ui/announcements_layout_tokens.dart';
import 'package:emp_ai_boilerplate_app/src/shell/auth/ui/boilerplate_auth_ui.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart' show AuthSnapshot;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route shell: picks mobile vs web layout by width (similar intent to SNR’s
/// `mobile/` + `web/` screens, without adding a DS dependency).
///
/// Ensures **employee assignment** is resolved into
/// [EmployeeAssignmentAnnouncementWire] before child widgets run CachedQuery,
/// so POST bodies match emapta V2 `recipients` + `channels`.
class AnnouncementsHomeScreen extends ConsumerWidget {
  const AnnouncementsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EmployeeAssignmentAnnouncementWire> wire =
        ref.watch(employeeAssignmentAnnouncementWireProvider);
    final AuthSnapshot session = ref.watch(boilerplateAuthSnapshotProvider);

    if (wire.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (wire.hasError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(NorthstarSpacing.space24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Could not load your profile for announcements.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                FilledButton(
                  onPressed: () async {
                    await ref
                        .read(
                          employeeAssignmentAnnouncementWireProvider.notifier,
                        )
                        .clearPersistedRecipientCache();
                    ref.invalidate(employeeAssignmentAnnouncementWireProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!session.isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(NorthstarSpacing.space24),
            child: Text(
              'Sign in to view announcements.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        if (c.maxWidth >= AnnouncementsLayoutTokens.homeWideMinWidth) {
          return const AnnouncementsHomeWebScreen();
        }
        return const AnnouncementsHomeMobileScreen();
      },
    );
  }
}
