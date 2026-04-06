import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_text_link.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarTextLinkCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_text_link',
    title: 'NorthstarTextLink',
    description:
        'Inline **text link** for sentences and paragraphs (not standalone '
        '“View all” — use tertiary [NorthstarButton]). **Default:** blue '
        '`#0466F2` + underline. **Hover:** same hue, underline off. **Visited:** '
        'violet `#7C3AED` + underline. Inherits **font size / weight / family** '
        'from [DefaultTextStyle]. [interactionPreview] for catalog screenshots.',
    code: '''
  DefaultTextStyle(
    style: Theme.of(context).textTheme.bodyMedium!,
    child: Wrap(
      children: [
  Text('Read our '),
  NorthstarTextLink(
    label: 'Privacy Policy',
    onTap: () {},
    automationId: 'privacy',
  ),
  Text(' for details.'),
      ],
    ),
  )
  
  NorthstarTextLink(
    label: 'Already opened',
    isVisited: true,
    onTap: () {},
    automationId: 'visited_doc',
  )
  
  // Catalog / docs only:
  NorthstarTextLink(
    label: 'Hover snapshot',
    interactionPreview: NorthstarTextLinkInteractionPreview.hovered,
    onTap: () {},
  )
  ''',
    preview: (BuildContext context) => const _NorthstarTextLinkCatalogDemo(),
  );
}

class _NorthstarTextLinkCatalogDemo extends StatelessWidget {
  const _NorthstarTextLinkCatalogDemo();

  @override
  Widget build(BuildContext context) {
    final TextStyle caption = Theme.of(context).textTheme.labelSmall!;
    final TextStyle body = Theme.of(context).textTheme.bodyMedium!;

    Widget previewTile(String title, Widget child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: caption),
          const SizedBox(height: NorthstarSpacing.space4),
          DefaultTextStyle(style: body, child: child),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Paragraph-style (inherit body)', style: caption),
          const SizedBox(height: 6),
          DefaultTextStyle(
            style: body,
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: <Widget>[
                const Text('By continuing you accept the '),
                NorthstarTextLink(
                  label: 'Privacy Policy',
                  onTap: () {},
                  automationId: 'cat_tl_privacy',
                ),
                const Text(' and '),
                NorthstarTextLink(
                  label: 'Terms & Conditions',
                  onTap: () {},
                  automationId: 'cat_tl_terms',
                ),
                const Text('.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('interactionPreview (static)', style: caption),
          const SizedBox(height: NorthstarSpacing.space8),
          Wrap(
            spacing: 28,
            runSpacing: 16,
            children: <Widget>[
              previewTile(
                'Default',
                NorthstarTextLink(
                  label: 'This is a link',
                  interactionPreview: NorthstarTextLinkInteractionPreview.none,
                  isVisited: false,
                  onTap: () {},
                  automationId: 'cat_tl_st_default',
                ),
              ),
              previewTile(
                'Hovered',
                NorthstarTextLink(
                  label: 'This is a link',
                  interactionPreview:
                      NorthstarTextLinkInteractionPreview.hovered,
                  isVisited: false,
                  onTap: () {},
                  automationId: 'cat_tl_st_hover',
                ),
              ),
              previewTile(
                'Visited',
                NorthstarTextLink(
                  label: 'This is a link',
                  interactionPreview:
                      NorthstarTextLinkInteractionPreview.visited,
                  onTap: () {},
                  automationId: 'cat_tl_st_visited',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Visited hover (violet, no underline)', style: caption),
          const SizedBox(height: NorthstarSpacing.space8),
          previewTile(
            'Hovered + isVisited',
            NorthstarTextLink(
              label: 'This is a link',
              interactionPreview: NorthstarTextLinkInteractionPreview.hovered,
              isVisited: true,
              onTap: () {},
              automationId: 'cat_tl_st_vis_hov',
            ),
          ),
          const SizedBox(height: 20),
          const _NorthstarTextLinkToggleVisitedDemo(),
          const SizedBox(height: 20),
          Text('Inherits large / bold surrounding style', style: caption),
          const SizedBox(height: NorthstarSpacing.space8),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: <Widget>[
                const Text('This '),
                NorthstarTextLink(
                  label: 'link',
                  onTap: () {},
                  automationId: 'cat_tl_inherit',
                ),
                const Text(' inherit font styles'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NorthstarTextLinkToggleVisitedDemo extends StatefulWidget {
  const _NorthstarTextLinkToggleVisitedDemo();

  @override
  State<_NorthstarTextLinkToggleVisitedDemo> createState() =>
      _NorthstarTextLinkToggleVisitedDemoState();
}

class _NorthstarTextLinkToggleVisitedDemoState
    extends State<_NorthstarTextLinkToggleVisitedDemo> {
  bool _visited = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle caption = Theme.of(context).textTheme.labelSmall!;
    final TextStyle body = Theme.of(context).textTheme.bodyMedium!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Tap to toggle visited', style: caption),
        const SizedBox(height: 6),
        DefaultTextStyle(
          style: body,
          child: NorthstarTextLink(
            label: _visited
                ? 'Visited (tap to reset)'
                : 'Not visited (tap to visit)',
            isVisited: _visited,
            onTap: () => setState(() => _visited = !_visited),
            automationId: 'cat_tl_toggle',
          ),
        ),
      ],
    );
  }
}
