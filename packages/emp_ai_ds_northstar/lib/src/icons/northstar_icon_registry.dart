import 'northstar_icon_category.dart';
import 'northstar_icon_manifest.g.dart';
import 'northstar_icon_manifest_item.dart';

/// Lookup and search over [kNorthstarIconManifest].
abstract final class NorthstarIconRegistry {
  const NorthstarIconRegistry._();

  /// All bundled SVGs (order stable: path sort).
  static List<NorthstarIconManifestItem> get all =>
      List<NorthstarIconManifestItem>.unmodifiable(kNorthstarIconManifest);

  static NorthstarIconManifestItem? tryById(String id) {
    for (final NorthstarIconManifestItem e in kNorthstarIconManifest) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  static List<NorthstarIconManifestItem> inCategory(NorthstarIconCategory category) {
    return kNorthstarIconManifest
        .where((NorthstarIconManifestItem e) => e.category == category)
        .toList();
  }

  /// Case-insensitive match on [NorthstarIconManifestItem.id], asset path, and category title.
  static List<NorthstarIconManifestItem> search(String query) {
    final String q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return List<NorthstarIconManifestItem>.from(kNorthstarIconManifest);
    }
    return kNorthstarIconManifest.where((NorthstarIconManifestItem e) {
      if (e.id.contains(q)) {
        return true;
      }
      if (e.relativeAssetPath.toLowerCase().contains(q)) {
        return true;
      }
      if (e.category.catalogTitle.toLowerCase().contains(q)) {
        return true;
      }
      return false;
    }).toList();
  }
}
