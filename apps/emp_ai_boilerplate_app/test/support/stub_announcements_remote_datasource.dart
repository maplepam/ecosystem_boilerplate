import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/datasources/announcements_remote_datasource.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/dtos/announcement_dto.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';

/// Offline stub for `ProviderScope` overrides when tests must not hit the network.
final class StubAnnouncementsRemoteDataSource
    implements AnnouncementsRemoteDataSource {
  StubAnnouncementsRemoteDataSource({List<AnnouncementDto>? items})
      : _items = items ?? _defaultItems;

  final List<AnnouncementDto> _items;

  static final List<AnnouncementDto> _defaultItems = <AnnouncementDto>[
    AnnouncementDto(
      id: 'stub-1',
      title: 'Stub announcement',
      summary: 'Override announcementsRemoteDataSourceProvider in tests.',
      body: 'Body',
      publishedAt: DateTime.utc(2024, 6, 1),
      category: AnnouncementCategory.company,
      priority: AnnouncementPriority.standard,
    ),
  ];

  @override
  Future<List<AnnouncementDto>> fetchPublishedListPage(
    AnnouncementsListPageQuery query,
  ) async {
    Iterable<AnnouncementDto> all = _items;
    if (query.categoryFilter != null) {
      all = all.where(
        (AnnouncementDto d) =>
            d.category == query.categoryFilter,
      );
    }
    final List<AnnouncementDto> list = all.toList(growable: false);
    final int start = query.offset.clamp(0, list.length);
    final int end = (start + query.limit).clamp(0, list.length);
    if (start >= list.length) {
      return <AnnouncementDto>[];
    }
    return list.sublist(start, end);
  }

  @override
  Future<AnnouncementDto?> fetchPublishedDetail(
    String announcementId,
    EmployeeAssignmentAnnouncementWire recipientWire,
  ) async {
    for (final AnnouncementDto d in _items) {
      if (d.id == announcementId) {
        return d;
      }
    }
    return null;
  }
}
