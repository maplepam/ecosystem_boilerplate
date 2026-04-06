import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:flutter/material.dart';

/// First step of the widget catalog: searchable grid/list of components.
///
/// Host supplies [onOpenEntry] (e.g. [GoRouter.go] to a detail route).
class NorthstarWidgetLibraryListPage extends StatefulWidget {
  const NorthstarWidgetLibraryListPage({
    super.key,
    required this.entries,
    required this.onOpenEntry,
    this.title = 'Widget Library',
    this.subtitle,
    this.searchHint = 'Search by name…',
  });

  final List<WidgetCatalogEntry> entries;
  final void Function(WidgetCatalogEntry entry) onOpenEntry;
  final String title;
  final String? subtitle;
  final String searchHint;

  @override
  State<NorthstarWidgetLibraryListPage> createState() =>
      _NorthstarWidgetLibraryListPageState();
}

class _NorthstarWidgetLibraryListPageState
    extends State<NorthstarWidgetLibraryListPage> {
  String _query = '';

  List<WidgetCatalogEntry> get _filtered {
    final String q = _query.trim().toLowerCase();
    final List<WidgetCatalogEntry> list = q.isEmpty
        ? widget.entries.toList(growable: false)
        : widget.entries
            .where(
              (WidgetCatalogEntry e) =>
                  e.id.toLowerCase().contains(q) ||
                  e.title.toLowerCase().contains(q) ||
                  e.description.toLowerCase().contains(q),
            )
            .toList(growable: false);
    final List<WidgetCatalogEntry> sorted = List<WidgetCatalogEntry>.of(list)
      ..sort(WidgetCatalogEntry.compareByTitle);
    return sorted;
  }

  /// Min height for each grid tile: wide layout uses a narrow pane (e.g. 400px)
  /// with two columns, so [childAspectRatio] made cells ~74px tall and overflowed
  /// title + two-line blurb + padding. Fixed extent scales with text size.
  double _gridTileMainAxisExtent(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(120);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<WidgetCatalogEntry> items = _filtered;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Use the list’s laid-out width (e.g. 400px master pane), not screen
        // width — avoids 3 columns squeezed into a narrow split column.
        final double viewWidth = constraints.maxWidth;
        final bool wide = viewWidth > 520;
        final int gridCrossAxisCount = viewWidth >= 960 ? 3 : 2;

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  NorthstarSpacing.space8,
                  20,
                  NorthstarSpacing.space16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.subtitle != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SearchBar(
                      hintText: widget.searchHint,
                      leading: const Icon(Icons.search_rounded),
                      trailing: _query.isEmpty
                          ? null
                          : <Widget>[
                              IconButton(
                                tooltip: 'Clear',
                                onPressed: () => setState(() => _query = ''),
                                icon: const Icon(Icons.close_rounded),
                              ),
                            ],
                      onChanged: (String v) => setState(() => _query = v),
                    ),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(NorthstarSpacing.space32),
                    child: Text(
                      'No components match your search.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  NorthstarSpacing.space16,
                  0,
                  NorthstarSpacing.space16,
                  NorthstarSpacing.space32,
                ),
                sliver: wide
                    ? SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: _gridTileMainAxisExtent(context),
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int i) {
                            return _CatalogTile(
                              entry: items[i],
                              onTap: () => widget.onOpenEntry(items[i]),
                            );
                          },
                          childCount: items.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CatalogTile(
                                entry: items[i],
                                onTap: () => widget.onOpenEntry(items[i]),
                              ),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.entry,
    required this.onTap,
  });

  final WidgetCatalogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String blurb = entry.description.length > 120
        ? '${entry.description.substring(0, 117)}…'
        : entry.description;

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.widgets_outlined,
                    color: scheme.onPrimaryContainer,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      entry.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: NorthstarSpacing.space4),
                    Text(
                      blurb,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
