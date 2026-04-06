import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_banner.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarBannerCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_banner',
    title: 'NorthstarBanner',
    description:
        'Figma **Banners**: [NorthstarBannerKind.normal] (inline pastel + border), '
        '[systemFixed] (high-contrast strip), [floating] (solid compact + hover tint). '
        '[NorthstarBannerStatus] drives palette and default icon. '
        'Optional body, notes, two text actions, dismiss. '
        '[NorthstarBannerLayout.overlay] + [NorthstarBannerAnchor] positions inside a '
        '[Stack] (top/bottom center and four corners); [flow] stretches to parent width.',
    code: '''
  // Inline (normal)
  NorthstarBanner(
    kind: NorthstarBannerKind.normal,
    status: NorthstarBannerStatus.success,
    label: 'Job request approved',
    body: 'We emailed the hiring manager.',
    primaryActionLabel: 'View job',
    onPrimaryAction: () {},
    onDismiss: () {},
  )
  
  // System strip — overlay (direct Stack child)
  NorthstarBanner(
    kind: NorthstarBannerKind.systemFixed,
    status: NorthstarBannerStatus.error,
    layout: NorthstarBannerLayout.overlay,
    anchor: NorthstarBannerAnchor.topCenter,
    label: 'System maintenance scheduled for 5:30 PM',
    onDismiss: () {},
  )
  
  // Floating — corner + margin
  NorthstarBanner(
    kind: NorthstarBannerKind.floating,
    status: NorthstarBannerStatus.informative,
    layout: NorthstarBannerLayout.overlay,
    anchor: NorthstarBannerAnchor.bottomRight,
    margin: EdgeInsets.all(NorthstarSpacing.space12),
    label: 'New updates available',
    onDismiss: () {},
  )
  ''',
    preview: _northstarBannerCatalogPreview,
  );
}

Widget _northstarBannerCatalogPreview(BuildContext context) {
  return const _NorthstarBannerCatalogDemo();
}

class _NorthstarBannerCatalogDemo extends StatefulWidget {
  const _NorthstarBannerCatalogDemo();

  @override
  State<_NorthstarBannerCatalogDemo> createState() =>
      _NorthstarBannerCatalogDemoState();
}

class _NorthstarBannerCatalogDemoState
    extends State<_NorthstarBannerCatalogDemo> {
  NorthstarBannerAnchor _anchor = NorthstarBannerAnchor.topCenter;
  bool _overlayFixed = true;
  bool _showOverlay = true;

  @override
  Widget build(BuildContext context) {
    final TextStyle? sectionStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Normal (inline)', style: sectionStyle),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarBanner(
            kind: NorthstarBannerKind.normal,
            status: NorthstarBannerStatus.success,
            label: 'Job request approved',
            body: 'We emailed the hiring manager.',
            primaryActionLabel: 'View job',
            onPrimaryAction: () =>
                catalogPreviewSnack(context, 'Banner · View job'),
            showDismissButton: true,
            onDismiss: () =>
                catalogPreviewSnack(context, 'Banner · Dismiss success'),
            automationId: 'cat_banner_norm_ok',
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarBanner(
            kind: NorthstarBannerKind.normal,
            status: NorthstarBannerStatus.informative,
            label: 'New policy available',
            body: 'Read the updated remote work guidelines.',
            primaryActionLabel: 'Open policy',
            onPrimaryAction: () =>
                catalogPreviewSnack(context, 'Banner · Open policy'),
            automationId: 'cat_banner_norm_info',
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarBanner(
            kind: NorthstarBannerKind.normal,
            status: NorthstarBannerStatus.warning,
            label: 'Please complete required fields',
            automationId: 'cat_banner_norm_warn',
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarBanner(
            kind: NorthstarBannerKind.normal,
            status: NorthstarBannerStatus.error,
            label: 'Upload failed',
            body: 'The file was too large.',
            primaryActionLabel: 'Retry',
            onPrimaryAction: () =>
                catalogPreviewSnack(context, 'Banner · Retry'),
            onDismiss: () =>
                catalogPreviewSnack(context, 'Banner · Dismiss error'),
            automationId: 'cat_banner_norm_err',
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text('System fixed (flow)', style: sectionStyle),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarBanner(
            kind: NorthstarBannerKind.systemFixed,
            status: NorthstarBannerStatus.informative,
            layout: NorthstarBannerLayout.flow,
            label: 'Product launch: try the new dashboard',
            primaryActionLabel: 'Try it now',
            onPrimaryAction: () =>
                catalogPreviewSnack(context, 'Banner · Try it now'),
            secondaryActionLabel: 'Later',
            onSecondaryAction: () =>
                catalogPreviewSnack(context, 'Banner · Later'),
            onDismiss: () =>
                catalogPreviewSnack(context, 'Banner · Dismiss flow'),
            automationId: 'cat_banner_sys_flow',
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text('Overlay in Stack (fixed vs floating)', style: sectionStyle),
          const SizedBox(height: NorthstarSpacing.space8),
          Wrap(
            spacing: NorthstarSpacing.space8,
            runSpacing: NorthstarSpacing.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              DropdownButton<NorthstarBannerAnchor>(
                value: _anchor,
                onChanged: (NorthstarBannerAnchor? v) {
                  if (v != null) {
                    setState(() => _anchor = v);
                  }
                },
                items: NorthstarBannerAnchor.values
                    .map(
                      (NorthstarBannerAnchor a) =>
                          DropdownMenuItem<NorthstarBannerAnchor>(
                        value: a,
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
              ),
              FilterChip(
                label: const Text('System fixed'),
                selected: _overlayFixed,
                onSelected: (_) => setState(() => _overlayFixed = true),
              ),
              FilterChip(
                label: const Text('Floating'),
                selected: !_overlayFixed,
                onSelected: (_) => setState(() => _overlayFixed = false),
              ),
              TextButton(
                onPressed: () => setState(() => _showOverlay = true),
                child: const Text('Show overlay'),
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: <Widget>[
                  ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: const Center(
                      child: Text('Stack body (scroll / page content)'),
                    ),
                  ),
                  if (_showOverlay)
                    if (_overlayFixed)
                      NorthstarBanner(
                        kind: NorthstarBannerKind.systemFixed,
                        status: NorthstarBannerStatus.warning,
                        layout: NorthstarBannerLayout.overlay,
                        anchor: _anchor,
                        label: 'Your password expires in 2 days',
                        primaryActionLabel: 'Change password',
                        onPrimaryAction: () => catalogPreviewSnack(
                            context, 'Overlay · Change password'),
                        onDismiss: () => setState(() => _showOverlay = false),
                        automationId: 'cat_banner_sys_ov',
                      )
                    else
                      NorthstarBanner(
                        kind: NorthstarBannerKind.floating,
                        status: NorthstarBannerStatus.error,
                        layout: NorthstarBannerLayout.overlay,
                        anchor: _anchor,
                        label: 'Unable to load data',
                        primaryActionLabel: 'Retry',
                        onPrimaryAction: () => catalogPreviewSnack(
                            context, 'Floating overlay · Retry'),
                        onDismiss: () => setState(() => _showOverlay = false),
                        automationId: 'cat_banner_float_ov',
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
