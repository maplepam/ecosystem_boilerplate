import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/data/dtos/announcement_dto.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnnouncementDto.fromJson', () {
    test('maps snake_case and announcement_id', () {
      final AnnouncementDto dto = AnnouncementDto.fromJson(<String, dynamic>{
        'announcement_id': '42',
        'title': 'Hello',
        'summary': 'Short',
        'body': 'Full body',
        'published_at': '2025-03-15T10:00:00.000Z',
        'category': 'hr',
      });
      expect(dto.id, '42');
      expect(dto.title, 'Hello');
      expect(dto.summary, 'Short');
      expect(dto.body, 'Full body');
      expect(dto.category, AnnouncementCategory.hr);
      final Announcement domain = dto.toDomain();
      expect(domain.id, '42');
      expect(domain.isRead, false);
    });

    test('toDomain merges serverIsRead', () {
      final AnnouncementDto dto = AnnouncementDto(
        id: '1',
        title: 'T',
        summary: 'S',
        body: 'B',
        publishedAt: DateTime.utc(2025, 1, 1),
        category: AnnouncementCategory.company,
        priority: AnnouncementPriority.standard,
        serverIsRead: true,
      );
      expect(dto.toDomain().isRead, true);
      expect(dto.toDomain(isRead: false).isRead, true);
    });
  });

  group('AnnouncementDto.fromEmaptaPublishedItem', () {
    test('uses message as body and announcement_id', () {
      final AnnouncementDto dto = AnnouncementDto.fromEmaptaPublishedItem(
        <String, dynamic>{
          'announcement_id': '99',
          'title': 'Emapta title',
          'message': 'Emapta message body',
          'published_at': '2025-01-01T12:00:00.000Z',
          'categories': <String>['it'],
          'is_read': false,
        },
      );
      expect(dto.id, '99');
      expect(dto.body, 'Emapta message body');
      expect(dto.category, AnnouncementCategory.it);
      expect(dto.serverIsRead, false);
    });

    test('is_feature maps to important priority', () {
      final AnnouncementDto dto = AnnouncementDto.fromEmaptaPublishedItem(
        <String, dynamic>{
          'announcement_id': '1',
          'title': 'Feat',
          'message': 'm',
          'published_at': '2025-01-01T12:00:00.000Z',
          'is_feature': true,
        },
      );
      expect(dto.priority, AnnouncementPriority.important);
    });

    test('reads title, content, publish_at from channels[0] when root is sparse',
        () {
      final AnnouncementDto dto = AnnouncementDto.fromEmaptaPublishedItem(
        <String, dynamic>{
          'id': 'b8448c41-dc0e-4de5-bfd4-cf19e69d65b0',
          'sender': 'Global Technology Solutions',
          'categories': <String>['others'],
          'sub_content': '',
          'is_read': false,
          'channels': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'Test Announcement With Application Type 3',
              'content': '<h1>Hello World</h1>',
              'publish_at': '2025-06-03T05:12:00.000Z',
              'channel_type': 'announcement',
            },
          ],
        },
      );
      expect(dto.id, 'b8448c41-dc0e-4de5-bfd4-cf19e69d65b0');
      expect(dto.title, 'Test Announcement With Application Type 3');
      expect(dto.body, '<h1>Hello World</h1>');
      expect(dto.summary, 'Hello World');
      expect(dto.publishedAt, DateTime.parse('2025-06-03T05:12:00.000Z'));
      expect(dto.category, AnnouncementCategory.others);
      expect(dto.authorName, 'Global Technology Solutions');
    });

    test('thumbnailAssetKey from channels[0] when root thumbnail fields null', () {
      final AnnouncementDto dto = AnnouncementDto.fromEmaptaPublishedItem(
        <String, dynamic>{
          'id': '1',
          'thumbnail_id': null,
          'channels': <Map<String, dynamic>>[
            <String, dynamic>{
              'title': 'T',
              'content': 'c',
              'publish_at': '2025-01-01T12:00:00.000Z',
              'thumbnail_id': 'asset-uuid-from-channel',
            },
          ],
        },
      );
      expect(dto.thumbnailAssetKey, 'asset-uuid-from-channel');
    });
  });
}
