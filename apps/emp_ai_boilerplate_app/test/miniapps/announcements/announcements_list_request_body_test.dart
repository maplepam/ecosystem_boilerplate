import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/announcements_list_request_body.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('announcementsPublishedListBody', () {
    test('matches emapta V2 list shape (status, channels, recipient types)', () {
      const EmployeeAssignmentAnnouncementWire wire =
          EmployeeAssignmentAnnouncementWire(
        companyId: 'co-1',
        employeeAssignmentId: 'ea-1',
        profileId: 'prof-1',
        fallbackUsername: 'user',
      );
      final Map<String, dynamic> body = announcementsPublishedListBody(
        const AnnouncementsListPageQuery(
          offset: 10,
          limit: 25,
          recipientWire: wire,
        ),
      );
      expect(body['offset'], 10);
      expect(body['limit'], 25);
      expect(body['status'], 'published');
      expect(body['is_feature'], isNull);
      expect(body['categories'], isNull);
      expect(body['channels'], <String>['announcement']);
      expect(body['recipients'], <Map<String, dynamic>>[
        <String, dynamic>{
          'recipient_value': 'all',
          'recipient_type': 'client',
        },
        <String, dynamic>{
          'recipient_value': 'all',
          'recipient_type': 'department',
        },
        <String, dynamic>{
          'recipient_value': 'co-1',
          'recipient_type': 'client',
        },
        <String, dynamic>{
          'recipient_value': 'ea-1',
          'recipient_type': 'talent',
        },
      ]);
    });

    test('talent uses profile_id when employee_assignment_id empty', () {
      const EmployeeAssignmentAnnouncementWire wire =
          EmployeeAssignmentAnnouncementWire(
        profileId: '231896.user',
        fallbackUsername: 'u',
      );
      final Map<String, dynamic> body = announcementsPublishedListBody(
        const AnnouncementsListPageQuery(
          offset: 0,
          limit: 20,
          recipientWire: wire,
        ),
      );
      expect(body['recipients'], <Map<String, dynamic>>[
        <String, dynamic>{
          'recipient_value': 'all',
          'recipient_type': 'client',
        },
        <String, dynamic>{
          'recipient_value': 'all',
          'recipient_type': 'department',
        },
        <String, dynamic>{
          'recipient_value': '231896.user',
          'recipient_type': 'talent',
        },
      ]);
    });

    test('sets categories when filter present', () {
      const EmployeeAssignmentAnnouncementWire wire =
          EmployeeAssignmentAnnouncementWire(
        fallbackUsername: 'x',
      );
      final Map<String, dynamic> body = announcementsPublishedListBody(
        const AnnouncementsListPageQuery(
          offset: 0,
          limit: 20,
          recipientWire: wire,
          categoryFilter: AnnouncementCategory.hr,
        ),
      );
      expect(body['categories'], <String>['hr']);
    });
  });

  group('announcementsPublishedDetailBody', () {
    test('maps announcement_id and recipients from wire', () {
      const EmployeeAssignmentAnnouncementWire wire =
          EmployeeAssignmentAnnouncementWire(
        employeeAssignmentId: 'talent-id',
        fallbackUsername: 'u',
      );
      final Map<String, dynamic> body = announcementsPublishedDetailBody(
        'abc-123',
        wire,
      );
      expect(body['announcement_id'], 'abc-123');
      expect(body['channels'], <String>['announcement']);
      expect(body['recipients'], <Map<String, dynamic>>[
        <String, dynamic>{
          'recipient_value': 'all',
          'recipient_type': 'client',
        },
        <String, dynamic>{
          'recipient_value': 'all',
          'recipient_type': 'department',
        },
        <String, dynamic>{
          'recipient_value': 'talent-id',
          'recipient_type': 'talent',
        },
      ]);
    });
  });
}
