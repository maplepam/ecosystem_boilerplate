import 'package:cached_query_flutter/cached_query_flutter.dart';

/// Drops in-memory [CachedQuery] entries and persisted query storage (if
/// configured). Call after sign-out so the next session does not reuse stale
/// HTTP/query data.
Future<void> boilerplateClearHostCaches() async {
  CachedQuery.instance.deleteCache(deleteStorage: true);
}
