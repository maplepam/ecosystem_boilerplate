import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/dtos/announcement_dto.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';

abstract class AnnouncementsRemoteDataSource {
  Future<List<AnnouncementDto>> fetchPublishedListPage(
    AnnouncementsListPageQuery query,
  );

  /// `POST /announcement/published/detail`; returns `null` if payload has no data.
  Future<AnnouncementDto?> fetchPublishedDetail(
    String announcementId,
    EmployeeAssignmentAnnouncementWire recipientWire,
  );
}
