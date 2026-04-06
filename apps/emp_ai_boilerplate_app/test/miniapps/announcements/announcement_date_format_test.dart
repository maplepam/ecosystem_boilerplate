import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatAnnouncementDate', () {
    test('returns Today for same calendar day (local)', () {
      final DateTime now = DateTime.now();
      final DateTime local = now.toLocal();
      expect(formatAnnouncementDate(local), 'Today');
    });

    test('returns Yesterday for previous local day', () {
      final DateTime yesterday =
          DateTime.now().subtract(const Duration(days: 1));
      expect(formatAnnouncementDate(yesterday), 'Yesterday');
    });

    test('returns Nd ago within a week', () {
      final DateTime d = DateTime.now().subtract(const Duration(days: 3));
      expect(formatAnnouncementDate(d), '3d ago');
    });
  });
}
