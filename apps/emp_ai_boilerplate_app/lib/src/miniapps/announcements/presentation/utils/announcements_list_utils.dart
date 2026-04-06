import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';

/// Merges all loaded infinite pages into one list (order preserved).
List<Announcement> flattenAnnouncementInfinitePages(
  InfiniteQueryData<List<Announcement>, int>? data,
) {
  if (data == null || data.pages.isEmpty) {
    return <Announcement>[];
  }
  return data.pages
      .expand((List<Announcement> page) => page)
      .toList(growable: false);
}

/// Client-side search only (does **not** change the API body). Category is
/// applied server-side via [AnnouncementsListPageQuery.categoryFilter].
List<Announcement> applyAnnouncementsSearchFilter(
  List<Announcement> items,
  String rawQuery,
) {
  final String trimmed = rawQuery.trim().toLowerCase();
  if (trimmed.isEmpty) {
    return items;
  }
  return items
      .where(
        (Announcement a) =>
            a.title.toLowerCase().contains(trimmed) ||
            a.summary.toLowerCase().contains(trimmed) ||
            a.body.toLowerCase().contains(trimmed),
      )
      .toList(growable: false);
}

int countUnreadAnnouncements(Iterable<Announcement> items) =>
    items.where((Announcement a) => !a.isRead).length;
