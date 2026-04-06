import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Searchable, grouped browser for [kNorthstarIconManifest] (Northstar V3 SVGs).
class NorthstarIconCatalogPanel extends StatefulWidget {
  const NorthstarIconCatalogPanel({super.key});

  @override
  State<NorthstarIconCatalogPanel> createState() => _NorthstarIconCatalogPanelState();
}

class _NorthstarIconCatalogPanelState extends State<NorthstarIconCatalogPanel> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _sampleCode(NorthstarIconManifestItem item) {
    final String safeId = item.id.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "NorthstarSvgIcon(\n"
        "  item: NorthstarIconRegistry.tryById('$safeId')!,\n"
        '  size: 24,\n'
        '  color: Theme.of(context).colorScheme.onSurface, // optional\n'
        ')';
  }

  static String _samplePath(NorthstarIconManifestItem item) {
    final String p = item.relativeAssetPath.replaceAll(r'\', r'\\').replaceAll("'", r"\'");
    return "NorthstarSvgIcon.fromPath(\n"
        "  relativeAssetPath: '$p',\n"
        '  size: 24,\n'
        '  color: Theme.of(context).colorScheme.onSurface, // optional\n'
        ')';
  }

  void _showSample(BuildContext context, NorthstarIconManifestItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            NorthstarSpacing.space16,
            0,
            NorthstarSpacing.space16,
            NorthstarSpacing.space24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  NorthstarSvgIcon(item: item, size: 40),
                  const SizedBox(width: NorthstarSpacing.space12),
                  Expanded(
                    child: Text(
                      item.id,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NorthstarSpacing.space8),
              Text(
                item.relativeAssetPath,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: NorthstarSpacing.space16),
              Text('By id', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 6),
              SelectableText(
                _sampleCode(item),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: NorthstarSpacing.space16),
              Text('By asset path', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 6),
              SelectableText(
                _samplePath(item),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: NorthstarSpacing.space12),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _sampleCode(item)),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied id sample')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy id sample'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String q = _controller.text;
    final List<NorthstarIconManifestItem> matches = NorthstarIconRegistry.search(q);

    final Map<NorthstarIconCategory, List<NorthstarIconManifestItem>> grouped =
        <NorthstarIconCategory, List<NorthstarIconManifestItem>>{};
    for (final NorthstarIconCategory c in NorthstarIconCategory.values) {
      grouped[c] = <NorthstarIconManifestItem>[];
    }
    for (final NorthstarIconManifestItem e in matches) {
      grouped[e.category]!.add(e);
    }

    final List<NorthstarIconCategory> ordered = NorthstarIconCategory.values.toList()
      ..sort(
        (NorthstarIconCategory a, NorthstarIconCategory b) =>
            a.catalogOrder.compareTo(b.catalogOrder),
      );
    final List<NorthstarIconCategory> visible = ordered
        .where((NorthstarIconCategory c) => grouped[c]!.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search by id, path, or group name…',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Text(
          '${matches.length} icon${matches.length == 1 ? '' : 's'} · '
          'emp_ai_ds_northstar / assets/northstar_icons',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Expanded(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (BuildContext context, int i) {
              final NorthstarIconCategory cat = visible[i];
              final List<NorthstarIconManifestItem> items = grouped[cat]!;
              return ExpansionTile(
                initiallyExpanded: q.isNotEmpty && items.length <= 24,
                title: Text('${cat.catalogTitle} (${items.length})'),
                children: <Widget>[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: items.length,
                    itemBuilder: (BuildContext context, int j) {
                      final NorthstarIconManifestItem item = items[j];
                      return InkWell(
                        onTap: () => _showSample(context, item),
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            NorthstarSvgIcon(
                              item: item,
                              size: 28,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            const SizedBox(height: NorthstarSpacing.space4),
                            Text(
                              item.id,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    height: 1.1,
                                  ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
