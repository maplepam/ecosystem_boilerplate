import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/entities/announcement.dart';
import 'package:meta/meta.dart';

/// Parameters for **one** paged read of the published list (what the app means
/// by “give me this slice”). The **data** layer maps this to the wire JSON
/// (`announcements_list_request_body.dart`).
@immutable
final class AnnouncementsListPageQuery {
  const AnnouncementsListPageQuery({
    required this.offset,
    required this.limit,
    required this.recipientWire,
    this.categoryFilter,
  });

  final int offset;
  final int limit;

  /// Leave-management + identity bundle for emapta-style `recipients` on
  /// `POST …/published/list|detail`.
  final EmployeeAssignmentAnnouncementWire recipientWire;

  /// When set, the HTTP body sends `categories` so the server filters.
  final AnnouncementCategory? categoryFilter;
}
