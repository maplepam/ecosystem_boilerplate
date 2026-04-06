import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_read_local_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/dtos/announcement_dto.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/repositories/announcements_repository.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';

final class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  AnnouncementsRepositoryImpl(this._remote, this._readLocal);

  final AnnouncementsRemoteDataSource _remote;
  final AnnouncementsReadLocalDataSource _readLocal;

  static const int _detailFallbackScanLimit = 200;

  @override
  Future<AppResult<List<Announcement>>> loadPublishedAnnouncementsPage(
    AnnouncementsListPageQuery query,
  ) async {
    try {
      final Set<String> read = await _readLocal.readIds();
      final List<AnnouncementDto> dtos =
          await _remote.fetchPublishedListPage(query);
      final List<Announcement> list = dtos
          .map(
            (AnnouncementDto dto) =>
                dto.toDomain(isRead: read.contains(dto.id)),
          )
          .toList(growable: false);
      return AppSuccess<List<Announcement>>(list);
    } on Object catch (e, _) {
      return AppFailure<List<Announcement>>(
        code: 'announcements_page_load',
        message: e.toString(),
        cause: e,
      );
    }
  }

  @override
  Future<AppResult<Announcement>> loadPublishedAnnouncementById(
    String id, {
    required EmployeeAssignmentAnnouncementWire recipientWire,
  }) async {
    try {
      final Set<String> read = await _readLocal.readIds();
      final AnnouncementDto? detail = await _remote.fetchPublishedDetail(
        id,
        recipientWire,
      );
      if (detail != null) {
        return AppSuccess<Announcement>(
          detail.toDomain(isRead: read.contains(detail.id)),
        );
      }
      final List<AnnouncementDto> window = await _remote.fetchPublishedListPage(
        AnnouncementsListPageQuery(
          offset: 0,
          limit: _detailFallbackScanLimit,
          recipientWire: recipientWire,
          categoryFilter: null,
        ),
      );
      for (final AnnouncementDto dto in window) {
        if (dto.id == id) {
          return AppSuccess<Announcement>(
            dto.toDomain(isRead: read.contains(dto.id)),
          );
        }
      }
      return AppFailure<Announcement>(
        code: 'announcement_not_found',
        message: id,
      );
    } on Object catch (e, _) {
      return AppFailure<Announcement>(
        code: 'announcement_detail_load',
        message: e.toString(),
        cause: e,
      );
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await _readLocal.addReadId(id);
  }
}
