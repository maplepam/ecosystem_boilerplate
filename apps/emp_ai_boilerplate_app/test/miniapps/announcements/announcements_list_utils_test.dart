import 'package:cached_query/cached_query.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/utils/announcements_list_utils.dart';
import 'package:flutter_test/flutter_test.dart';

Announcement _a({
  required String id,
  required String title,
  String summary = '',
  String body = '',
  bool isRead = false,
}) {
  return Announcement(
    id: id,
    title: title,
    summary: summary.isEmpty ? title : summary,
    body: body.isEmpty ? title : body,
    publishedAt: DateTime.utc(2025, 6, 1),
    category: AnnouncementCategory.company,
    isRead: isRead,
  );
}

void main() {
  group('flattenAnnouncementInfinitePages', () {
    test('null or empty pages yields empty list', () {
      expect(flattenAnnouncementInfinitePages(null), isEmpty);
      expect(
        flattenAnnouncementInfinitePages(
          InfiniteQueryData<List<Announcement>, int>(pages: <List<Announcement>>[], args: <int>[]),
        ),
        isEmpty,
      );
    });

    test('concatenates pages in order', () {
      final Announcement a1 = _a(id: '1', title: 'A');
      final Announcement a2 = _a(id: '2', title: 'B');
      final Announcement a3 = _a(id: '3', title: 'C');
      final InfiniteQueryData<List<Announcement>, int> data =
          InfiniteQueryData<List<Announcement>, int>(
        pages: <List<Announcement>>[
          <Announcement>[a1, a2],
          <Announcement>[a3],
        ],
        args: <int>[0, 1],
      );
      expect(
        flattenAnnouncementInfinitePages(data),
        <Announcement>[a1, a2, a3],
      );
    });
  });

  group('applyAnnouncementsSearchFilter', () {
    final List<Announcement> items = <Announcement>[
      _a(id: '1', title: 'Alpha news', body: 'body one'),
      _a(id: '2', title: 'Beta', summary: 'gamma summary'),
      _a(id: '3', title: 'Other', body: 'contains ALPHA in body'),
    ];

    test('empty or whitespace query returns all', () {
      expect(applyAnnouncementsSearchFilter(items, ''), items);
      expect(applyAnnouncementsSearchFilter(items, '   '), items);
    });

    test('matches title, summary, or body case-insensitively', () {
      expect(
        applyAnnouncementsSearchFilter(items, 'alpha').map((Announcement e) => e.id),
        <String>['1', '3'],
      );
      expect(
        applyAnnouncementsSearchFilter(items, 'gamma').single.id,
        '2',
      );
    });

    test('no match returns empty', () {
      expect(applyAnnouncementsSearchFilter(items, 'zzz'), isEmpty);
    });
  });

  group('countUnreadAnnouncements', () {
    test('counts only isRead == false', () {
      final List<Announcement> items = <Announcement>[
        _a(id: '1', title: 'a', isRead: false),
        _a(id: '2', title: 'b', isRead: true),
        _a(id: '3', title: 'c', isRead: false),
      ];
      expect(countUnreadAnnouncements(items), 2);
      expect(countUnreadAnnouncements(<Announcement>[]), 0);
    });
  });
}
