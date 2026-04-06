import 'package:emp_ai_boilerplate_app/src/miniapps/announcements/domain/announcement.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Scrollable body for [Announcement] detail (mini-app widget).
class AnnouncementDetailContent extends StatelessWidget {
  const AnnouncementDetailContent({
    super.key,
    required this.announcement,
  });

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final Announcement a = announcement;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          a.title,
          style: NorthstarTextRole.pageTitle
              .style(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Wrap(
          spacing: NorthstarSpacing.space8,
          runSpacing: NorthstarSpacing.space4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              formatAnnouncementDate(a.publishedAt),
              style: NorthstarTextRole.label.style(context).copyWith(
                    color: ns.outline,
                  ),
            ),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(
                a.category.label,
                style: NorthstarTextRole.label.style(context),
              ),
            ),
            if (a.authorName != null)
              Text(
                '· ${a.authorName}',
                style: NorthstarTextRole.body.style(context).copyWith(
                      color: ns.outlineVariant,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          a.body,
          style: NorthstarTextRole.bodyLarge.style(context).copyWith(
                height: 1.5,
              ),
        ),
        if (a.actionUrl != null && a.actionLabel != null) ...<Widget>[
          const SizedBox(height: NorthstarSpacing.space24),
          FilledButton.tonalIcon(
            onPressed: () async {
              final Uri? uri = Uri.tryParse(a.actionUrl!);
              if (uri == null) {
                return;
              }
              final bool ok = await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
              if (!context.mounted) {
                return;
              }
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open ${a.actionUrl}')),
                );
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: Text(a.actionLabel!),
          ),
        ],
      ],
    );
  }
}
