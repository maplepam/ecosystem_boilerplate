import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';

abstract class AnnouncementsRepository {
  /// Fetches **one page** of the published list (`offset` / `limit` / optional
  /// server `categories` filter). Does not imply “full list in memory”.
  Future<AppResult<List<Announcement>>> loadPublishedAnnouncementsPage(
    AnnouncementsListPageQuery query,
  );

  /// Loads a **single** published item by id (detail endpoint first; may scan
  /// a small list window as fallback).
  Future<AppResult<Announcement>> loadPublishedAnnouncementById(
    String id, {
    required EmployeeAssignmentAnnouncementWire recipientWire,
  });

  Future<void> markAsRead(String id);
}
