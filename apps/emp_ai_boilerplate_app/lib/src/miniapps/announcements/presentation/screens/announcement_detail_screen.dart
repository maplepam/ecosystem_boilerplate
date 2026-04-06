import 'dart:async';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_cached_query_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/notifiers/mark_announcement_read_notifier.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/ui/announcements_layout_tokens.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/widgets/announcement_detail_content.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail uses **[cached_query] [Query]** per id (cached read + refetch).
class AnnouncementDetailScreen extends ConsumerStatefulWidget {
  const AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  final String announcementId;

  @override
  ConsumerState<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState
    extends ConsumerState<AnnouncementDetailScreen> {
  bool _markReadDispatched = false;

  @override
  Widget build(BuildContext context) {
    final Query<Announcement> query =
        ref.watch(announcementsDetailQueryProvider(widget.announcementId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Announcement',
          style: NorthstarTextRole.subheadingSemiBold.style(context),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => unawaited(query.refetch()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final Widget inner = QueryBuilder<QueryStatus<Announcement>>(
            query: query,
            builder: (BuildContext context, QueryStatus<Announcement> state) {
              return switch (state) {
                QuerySuccess<Announcement>(:final data) => Builder(
                    builder: (BuildContext context) {
                      if (!data.isRead && !_markReadDispatched) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) {
                            return;
                          }
                          _markReadDispatched = true;
                          unawaited(
                            ref
                                .read(markAnnouncementReadNotifierProvider
                                    .notifier)
                                .markRead(data.id),
                          );
                        });
                      }
                      return AnnouncementDetailContent(announcement: data);
                    },
                  ),
                QueryError<Announcement>(:final error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(NorthstarSpacing.space24),
                      child: Text(
                        'Could not open this announcement.\n$error',
                        style: NorthstarTextRole.body.style(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                QueryLoading<Announcement>(:final data) when data != null =>
                  AnnouncementDetailContent(announcement: data),
                _ => const Center(child: CircularProgressIndicator()),
              };
            },
          );
          if (c.maxWidth >= AnnouncementsLayoutTokens.homeWideMinWidth) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AnnouncementsLayoutTokens.detailMaxContentWidth,
                ),
                child: inner,
              ),
            );
          }
          return inner;
        },
      ),
    );
  }
}
