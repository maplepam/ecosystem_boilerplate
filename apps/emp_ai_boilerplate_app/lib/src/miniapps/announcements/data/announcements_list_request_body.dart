import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/entities/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/entities/announcements_list_page_query.dart';

/// JSON body for `POST …/announcement/published/list` (V2), aligned with
/// [EmpFetchAnnouncementsParams.toJsonV2] and [AnnouncementRecipient] in emapta
/// `announcement_module`.
Map<String, dynamic> announcementsPublishedListBody(
  AnnouncementsListPageQuery query,
) {
  return <String, dynamic>{
    'offset': query.offset,
    'limit': query.limit,
    'status': 'published',
    'is_read': null,
    'title': null,
    'is_feature': null,
    'categories': query.categoryFilter == null
        ? null
        : <String>[_announcementCategoryApiValue(query.categoryFilter!)],
    'channels': <String>['announcement'],
    'recipients': announcementRecipientsFromWire(query.recipientWire),
    'client': null,
  };
}

/// Same shape as emapta `home_network_notifier` / `newsfeed_notifier` list
/// fetches: `all` client + department, optional company client, optional talent.
List<Map<String, dynamic>> announcementRecipientsFromWire(
  EmployeeAssignmentAnnouncementWire wire,
) {
  final String companyId = wire.companyId.trim();
  final String talentId = wire.talentRecipientValue.trim();
  return <Map<String, dynamic>>[
    <String, dynamic>{
      'recipient_value': 'all',
      'recipient_type': 'client',
    },
    <String, dynamic>{
      'recipient_value': 'all',
      'recipient_type': 'department',
    },
    if (companyId.isNotEmpty)
      <String, dynamic>{
        'recipient_value': companyId,
        'recipient_type': 'client',
      },
    if (talentId.isNotEmpty)
      <String, dynamic>{
        'recipient_value': talentId,
        'recipient_type': 'talent',
      },
  ];
}

/// Values aligned with [AnnouncementDto] / emapta category mapping.
String _announcementCategoryApiValue(AnnouncementCategory c) {
  return switch (c) {
    AnnouncementCategory.company => 'company',
    AnnouncementCategory.hr => 'hr',
    AnnouncementCategory.it => 'it',
    AnnouncementCategory.facilities => 'facilities',
    AnnouncementCategory.product => 'product',
    AnnouncementCategory.others => 'others',
  };
}

/// JSON body for `POST …/announcement/published/detail` (V2).
Map<String, dynamic> announcementsPublishedDetailBody(
  String announcementId,
  EmployeeAssignmentAnnouncementWire wire,
) {
  return <String, dynamic>{
    'announcement_id': announcementId,
    'channels': <String>['announcement'],
    'recipients': announcementRecipientsFromWire(wire),
    'client': null,
  };
}
