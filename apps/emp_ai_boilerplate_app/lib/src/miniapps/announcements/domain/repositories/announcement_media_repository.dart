/// Resolves announcement **asset keys** (`thumbnail_id` / `content_image_id`)
/// to displayable URLs via emapta **announcement-bl**
/// `POST /media/assets/files` (`asset_keys`), same as
/// `FetchMediaAssetByKeyDatasourceImpl.fetchV2` in `announcement_module`.
abstract class AnnouncementMediaRepository {
  /// One batched request for all keys; returns map **assetKey → URL** (or null).
  Future<Map<String, String?>> resolveAssetUrls(Iterable<String> assetKeys);
}
