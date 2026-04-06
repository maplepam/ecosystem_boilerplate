import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_cached_query_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_data_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Persists read state then **invalidates** announcement [cached_query] entries
/// so list/detail refetch with updated read flags.
final class MarkAnnouncementReadNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> markRead(String announcementId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(announcementsRepositoryProvider).markAsRead(announcementId);
      await CachedQuery.instance.invalidateCache(
        filterFn: announcementsCachedQueryFilter,
      );
    });
  }
}

final markAnnouncementReadNotifierProvider =
    AsyncNotifierProvider.autoDispose<MarkAnnouncementReadNotifier, void>(
  MarkAnnouncementReadNotifier.new,
);
