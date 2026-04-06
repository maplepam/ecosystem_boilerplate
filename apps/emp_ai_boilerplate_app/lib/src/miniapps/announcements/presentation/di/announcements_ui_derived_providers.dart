import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search text for **client-side** filtering only (title/body/summary).
/// Does not appear in `announcementsPublishedListBody` unless you extend the API.
final announcementsSearchQueryProvider = StateProvider<String>(
  (ref) => '',
);

/// Drives **server-side** `categories` in the list POST body (rebuilds cached
/// queries that include this in their key).
final announcementsCategoryFilterProvider =
    StateProvider<AnnouncementCategory?>(
  (ref) => null,
);
