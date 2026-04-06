import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';

/// Shared between mobile (strip) and web (can map labels similarly).
List<NorthstarFilterChipStripItem> announcementsHomeFilterItems() {
  return <NorthstarFilterChipStripItem>[
    const NorthstarFilterChipStripItem(value: null, label: 'All'),
    ...AnnouncementCategory.values.map(
      (AnnouncementCategory c) => NorthstarFilterChipStripItem(
        value: c.name,
        label: c.label,
      ),
    ),
  ];
}
