import 'package:meta/meta.dart';

/// Company announcements (emapta-style feed + detail + read state).
@immutable
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.publishedAt,
    required this.category,
    this.priority = AnnouncementPriority.standard,
    this.authorName,
    this.actionUrl,
    this.actionLabel,
    this.thumbnailAssetKey,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final DateTime publishedAt;
  final AnnouncementCategory category;
  final AnnouncementPriority priority;
  final String? authorName;
  final String? actionUrl;
  final String? actionLabel;

  /// `thumbnail_id` / `content_image_id` from announcement-bl list payload;
  /// resolved to a URL via [AnnouncementMediaRepository.resolveAssetUrls].
  final String? thumbnailAssetKey;

  final bool isRead;

  Announcement copyWith({
    String? id,
    String? title,
    String? summary,
    String? body,
    DateTime? publishedAt,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
    String? authorName,
    String? actionUrl,
    String? actionLabel,
    String? thumbnailAssetKey,
    bool? isRead,
  }) {
    return Announcement(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      publishedAt: publishedAt ?? this.publishedAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      authorName: authorName ?? this.authorName,
      actionUrl: actionUrl ?? this.actionUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      thumbnailAssetKey: thumbnailAssetKey ?? this.thumbnailAssetKey,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum AnnouncementPriority { standard, important }

enum AnnouncementCategory {
  company,
  hr,
  it,
  facilities,
  product,
  others,
}

extension AnnouncementCategoryX on AnnouncementCategory {
  String get label => switch (this) {
        AnnouncementCategory.company => 'Company',
        AnnouncementCategory.hr => 'HR',
        AnnouncementCategory.it => 'IT',
        AnnouncementCategory.facilities => 'Facilities',
        AnnouncementCategory.product => 'Product',
        AnnouncementCategory.others => 'Others',
      };
}

/// Shared relative date labels for list + detail.
String formatAnnouncementDate(DateTime publishedAt) {
  final DateTime local = publishedAt.toLocal();
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime day = DateTime(local.year, local.month, local.day);
  final int diffDays = today.difference(day).inDays;
  if (diffDays == 0) {
    return 'Today';
  }
  if (diffDays == 1) {
    return 'Yesterday';
  }
  if (diffDays < 7) {
    return '${diffDays}d ago';
  }
  final String m = local.month.toString().padLeft(2, '0');
  final String d = local.day.toString().padLeft(2, '0');
  return '${local.year}-$m-$d';
}
