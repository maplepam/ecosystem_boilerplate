/// Emapta `announcement_module` V2 paths on the **announcement-bl** host
/// (`notificationConnectionStringV2` + `/announcement/published/...`).
abstract final class AnnouncementsApiPaths {
  static const String publishedList = '/announcement/published/list';
  static const String publishedDetail = '/announcement/published/detail';
}
