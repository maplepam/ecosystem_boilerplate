import 'dart:math' as math;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_pagination.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarPaginationCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_pagination',
    title: 'NorthstarPaginationBar',
    description:
        'Figma **Pagination**: prev/next, adaptive page window ([northstarPaginationPageSlotsAdaptive] '
        '— fewer number cells when the row is narrow; no horizontal scroll), full window '
        'matches [northstarPaginationPageSlots] when space allows, ellipsis hover → skip '
        '([ellipsisSkipDelta] default **3**), active page tint, **10 / page** menu, **Go to** when '
        '[goToPageVisibleThreshold] ≤ total pages (default **8**), range summary after controls '
        '(start-aligned), [compact] arrows-only toolbar variant, [emptyResults] disabled state. '
        'Compose **below** scrollable content—not pinned to viewport bottom.',
    code: r'''
  // Full-width page window (use northstarPaginationPageSlotsAdaptive + maxSlotCount for density):
  final List<int?> slots = northstarPaginationPageSlotsAdaptive(
    currentPage: page,
    totalPages: totalPages,
    maxSlotCount: 7,
  );

  NorthstarPaginationBar(
    automationId: 'documents',
    currentPage: page,
    totalPages: totalPages,
    totalItems: totalCount,
    pageSize: pageSize,
    pageSizeOptions: const [10, 25, 50],
    onPageChanged: (int p) => setState(() => page = p),
    onPageSizeChanged: (int n) => setState(() {
      pageSize = n;
      page = 1;
    }),
    goToPageVisibleThreshold: 8,
    ellipsisSkipDelta: 3,
    compact: false,
    emptyResults: totalCount == 0,
    enabled: totalCount > 0,
    goToPageLoading: isLoading,
  );
  ''',
    preview: (BuildContext context) => const _NorthstarPaginationCatalogDemo(),
  );
}

class _NorthstarPaginationCatalogDemo extends StatefulWidget {
  const _NorthstarPaginationCatalogDemo();

  @override
  State<_NorthstarPaginationCatalogDemo> createState() =>
      _NorthstarPaginationCatalogDemoState();
}

enum _PaginationDemoScenario {
  startPages,
  middlePages,
  endPages,
  singlePage,
  manyPagesGoTo,
  emptyDisabled,
  compactArrows,
}

class _NorthstarPaginationCatalogDemoState
    extends State<_NorthstarPaginationCatalogDemo> {
  _PaginationDemoScenario _scenario = _PaginationDemoScenario.startPages;
  int _page = 1;
  int _pageSize = 10;
  bool _goToLoading = false;

  int get _totalPages {
    switch (_scenario) {
      case _PaginationDemoScenario.startPages:
        return 10;
      case _PaginationDemoScenario.middlePages:
        return 20;
      case _PaginationDemoScenario.endPages:
        return 10;
      case _PaginationDemoScenario.singlePage:
        return 1;
      case _PaginationDemoScenario.manyPagesGoTo:
        return 30;
      case _PaginationDemoScenario.emptyDisabled:
        return 1;
      case _PaginationDemoScenario.compactArrows:
        return 12;
    }
  }

  int get _totalItems {
    if (_scenario == _PaginationDemoScenario.emptyDisabled) {
      return 0;
    }
    if (_scenario == _PaginationDemoScenario.singlePage) {
      return 7;
    }
    return _totalPages * _pageSize - 3;
  }

  void _applyScenario(_PaginationDemoScenario s) {
    setState(() {
      _scenario = s;
      switch (s) {
        case _PaginationDemoScenario.startPages:
          _page = 1;
        case _PaginationDemoScenario.middlePages:
          _page = 10;
        case _PaginationDemoScenario.endPages:
          _page = 10;
        case _PaginationDemoScenario.singlePage:
          _page = 1;
        case _PaginationDemoScenario.manyPagesGoTo:
          _page = 15;
        case _PaginationDemoScenario.emptyDisabled:
          _page = 1;
        case _PaginationDemoScenario.compactArrows:
          _page = 3;
      }
    });
  }

  List<String> _visibleItems() {
    if (_scenario == _PaginationDemoScenario.emptyDisabled) {
      return <String>[];
    }
    final int start = (_page - 1) * _pageSize;
    final int end = math.min(start + _pageSize, _totalItems);
    return <String>[
      for (var i = start; i < end; i++) 'Item ${i + 1}',
    ];
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool compact = _scenario == _PaginationDemoScenario.compactArrows;
    final bool empty = _scenario == _PaginationDemoScenario.emptyDisabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Scenario',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final _PaginationDemoScenario s
                  in _PaginationDemoScenario.values)
                ChoiceChip(
                  label: Text(_scenarioLabel(s)),
                  selected: _scenario == s,
                  onSelected: (_) => _applyScenario(s),
                ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          Text(
            'Full window (max 7 slots): ${northstarPaginationPageSlotsAdaptive(
              currentPage: _page.clamp(1, math.max(1, _totalPages)),
              totalPages: math.max(1, _totalPages),
              maxSlotCount: 7,
            )}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(NorthstarSpacing.space12),
                  child: empty
                      ? Text(
                          'No results (empty / disabled state).',
                          style: textTheme.bodyMedium,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Page $_page — visible rows',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: NorthstarSpacing.space8),
                            ..._visibleItems().map(
                              (String e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(e),
                              ),
                            ),
                          ],
                        ),
                ),
                const Divider(height: 1),
                NorthstarPaginationBar(
                  automationId: 'catalog_pagination',
                  currentPage: _page.clamp(1, math.max(1, _totalPages)),
                  totalPages: math.max(1, _totalPages),
                  totalItems: empty ? 0 : _totalItems,
                  pageSize: _pageSize,
                  pageSizeOptions: const <int>[10, 25, 50],
                  onPageChanged:
                      empty ? (_) {} : (int p) => setState(() => _page = p),
                  onPageSizeChanged: empty
                      ? null
                      : (int n) => setState(() {
                            _pageSize = n;
                            _page = 1;
                          }),
                  compact: compact,
                  emptyResults: empty,
                  enabled: !empty,
                  goToPageLoading: _goToLoading,
                ),
              ],
            ),
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          FilterChip(
            label: const Text('Go-to loading (disables field)'),
            selected: _goToLoading,
            onSelected: (bool v) {
              if (!empty) {
                setState(() => _goToLoading = v);
              }
            },
          ),
        ],
      ),
    );
  }
}

String _scenarioLabel(_PaginationDemoScenario s) {
  return switch (s) {
    _PaginationDemoScenario.startPages => 'Start (10 pg)',
    _PaginationDemoScenario.middlePages => 'Middle (20 pg)',
    _PaginationDemoScenario.endPages => 'End (10 pg)',
    _PaginationDemoScenario.singlePage => 'Single page',
    _PaginationDemoScenario.manyPagesGoTo => '30 pg + Go to',
    _PaginationDemoScenario.emptyDisabled => 'Empty / disabled',
    _PaginationDemoScenario.compactArrows => 'Compact arrows',
  };
}
