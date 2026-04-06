import 'dart:async';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_cached_query_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_ui_derived_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/utils/announcements_list_utils.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/widgets/announcements_feed_panel.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/widgets/announcements_home_filter_items.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Narrow layout: **infinite scroll** via [InfiniteQuery] + client search filter.
class AnnouncementsHomeMobileScreen extends ConsumerWidget {
  const AnnouncementsHomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final InfiniteQuery<List<Announcement>, int> query =
        ref.watch(announcementsInfiniteListQueryProvider);
    final String search = ref.watch(announcementsSearchQueryProvider);
    final AnnouncementCategory? selected =
        ref.watch(announcementsCategoryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: NorthstarSpacing.space8,
        title: NorthstarSearchField(
          hintText: 'Search title or body…',
          automationId: 'announcements_search',
          onChanged: (String v) =>
              ref.read(announcementsSearchQueryProvider.notifier).state = v,
        ),
        actions: <Widget>[
          QueryBuilder<InfiniteQueryStatus<List<Announcement>, int>>(
            query: query,
            builder: (BuildContext context,
                InfiniteQueryStatus<List<Announcement>, int> state) {
              final List<Announcement> flat = applyAnnouncementsSearchFilter(
                flattenAnnouncementInfinitePages(state.data),
                search,
              );
              final int unread = countUnreadAnnouncements(flat);
              final Widget icon = IconButton(
                tooltip: 'Refresh',
                onPressed: () => unawaited(query.refetch()),
                icon: const Icon(Icons.refresh),
              );
              if (unread <= 0) {
                return icon;
              }
              return Badge.count(
                count: unread,
                child: icon,
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              NorthstarSpacing.space16,
              NorthstarSpacing.space8,
              NorthstarSpacing.space16,
              0,
            ),
            child: NorthstarFilterChipStrip(
              items: announcementsHomeFilterItems(),
              selectedValue: selected?.name,
              onSelected: (String? v) {
                ref.read(announcementsCategoryFilterProvider.notifier).state =
                    v == null
                        ? null
                        : AnnouncementCategory.values.byName(v);
              },
            ),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Expanded(
            child: QueryBuilder<InfiniteQueryStatus<List<Announcement>, int>>(
              query: query,
              builder:
                  (BuildContext context, InfiniteQueryStatus<List<Announcement>, int> state) {
                final List<Announcement> flat =
                    flattenAnnouncementInfinitePages(state.data);
                final List<Announcement> visible =
                    applyAnnouncementsSearchFilter(flat, search);
                final bool initialLoading =
                    state is InfiniteQueryLoading<List<Announcement>, int> &&
                        state.isInitialFetch &&
                        flat.isEmpty;
                final bool fetchingMore =
                    state is InfiniteQueryLoading<List<Announcement>, int> &&
                        state.isFetchingNextPage;
                final Object? err = switch (state) {
                  InfiniteQueryError<List<Announcement>, int>(:final error) =>
                    error,
                  _ => null,
                };

                return AnnouncementsFeedPanel(
                  items: visible,
                  isInitialLoading: initialLoading,
                  isFetchingMore: fetchingMore,
                  error: err,
                  onRefresh: () => query.refetch(),
                  onOpenDetail: (Announcement a) =>
                      context.push('/announcements/detail/${a.id}'),
                  hasNextPage: query.hasNextPage(),
                  onLoadMore: query.hasNextPage()
                      ? () => unawaited(query.getNextPage())
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
