import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// One cell in the announcements grid: hero image, title, category, date.
class AnnouncementGridCard extends StatelessWidget {
  const AnnouncementGridCard({
    super.key,
    required this.announcement,
    required this.onTap,
    this.imageUrl,
    this.imageLoading = false,
  });

  final Announcement announcement;
  final VoidCallback onTap;
  final String? imageUrl;
  final bool imageLoading;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Announcement a = announcement;

    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        elevation: a.priority == AnnouncementPriority.important ? 2 : 0,
        borderRadius: BorderRadius.circular(12),
        color: ns.surfaceContainerHigh.withValues(alpha: 0.45),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 2,
                child: _Thumbnail(
                  imageUrl: imageUrl,
                  loading: imageLoading,
                  hasAssetKey: a.thumbnailAssetKey != null &&
                      a.thumbnailAssetKey!.trim().isNotEmpty,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  10,
                  NorthstarSpacing.space8,
                  10,
                  10,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (!a.isRead)
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 6,
                              top: NorthstarSpacing.space4,
                            ),
                            child: Icon(
                              Icons.fiber_manual_record,
                              size: 8,
                              color: ns.primary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            a.title,
                            style: NorthstarTextRole.subheadingSemiBold
                                .style(context)
                                .copyWith(height: 1.25),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NorthstarSpacing.space4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            a.category.label,
                            style: NorthstarTextRole.bodySmall.style(context),
                          ),
                        ),
                        if (a.priority == AnnouncementPriority.important)
                          Chip(
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              'Important',
                              style: NorthstarTextRole.bodySmall
                                  .style(context)
                                  .copyWith(color: ns.error),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: NorthstarSpacing.space4),
                    Text(
                      formatAnnouncementDate(a.publishedAt),
                      style: NorthstarTextRole.bodySmall.style(context).copyWith(
                            color: ns.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.imageUrl,
    required this.loading,
    required this.hasAssetKey,
  });

  final String? imageUrl;
  final bool loading;
  final bool hasAssetKey;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Color bg = ns.surfaceContainerLow.withValues(alpha: 0.65);

    if (loading && hasAssetKey) {
      return ColoredBox(
        color: bg,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final String? url = imageUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(context, bg),
        loadingBuilder: (BuildContext _, Widget child, ImageChunkEvent? p) {
          if (p == null) {
            return child;
          }
          return ColoredBox(
            color: bg,
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      );
    }

    return _placeholder(context, bg);
  }

  Widget _placeholder(BuildContext context, Color bg) {
    return ColoredBox(
      color: bg,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 40,
          color: NorthstarColorTokens.of(context).outline.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
