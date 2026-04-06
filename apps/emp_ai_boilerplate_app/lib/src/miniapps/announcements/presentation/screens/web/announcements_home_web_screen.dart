import 'dart:async';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_cached_query_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_ui_derived_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/utils/announcements_list_utils.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/widgets/announcements_feed_panel.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/emp_ai_ds_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Wide layout: **horizontal category pills** (emapta newsfeed-style tabs) +
/// **pagination footer**, full-width feed (no side category rail).
///
/// Reference: `newsfeed_web_screen.dart` + `NewsfeedAnnouncementTabBarListWeb`
/// in emapta — tabs on top; boilerplate places pager at the **bottom** per UX.
class AnnouncementsHomeWebScreen extends ConsumerWidget {
  const AnnouncementsHomeWebScreen({super.key});

  static const List<int> _pageSizeChoices = <int>[10, 25, 50];

  static List<AnnouncementCategory?> get _categoryTabs =>
      <AnnouncementCategory?>[
        null,
        ...AnnouncementCategory.values,
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int pageIndex = ref.watch(announcementsWebPageIndexProvider);
    final int pageSize = ref.watch(announcementsWebPageSizeProvider);
    final AnnouncementCategory? selected =
        ref.watch(announcementsCategoryFilterProvider);
    final String search = ref.watch(announcementsSearchQueryProvider);

    final AnnouncementsPagedCacheKey cacheKey = AnnouncementsPagedCacheKey(
      pageIndex: pageIndex,
      pageSize: pageSize,
      categoryFilter: selected,
    );
    final Query<List<Announcement>> query =
        ref.watch(announcementsPublishedPagedListQueryProvider(cacheKey));

    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 12,
        title: NorthstarSearchField(
          hintText: 'Search title or body…',
          automationId: 'announcements_search',
          onChanged: (String v) =>
              ref.read(announcementsSearchQueryProvider.notifier).state = v,
        ),
        actions: <Widget>[
          QueryBuilder<QueryStatus<List<Announcement>>>(
            query: query,
            builder:
                (BuildContext context, QueryStatus<List<Announcement>> state) {
              final List<Announcement>? rows = state.data;
              final List<Announcement> visible = rows == null
                  ? <Announcement>[]
                  : applyAnnouncementsSearchFilter(rows, search);
              final int unread = countUnreadAnnouncements(visible);
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
          Material(
            color: ns.surfaceContainerLow,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                20,
                NorthstarSpacing.space12,
                20,
                NorthstarSpacing.space12,
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _categoryTabs.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: NorthstarSpacing.space12),
                    _CategoryPill(
                      label: i == 0 ? 'All' : _categoryTabs[i]!.label,
                      selected: _categoryTabs[i] == selected,
                      onTap: () {
                        ref
                            .read(announcementsCategoryFilterProvider.notifier)
                            .state = _categoryTabs[i];
                        ref
                            .read(announcementsWebPageIndexProvider.notifier)
                            .state = 0;
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: QueryBuilder<QueryStatus<List<Announcement>>>(
              query: query,
              builder: (BuildContext context,
                  QueryStatus<List<Announcement>> state) {
                final List<Announcement> rows = state.data ?? <Announcement>[];
                final List<Announcement> visible =
                    applyAnnouncementsSearchFilter(rows, search);
                final bool loading =
                    state is QueryLoading<List<Announcement>> &&
                        state.isInitialFetch &&
                        rows.isEmpty;
                final Object? err = switch (state) {
                  QueryError<List<Announcement>>(:final error) => error,
                  _ => null,
                };

                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    NorthstarSpacing.space16,
                    0,
                    NorthstarSpacing.space16,
                    0,
                  ),
                  child: AnnouncementsFeedPanel(
                    items: visible,
                    isInitialLoading: loading,
                    isFetchingMore: false,
                    error: err,
                    onRefresh: () => query.refetch(),
                    onOpenDetail: (Announcement a) =>
                        context.push('/announcements/detail/${a.id}'),
                  ),
                );
              },
            ),
          ),
          QueryBuilder<QueryStatus<List<Announcement>>>(
            query: query,
            builder:
                (BuildContext context, QueryStatus<List<Announcement>> state) {
              final List<Announcement> rows = state.data ?? <Announcement>[];
              final bool canNext = rows.length >= pageSize;
              final bool likelyEnd = rows.isNotEmpty && !canNext;

              return Material(
                elevation: 2,
                color: ns.surfaceContainerLow,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      NorthstarSpacing.space12,
                      20,
                      NorthstarSpacing.space12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (likelyEnd)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: NorthstarSpacing.space8,
                            ),
                            child: Text(
                              'End of list for this filter (page returned fewer than $pageSize items).',
                              style: NorthstarTextRole.bodySmall.style(context),
                            ),
                          ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: <Widget>[
                            Text(
                              'Rows per page',
                              style: NorthstarTextRole.label.style(context),
                            ),
                            DropdownButton<int>(
                              value: pageSize,
                              items: _pageSizeChoices
                                  .map(
                                    (int n) => DropdownMenuItem<int>(
                                      value: n,
                                      child: Text('$n'),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (int? v) {
                                if (v == null) {
                                  return;
                                }
                                ref
                                    .read(announcementsWebPageSizeProvider
                                        .notifier)
                                    .state = v;
                                ref
                                    .read(announcementsWebPageIndexProvider
                                        .notifier)
                                    .state = 0;
                              },
                            ),
                            Text(
                              'Page ${pageIndex + 1}',
                              style: NorthstarTextRole.label.style(context),
                            ),
                            IconButton(
                              tooltip: 'Previous page',
                              onPressed: pageIndex > 0
                                  ? () {
                                      ref
                                          .read(
                                            announcementsWebPageIndexProvider
                                                .notifier,
                                          )
                                          .state = pageIndex - 1;
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            IconButton(
                              tooltip: 'Next page',
                              onPressed: canNext
                                  ? () {
                                      ref
                                          .read(
                                            announcementsWebPageIndexProvider
                                                .notifier,
                                          )
                                          .state = pageIndex + 1;
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Pill-shaped tab (aligned with emapta `AnnoucementTabWidget` / `TabWidgetWeb`).
class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens tokens = NorthstarColorTokens.of(context);
    final TextStyle? base = Theme.of(context).textTheme.labelLarge;

    return Material(
      color: selected ? tokens.primary : tokens.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Text(
            label,
            style: base?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? tokens.onPrimary : tokens.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
