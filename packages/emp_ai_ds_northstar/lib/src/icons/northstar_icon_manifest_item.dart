import 'package:flutter/foundation.dart';

import 'northstar_icon_category.dart';

/// One bundled SVG under [assets/northstar_icons/].
@immutable
class NorthstarIconManifestItem {
  const NorthstarIconManifestItem({
    required this.id,
    required this.relativeAssetPath,
    required this.category,
  });

  /// Stable slug (search + samples).
  final String id;

  /// Path relative to package root, e.g. `assets/northstar_icons/Icon=foo.svg`.
  final String relativeAssetPath;

  final NorthstarIconCategory category;
}
