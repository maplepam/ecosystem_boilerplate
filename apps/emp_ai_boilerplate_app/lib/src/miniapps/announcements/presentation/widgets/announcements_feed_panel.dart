import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/di/announcements_data_providers.dart';
import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/presentation/widgets/announcement_grid_card.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Grid feed (up to **4 columns** on wide layouts) + empty + pull-to-refresh;
/// optional **load more** hook (infinite scroll).
///
/// Thumbnails: batched `POST …/media/assets/files` via
/// [announcementMediaRepositoryProvider] (emapta `announcement_module` parity).
class AnnouncementsFeedPanel extends ConsumerStatefulWidget {
  const AnnouncementsFeedPanel({
    super.key,
    required this.items,
    required this.isInitialLoading,
    required this.isFetchingMore,
    required this.error,
    required this.onRefresh,
    required this.onOpenDetail,
    this.onLoadMore,
    this.hasNextPage = false,
  });

  final List<Announcement> items;
  final bool isInitialLoading;
  final bool isFetchingMore;
  final Object? error;
  final Future<void> Function() onRefresh;
  final void Function(Announcement announcement) onOpenDetail;
  final VoidCallback? onLoadMore;
  final bool hasNextPage;

  @override
  ConsumerState<AnnouncementsFeedPanel> createState() =>
      _AnnouncementsFeedPanelState();
}

class _AnnouncementsFeedPanelState extends ConsumerState<AnnouncementsFeedPanel> {
  Map<String, String?>? _urlsByAssetKey;
  Set<String> _lastThumbKeys = <String>{};
  bool _thumbsLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleThumbResolve(widget.items);
    });
  }

  @override
  void didUpdateWidget(covariant AnnouncementsFeedPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleThumbResolve(widget.items);
  }

  void _scheduleThumbResolve(List<Announcement> items) {
    final Set<String> keys = items
        .map((Announcement e) => e.thumbnailAssetKey)
        .whereType<String>()
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toSet();
    if (setEquals(keys, _lastThumbKeys) && _urlsByAssetKey != null) {
      return;
    }
    _lastThumbKeys = Set<String>.from(keys);
    if (keys.isEmpty) {
      setState(() {
        _urlsByAssetKey = <String, String?>{};
        _thumbsLoading = false;
      });
      return;
    }
    setState(() => _thumbsLoading = true);
    ref.read(announcementMediaRepositoryProvider).resolveAssetUrls(keys).then(
      (Map<String, String?> m) {
        if (!mounted) {
          return;
        }
        if (!setEquals(keys, _lastThumbKeys)) {
          return;
        }
        setState(() {
          _urlsByAssetKey = m;
          _thumbsLoading = false;
        });
      },
    );
  }

  int _crossAxisCount(double width) {
    final int n = (width / 260).floor();
    return n.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isInitialLoading && widget.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (widget.error != null && widget.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NorthstarSpacing.space24),
          child: Text(
            'Could not load announcements.\n${widget.error}',
            style: NorthstarTextRole.body.style(context),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (widget.items.isEmpty) {
      return Center(
        child: Text(
          'No announcements match your filters.',
          style: NorthstarTextRole.body.style(context),
          textAlign: TextAlign.center,
        ),
      );
    }

    final Map<String, String?> urlMap = _urlsByAssetKey ?? <String, String?>{};

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification n) {
          if (widget.onLoadMore == null ||
              !widget.hasNextPage ||
              widget.isFetchingMore) {
            return false;
          }
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
            widget.onLoadMore!();
          }
          return false;
        },
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int cols = _crossAxisCount(constraints.maxWidth);
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.all(NorthstarSpacing.space16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      // Wider ratio = shorter row height; card uses min intrinsic height.
                      childAspectRatio: 0.92,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int i) {
                        final Announcement a = widget.items[i];
                        final String? k = a.thumbnailAssetKey?.trim();
                        final String? url =
                            (k != null && k.isNotEmpty) ? urlMap[k] : null;
                        final bool loading = _thumbsLoading &&
                            k != null &&
                            k.isNotEmpty;
                        return AnnouncementGridCard(
                          announcement: a,
                          imageUrl: url,
                          imageLoading: loading,
                          onTap: () => widget.onOpenDetail(a),
                        );
                      },
                      childCount: widget.items.length,
                    ),
                  ),
                ),
                if (widget.isFetchingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: NorthstarSpacing.space24,
                      ),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
