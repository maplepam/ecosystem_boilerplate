import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_announcement_wire.dart';
import 'package:emp_ai_boilerplate_app/src/integrations/employee_assignment/employee_assignment_profile_id_notifier.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/repositories/announcements_repository.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_data_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_ui_derived_providers.dart';
import 'package:emp_ai_foundation/emp_ai_foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// Matches all announcement list/detail [Query] / [InfiniteQuery] keys in this mini-app.
bool announcementsCachedQueryFilter(Object unencodedKey, String _) {
  return unencodedKey is Map && unencodedKey['scope'] == 'announcements';
}

/// Mobile infinite scroll: items per network page.
const int kAnnouncementsMobilePageSize = 20;

/// Web: 0-based page index (UI may show 1-based labels).
final announcementsWebPageIndexProvider = StateProvider<int>(
  (ref) => 0,
);

/// Web: rows per page (server `limit`).
final announcementsWebPageSizeProvider = StateProvider<int>(
  (ref) => 25,
);

String _announcementsRecipientCacheSegment(Ref ref) {
  final EmployeeAssignmentAnnouncementWire? wire = ref
      .watch(employeeAssignmentAnnouncementWireProvider)
      .valueOrNull;
  if (wire == null) {
    return '__pending__';
  }
  return wire.cacheSegment;
}

@immutable
final class AnnouncementsPagedCacheKey {
  const AnnouncementsPagedCacheKey({
    required this.pageIndex,
    required this.pageSize,
    required this.categoryFilter,
  });

  final int pageIndex;
  final int pageSize;
  final AnnouncementCategory? categoryFilter;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnnouncementsPagedCacheKey &&
          pageIndex == other.pageIndex &&
          pageSize == other.pageSize &&
          categoryFilter == other.categoryFilter;

  @override
  int get hashCode => Object.hash(pageIndex, pageSize, categoryFilter);
}

/// Infinite list for **narrow** layout; key includes category so changing the
/// chip rebuilds the query and refetches from page 0.
final announcementsInfiniteListQueryProvider =
    Provider<InfiniteQuery<List<Announcement>, int>>(
  (ref) {
    final AnnouncementCategory? cat =
        ref.watch(announcementsCategoryFilterProvider);
    const int pageSize = kAnnouncementsMobilePageSize;
    final AnnouncementsRepository repo = ref.watch(announcementsRepositoryProvider);
    return InfiniteQuery<List<Announcement>, int>(
      key: <String, Object?>{
        'scope': 'announcements',
        'mode': 'infinite',
        'pageSize': pageSize,
        'category': cat?.name ?? 'all',
        'recipient': _announcementsRecipientCacheSegment(ref),
      },
      queryFn: (int pageIndex) async {
        final EmployeeAssignmentAnnouncementWire wire = await ref.read(
          employeeAssignmentAnnouncementWireProvider.future,
        );
        final AppResult<List<Announcement>> r =
            await repo.loadPublishedAnnouncementsPage(
          AnnouncementsListPageQuery(
            offset: pageIndex * pageSize,
            limit: pageSize,
            recipientWire: wire,
            categoryFilter: cat,
          ),
        );
        return r.fold(
          onSuccess: (List<Announcement> v) => v,
          onFailure: (AppFailure<List<Announcement>> f) => throw f,
        );
      },
      getNextArg: (InfiniteQueryData<List<Announcement>, int>? data) {
        if (data == null || data.pages.isEmpty) {
          return 0;
        }
        final List<Announcement> last = data.lastPage!;
        if (last.isEmpty || last.length < pageSize) {
          return null;
        }
        return data.pages.length;
      },
    );
  },
);

/// Single **paged** list for **wide** layout (page index + page size + category).
final announcementsPublishedPagedListQueryProvider =
    Provider.family<Query<List<Announcement>>, AnnouncementsPagedCacheKey>(
  (ref, AnnouncementsPagedCacheKey key) {
    final AnnouncementsRepository repo = ref.watch(announcementsRepositoryProvider);
    return Query<List<Announcement>>(
      key: <String, Object?>{
        'scope': 'announcements',
        'mode': 'paged',
        'page': key.pageIndex,
        'limit': key.pageSize,
        'category': key.categoryFilter?.name ?? 'all',
        'recipient': _announcementsRecipientCacheSegment(ref),
      },
      queryFn: () async {
        final EmployeeAssignmentAnnouncementWire wire = await ref.read(
          employeeAssignmentAnnouncementWireProvider.future,
        );
        final AppResult<List<Announcement>> r =
            await repo.loadPublishedAnnouncementsPage(
          AnnouncementsListPageQuery(
            offset: key.pageIndex * key.pageSize,
            limit: key.pageSize,
            recipientWire: wire,
            categoryFilter: key.categoryFilter,
          ),
        );
        return r.fold(
          onSuccess: (List<Announcement> v) => v,
          onFailure: (AppFailure<List<Announcement>> f) => throw f,
        );
      },
    );
  },
);

/// Detail screen: one [Query] per announcement id.
final announcementsDetailQueryProvider =
    Provider.family<Query<Announcement>, String>(
  (ref, String id) {
    final AnnouncementsRepository repo = ref.watch(announcementsRepositoryProvider);
    return Query<Announcement>(
      key: <String, Object?>{
        'scope': 'announcements',
        'detail': id,
        'recipient': _announcementsRecipientCacheSegment(ref),
      },
      queryFn: () async {
        final EmployeeAssignmentAnnouncementWire wire = await ref.read(
          employeeAssignmentAnnouncementWireProvider.future,
        );
        final AppResult<Announcement> r =
            await repo.loadPublishedAnnouncementById(
          id,
          recipientWire: wire,
        );
        return r.fold(
          onSuccess: (Announcement v) => v,
          onFailure: (AppFailure<Announcement> f) => throw f,
        );
      },
    );
  },
);
