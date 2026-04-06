import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/entities/announcement.dart';
import 'package:meta/meta.dart';

/// Maps typical REST / BFF shapes (emapta-style) into [Announcement].
@immutable
final class AnnouncementDto {
  const AnnouncementDto({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.publishedAt,
    required this.category,
    required this.priority,
    this.authorName,
    this.actionUrl,
    this.actionLabel,
    this.thumbnailAssetKey,
    this.serverIsRead,
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

  /// Pass to `POST …/media/assets/files` as one of `asset_keys`.
  final String? thumbnailAssetKey;

  /// When set (emapta published API), merged with local read IDs in repository.
  final bool? serverIsRead;

  /// Accepts snake_case or camelCase keys; `body` falls back to `content`,
  /// `message`, or `description`.
  factory AnnouncementDto.fromJson(Map<String, dynamic> json) {
    final String id = _string(json, const <String>['id', 'announcement_id']);
    final String title = _string(json, const <String>['title', 'subject']);
    final String summary = _string(
      json,
      const <String>['summary', 'subtitle', 'excerpt', 'preview'],
    );
    final String body = _string(
      json,
      const <String>['body', 'content', 'message', 'description', 'html'],
    );
    final DateTime publishedAt = _date(
      json,
      const <String>['published_at', 'publishedAt', 'created_at', 'createdAt'],
    );
    final String? thumb = _optionalString(
      json,
      const <String>[
        'thumbnail_id',
        'thumbnailId',
        'content_image_id',
        'contentImageId',
      ],
    );
    return AnnouncementDto(
      id: id,
      title: title.isEmpty ? 'Untitled' : title,
      summary: summary.isEmpty && body.isNotEmpty
          ? body.length > 160
              ? '${body.substring(0, 160)}…'
              : body
          : summary,
      body: body.isEmpty ? summary : body,
      publishedAt: publishedAt,
      category: _category(json),
      priority: _priority(json),
      authorName: _optionalString(
        json,
        const <String>['author_name', 'authorName', 'author', 'from'],
      ),
      actionUrl: _optionalString(
        json,
        const <String>['action_url', 'actionUrl', 'link_url', 'url'],
      ),
      actionLabel: _optionalString(
        json,
        const <String>['action_label', 'actionLabel', 'link_label', 'cta'],
      ),
      thumbnailAssetKey: thumb,
    );
  }

  /// Maps one item from emapta `POST /announcement/published/list|detail`
  /// (`AnnouncementContent`). Title and body usually live on the first
  /// `channels[]` row (`title`, `content`, `publish_at`), not on the parent.
  factory AnnouncementDto.fromEmaptaPublishedItem(Map<String, dynamic> json) {
    final Map<String, dynamic>? channel = _emaptaPrimaryChannel(json);
    final String id = _emaptaAnnouncementId(json);
    final String titleRaw = _emaptaStringPreferChannel(
      json,
      channel,
      const <String>['title', 'subject'],
    );
    final String title = titleRaw.isEmpty ? 'Untitled' : titleRaw;
    final String fromChannel = _emaptaStringPreferChannel(
      json,
      channel,
      const <String>['content', 'message', 'body', 'html', 'description'],
    );
    final String subContent = _string(json, const <String>['sub_content', 'subContent']);
    final String body = fromChannel.isNotEmpty ? fromChannel : subContent;
    final String summary = _emaptaSummaryPreview(body, title);
    final DateTime publishedAt = _emaptaPublishedAt(json, channel);
    final bool? serverRead = json['is_read'] is bool
        ? json['is_read'] as bool
        : null;
    final String? thumbKey = _emaptaThumbnailAssetKey(json, channel);
    return AnnouncementDto(
      id: id.isEmpty ? 'unknown' : id,
      title: title,
      summary: summary,
      body: body.isEmpty ? title : body,
      publishedAt: publishedAt,
      category: _categoryFromEmapta(json),
      priority: _priorityEmapta(json),
      authorName: (json['sender'] as String?)?.trim(),
      actionUrl: null,
      actionLabel: null,
      thumbnailAssetKey: thumbKey,
      serverIsRead: serverRead,
    );
  }

  Announcement toDomain({bool isRead = false}) {
    return Announcement(
      id: id,
      title: title,
      summary: summary,
      body: body,
      publishedAt: publishedAt,
      category: category,
      priority: priority,
      authorName: authorName,
      actionUrl: actionUrl,
      actionLabel: actionLabel,
      thumbnailAssetKey: thumbnailAssetKey,
      isRead: isRead || (serverIsRead == true),
    );
  }
}

String? _emaptaThumbnailAssetKey(
  Map<String, dynamic> json,
  Map<String, dynamic>? channel,
) {
  const List<String> keys = <String>[
    'thumbnail_id',
    'thumbnailId',
    'content_image_id',
    'contentImageId',
  ];
  final String root = _string(json, keys);
  if (root.isNotEmpty) {
    return root;
  }
  if (channel != null) {
    final String fromChannel = _string(channel, keys);
    if (fromChannel.isNotEmpty) {
      return fromChannel;
    }
  }
  return null;
}

Map<String, dynamic>? _emaptaPrimaryChannel(Map<String, dynamic> json) {
  final Object? raw = json['channels'];
  if (raw is! List<dynamic> || raw.isEmpty) {
    return null;
  }
  for (final Object? e in raw) {
    if (e is Map<String, dynamic>) {
      return e;
    }
    if (e is Map) {
      return Map<String, dynamic>.from(e);
    }
  }
  return null;
}

String _emaptaStringPreferChannel(
  Map<String, dynamic> json,
  Map<String, dynamic>? channel,
  List<String> keys,
) {
  if (channel != null) {
    for (final String k in keys) {
      final Object? v = channel[k];
      if (v != null) {
        final String s = (v is String ? v : v.toString()).trim();
        if (s.isNotEmpty) {
          return s;
        }
      }
    }
  }
  for (final String k in keys) {
    final Object? v = json[k];
    if (v != null) {
      final String s = (v is String ? v : v.toString()).trim();
      if (s.isNotEmpty) {
        return s;
      }
    }
  }
  return '';
}

DateTime _emaptaPublishedAt(
  Map<String, dynamic> json,
  Map<String, dynamic>? channel,
) {
  const List<String> keys = <String>[
    'publish_at',
    'publishAt',
    'published_at',
    'publishedAt',
    'created_at',
    'createdAt',
  ];
  if (channel != null) {
    for (final String k in keys) {
      final Object? v = channel[k];
      if (v is String && v.isNotEmpty) {
        final DateTime? d = DateTime.tryParse(v);
        if (d != null) {
          return d;
        }
      }
    }
  }
  return _date(json, keys);
}

String _emaptaSummaryPreview(String body, String title) {
  if (body.isEmpty) {
    return title;
  }
  if (body.contains('<')) {
    final String plain = body
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.length <= 160) {
      return plain;
    }
    return '${plain.substring(0, 160)}…';
  }
  if (body.length > 160) {
    return '${body.substring(0, 160)}…';
  }
  return body;
}

String _emaptaAnnouncementId(Map<String, dynamic> json) {
  final Object? aid = json['announcement_id'];
  final Object? id = json['id'];
  if (aid != null && aid.toString().trim().isNotEmpty) {
    return aid.toString().trim();
  }
  if (id != null) {
    return id.toString().trim();
  }
  return '';
}

AnnouncementCategory _categoryFromEmapta(Map<String, dynamic> json) {
  final Object? cats = json['categories'];
  if (cats is List && cats.isNotEmpty) {
    final String raw = cats.first.toString().toLowerCase();
    return _categoryLabelToEnum(raw);
  }
  return _category(json);
}

AnnouncementCategory _categoryLabelToEnum(String raw) {
  return switch (raw) {
    'hr' || 'people' || 'talent' => AnnouncementCategory.hr,
    'it' || 'tech' || 'engineering' || 'systems' => AnnouncementCategory.it,
    'facilities' || 'office' || 'ops' => AnnouncementCategory.facilities,
    'product' || 'release' => AnnouncementCategory.product,
    'others' || 'other' => AnnouncementCategory.others,
    'company' => AnnouncementCategory.company,
    _ => AnnouncementCategory.company,
  };
}

AnnouncementPriority _priorityEmapta(Map<String, dynamic> json) {
  if (json['is_feature'] == true) {
    return AnnouncementPriority.important;
  }
  return _priority(json);
}

String _string(Map<String, dynamic> json, List<String> keys) {
  for (final String k in keys) {
    final Object? v = json[k];
    if (v != null) {
      final String s = v.toString().trim();
      if (s.isNotEmpty) {
        return s;
      }
    }
  }
  return '';
}

String? _optionalString(Map<String, dynamic> json, List<String> keys) {
  final String s = _string(json, keys);
  return s.isEmpty ? null : s;
}

DateTime _date(Map<String, dynamic> json, List<String> keys) {
  for (final String k in keys) {
    final Object? v = json[k];
    if (v is String && v.isNotEmpty) {
      final DateTime? parsed = DateTime.tryParse(v);
      if (parsed != null) {
        return parsed;
      }
    }
  }
  final String idStr = _string(json, const <String>['id', 'announcement_id']);
  final int? id = int.tryParse(idStr);
  if (id != null) {
    return DateTime.utc(2024, 1, 1).add(Duration(days: id % 240));
  }
  return DateTime.now();
}

AnnouncementCategory _category(Map<String, dynamic> json) {
  final String raw = _string(
    json,
    const <String>['category', 'type', 'channel', 'department'],
  ).toLowerCase();
  if (raw.isNotEmpty) {
    return _categoryLabelToEnum(raw);
  }
  final Object? uid = json['userId'] ?? json['user_id'];
  final int? n = uid is int ? uid : int.tryParse(uid?.toString() ?? '');
  if (n != null) {
    return switch (n % 5) {
      0 => AnnouncementCategory.company,
      1 => AnnouncementCategory.hr,
      2 => AnnouncementCategory.it,
      3 => AnnouncementCategory.facilities,
      _ => AnnouncementCategory.product,
    };
  }
  return AnnouncementCategory.company;
}

AnnouncementPriority _priority(Map<String, dynamic> json) {
  if (json['is_feature'] == true) {
    return AnnouncementPriority.important;
  }
  final String raw = _string(
    json,
    const <String>['priority', 'severity', 'level'],
  ).toLowerCase();
  if (raw.contains('important') ||
      raw == 'high' ||
      raw == 'critical' ||
      raw == 'alert') {
    return AnnouncementPriority.important;
  }
  return AnnouncementPriority.standard;
}
