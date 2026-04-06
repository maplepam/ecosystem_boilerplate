import 'dart:async';
import 'dart:math' as math;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_data_table.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_pagination.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarDataTableCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_data_table',
    title: 'NorthstarDataTable',
    description:
        '**View states:** [NorthstarDataTableViewState] ready / loading / error / '
        'empty. **Selection:** [showCheckboxColumn], [rowKey], cross-page '
        '[selectedRowKeys] + [NorthstarDataTableSelectionBanner] (select all '
        'dataset, clear, busy). **Columns:** [columnOrder] + '
        '[onColumnOrderChanged] (long-press header drag to reorder), optional '
        '[columnWidths] + shared horizontal scroll, resize separators, '
        '[onColumnWidthsChanged]. **Rows:** [onReorderRows] with drag handle. '
        'Catalog demos truncation (tooltip), dropdown cell, icon actions, and '
        'text field.',
    code: r'''
  NorthstarDataTable(
    viewState: NorthstarDataTableViewState.ready,
    showCheckboxColumn: true,
    selectedRowKeys: selected,
    onSelectedRowKeysChanged: (s) => setState(() => selected = s),
    columnOrder: [2, 0, 1, 3],
    onColumnOrderChanged: (o) => setState(() => order = o),
    columnWidths: [200, 160, 140, 100],
    onColumnWidthsChanged: (w) => setState(() => widths = w),
    onReorderRows: (o, n) => reorderGlobalRows(o, n),
    rows: [
      NorthstarDataTableRow(
        rowKey: item.id,
        cells: [ /* … */ ],
      ),
    ],
  );
  NorthstarDataTableSelectionBanner(
    selectedCount: selected.length,
    totalInDataset: allIds.length,
    onSelectAllInDataset: () => setState(() => selected = allIds.toSet()),
    onClearDatasetSelection: () => setState(() => selected = {}),
  );
  ''',
    preview: (BuildContext context) => const _NorthstarDataTableCatalogDemo(),
  );
}

class _ColDef {
  const _ColDef({
    required this.id,
    required this.label,
    this.sortable = false,
    this.numeric = false,
    this.defaultWidth = 160,
  });

  final String id;
  final String label;
  final bool sortable;
  final bool numeric;
  final double defaultWidth;
}

class _RowModel {
  _RowModel({
    required this.id,
    required this.name,
    required this.uploaded,
    required this.trainer,
    required this.bytes,
  })  : status = 'Active',
        note = '';

  final String id;
  final String name;
  final String uploaded;
  final String trainer;
  final int bytes;
  final String status;
  final String note;
}

class _NorthstarDataTableCatalogDemo extends StatefulWidget {
  const _NorthstarDataTableCatalogDemo();

  @override
  State<_NorthstarDataTableCatalogDemo> createState() =>
      _NorthstarDataTableCatalogDemoState();
}

class _NorthstarDataTableCatalogDemoState
    extends State<_NorthstarDataTableCatalogDemo> {
  static const List<_ColDef> _allColDefs = <_ColDef>[
    _ColDef(
      id: 'name',
      label: 'Filename',
      sortable: true,
      defaultWidth: 220,
    ),
    _ColDef(
      id: 'uploaded',
      label: 'Date uploaded',
      sortable: true,
    ),
    _ColDef(
      id: 'trainer',
      label: 'Trainer',
      sortable: true,
    ),
    _ColDef(
      id: 'size',
      label: 'Size',
      sortable: true,
      numeric: true,
      defaultWidth: 88,
    ),
    _ColDef(
      id: 'status',
      label: 'Status',
      defaultWidth: 120,
    ),
    _ColDef(id: 'actions', label: 'Actions', defaultWidth: 120),
    _ColDef(id: 'note', label: 'Note', defaultWidth: 140),
  ];

  static List<_RowModel> _seedData() => <_RowModel>[
        _RowModel(
          id: 'r1',
          name:
              'Information Security Policy (v1.0) — very long filename for ellipsis demo in the catalog preview surface',
          uploaded: 'Wed, 28 Jun 2023 08:09:23',
          trainer: 'Marvenn Sta. Cruz',
          bytes: 1200,
        ),
        _RowModel(
          id: 'r2',
          name: 'Acceptable Use Policy',
          uploaded: 'Tue, 27 Jun 2023 14:22:01',
          trainer: 'Alex Rivera',
          bytes: 890,
        ),
        _RowModel(
          id: 'r3',
          name: 'Remote Work Guidelines',
          uploaded: 'Mon, 26 Jun 2023 09:15:44',
          trainer: 'Jordan Lee',
          bytes: 2100,
        ),
        _RowModel(
          id: 'r4',
          name: 'Data Retention Schedule',
          uploaded: 'Sun, 25 Jun 2023 18:40:12',
          trainer: 'Sam Patel',
          bytes: 450,
        ),
        _RowModel(
          id: 'r5',
          name: 'Incident Response Playbook',
          uploaded: 'Sat, 24 Jun 2023 11:05:33',
          trainer: 'Casey Ng',
          bytes: 5600,
        ),
        _RowModel(
          id: 'r6',
          name: 'Vendor Risk Assessment',
          uploaded: 'Fri, 23 Jun 2023 16:50:00',
          trainer: 'Riley Chen',
          bytes: 3200,
        ),
      ];

  late List<_RowModel> _data = _seedData();

  int _page = 1;
  int _pageSize = 3;
  bool _zebra = true;
  bool _skeletonLoading = false;
  NorthstarDataTableViewState _viewState = NorthstarDataTableViewState.ready;
  int? _flashIndex;
  Timer? _flashTimer;

  final Set<String> _visibleColIds = <String>{
    'name',
    'uploaded',
    'trainer',
    'size',
    'status',
    'actions',
    'note',
  };
  final List<String> _columnOrder = <String>[
    'name',
    'uploaded',
    'trainer',
    'size',
    'status',
    'actions',
    'note',
  ];
  late List<double> _colWidths;

  final Set<Object> _selectedKeys = <Object>{};
  bool _selectBusy = false;
  bool _showCheckboxes = true;
  bool _enableReorder = false;
  bool _useFixedWidths = true;

  final Map<String, String> _dropdownValue = <String, String>{};
  final Map<String, TextEditingController> _noteControllers =
      <String, TextEditingController>{};

  List<NorthstarTableColumnSort> _sorts = List<NorthstarTableColumnSort>.filled(
    _allColDefs.length,
    NorthstarTableColumnSort.inactive,
  );
  int? _sortColumnIndex;

  @override
  void initState() {
    super.initState();
    _colWidths = _allColDefs.map((c) => c.defaultWidth).toList();
    for (final _RowModel r in _data) {
      _dropdownValue[r.id] = 'Active';
      _noteControllers[r.id] = TextEditingController(text: r.note);
    }
  }

  @override
  void dispose() {
    _flashTimer?.cancel();
    for (final TextEditingController c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _totalPages => math.max(
        1,
        (_data.length / _pageSize).ceil(),
      );

  List<_ColDef> get _visibleDefs {
    final List<_ColDef> out = <_ColDef>[];
    for (final String id in _columnOrder) {
      if (_visibleColIds.contains(id)) {
        out.add(_allColDefs.firstWhere((c) => c.id == id));
      }
    }
    return out;
  }

  /// Visible columns in stable definition order (logical indices for the table).
  List<_ColDef> get _canonicalVisibleDefs => <_ColDef>[
        for (final _ColDef c in _allColDefs)
          if (_visibleColIds.contains(c.id)) c,
      ];

  List<int> _tableColumnOrderPermutation() {
    final List<_ColDef> canonical = _canonicalVisibleDefs;
    final List<_ColDef> display = _visibleDefs;
    return <int>[
      for (final _ColDef d in display)
        canonical.indexWhere((c) => c.id == d.id),
    ];
  }

  void _applyTableColumnOrder(List<int> newPerm) {
    final List<_ColDef> canonical = _canonicalVisibleDefs;
    final List<String> orderedVisible = <String>[
      for (final int i in newPerm) canonical[i].id,
    ];
    final Set<String> vis = orderedVisible.toSet();
    final List<String> hiddenInOrder = <String>[
      for (final String id in _columnOrder)
        if (!vis.contains(id)) id,
    ];
    setState(() {
      _columnOrder
        ..clear()
        ..addAll(orderedVisible)
        ..addAll(hiddenInOrder);
    });
  }

  List<NorthstarTableColumnSort> _sortsForCanonicalVisible() {
    final List<_ColDef> canonical = _canonicalVisibleDefs;
    return <NorthstarTableColumnSort>[
      for (final _ColDef d in canonical)
        _sorts[_allColDefs.indexWhere((c) => c.id == d.id)],
    ];
  }

  int? _sortCanonicalVisibleIndex() {
    if (_sortColumnIndex == null) {
      return null;
    }
    final String id = _allColDefs[_sortColumnIndex!].id;
    if (!_visibleColIds.contains(id)) {
      return null;
    }
    return _canonicalVisibleDefs.indexWhere((c) => c.id == id);
  }

  List<double> _widthsForVisible() {
    final List<double> w = <double>[];
    for (final _ColDef d in _visibleDefs) {
      final int i = _allColDefs.indexWhere((c) => c.id == d.id);
      w.add(_colWidths[i]);
    }
    return w;
  }

  void _onWidthsChanged(List<double> nextVisible) {
    setState(() {
      var vi = 0;
      for (final _ColDef d in _visibleDefs) {
        final int i = _allColDefs.indexWhere((c) => c.id == d.id);
        _colWidths[i] = nextVisible[vi];
        vi++;
      }
    });
  }

  List<_RowModel> _sortedAll() {
    final List<_RowModel> copy = List<_RowModel>.from(_data);
    final int? col = _sortColumnIndex;
    if (col == null) {
      return copy;
    }
    if (_sorts[col] == NorthstarTableColumnSort.inactive) {
      return copy;
    }
    final _ColDef def = _allColDefs[col];
    int cmp(_RowModel a, _RowModel b) {
      switch (def.id) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'uploaded':
          return a.uploaded.compareTo(b.uploaded);
        case 'trainer':
          return a.trainer.compareTo(b.trainer);
        case 'size':
          return a.bytes.compareTo(b.bytes);
        default:
          return 0;
      }
    }

    copy.sort((a, b) {
      final int c = cmp(a, b);
      return _sorts[col] == NorthstarTableColumnSort.ascending ? c : -c;
    });
    return copy;
  }

  List<_RowModel> _pageSlice() {
    final List<_RowModel> s = _sortedAll();
    final int start = (_page - 1) * _pageSize;
    if (start >= s.length) {
      return <_RowModel>[];
    }
    return s.sublist(start, math.min(start + _pageSize, s.length));
  }

  void _onReorderRows(int oldIndex, int newIndex) {
    setState(() {
      final int start = (_page - 1) * _pageSize;
      newIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final List<_RowModel> slice = _pageSlice();
      final _RowModel moved = slice.removeAt(oldIndex);
      slice.insert(newIndex, moved);
      for (var i = 0; i < slice.length; i++) {
        _data[start + i] = slice[i];
      }
    });
  }

  void _flashTop() {
    _flashTimer?.cancel();
    setState(() => _flashIndex = 0);
    _flashTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _flashIndex = null);
      }
    });
  }

  Widget _cellFor(_RowModel m, String colId, TextTheme textTheme) {
    switch (colId) {
      case 'name':
        return Tooltip(
          message: m.name,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.insert_drive_file_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: NorthstarPaginationTokens.specTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'uploaded':
        return Text(
          m.uploaded,
          style: textTheme.bodySmall?.copyWith(
            color: NorthstarPaginationTokens.specTextSecondary,
          ),
        );
      case 'trainer':
        return Text(m.trainer, style: textTheme.bodyMedium);
      case 'size':
        return Text('${m.bytes} B', style: textTheme.bodyMedium);
      case 'status':
        return PopupMenuButton<String>(
          initialValue: _dropdownValue[m.id],
          onSelected: (String v) => setState(() => _dropdownValue[m.id] = v),
          itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
            const PopupMenuItem(value: 'Active', child: Text('Active')),
            const PopupMenuItem(value: 'Pending', child: Text('Pending')),
            const PopupMenuItem(value: 'Archived', child: Text('Archived')),
          ],
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(_dropdownValue[m.id] ?? 'Active'),
              const Icon(Icons.arrow_drop_down_rounded, size: 20),
            ],
          ),
        );
      case 'actions':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(30, 30),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.visibility_outlined, size: 20),
              onPressed: () {},
              tooltip: 'View',
            ),
            IconButton(
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(30, 30),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              onPressed: () {},
              tooltip: 'Delete',
            ),
          ],
        );
      case 'note':
        return TextField(
          controller: _noteControllers[m.id],
          style: textTheme.bodySmall,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Add note',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<_RowModel> slice = _pageSlice();
    final List<_ColDef> canonical = _canonicalVisibleDefs;
    final List<_ColDef> defs = _visibleDefs;

    final List<NorthstarDataTableColumn> columns = <NorthstarDataTableColumn>[
      for (final _ColDef d in canonical)
        NorthstarDataTableColumn(
          label: d.label,
          sortable: d.sortable,
          flex: d.numeric ? 1 : 2,
          numeric: d.numeric,
          minWidth: 64,
        ),
    ];

    final List<NorthstarDataTableRow> rows = <NorthstarDataTableRow>[
      for (var i = 0; i < slice.length; i++)
        NorthstarDataTableRow(
          rowKey: slice[i].id,
          highlightNew: _flashIndex == i,
          cells: <Widget>[
            for (final _ColDef d in canonical)
              _cellFor(slice[i], d.id, textTheme),
          ],
        ),
    ];

    final List<NorthstarTableColumnSort> displaySorts =
        _sortsForCanonicalVisible();
    final int? displaySortIdx = _sortCanonicalVisibleIndex();

    void onSortDisplay(int canonicalVisibleIndex) {
      final List<_ColDef> can = _canonicalVisibleDefs;
      final _ColDef def = can[canonicalVisibleIndex];
      final int logicalAll = _allColDefs.indexWhere((c) => c.id == def.id);
      final ({List<NorthstarTableColumnSort> sorts, int? activeColumn}) r =
          northstarTableCycleSortOnColumn(
        columnIndex: logicalAll,
        sortStates: _sorts,
      );
      setState(() {
        _sorts = r.sorts;
        _sortColumnIndex = r.activeColumn;
        _page = 1;
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: const Text('Ready'),
                selected: _viewState == NorthstarDataTableViewState.ready,
                onSelected: (_) => setState(() {
                  _viewState = NorthstarDataTableViewState.ready;
                  _skeletonLoading = false;
                }),
              ),
              ChoiceChip(
                label: const Text('Loading'),
                selected: _viewState == NorthstarDataTableViewState.loading,
                onSelected: (_) => setState(() {
                  _viewState = NorthstarDataTableViewState.loading;
                  _skeletonLoading = true;
                }),
              ),
              ChoiceChip(
                label: const Text('Error'),
                selected: _viewState == NorthstarDataTableViewState.error,
                onSelected: (_) => setState(
                    () => _viewState = NorthstarDataTableViewState.error),
              ),
              ChoiceChip(
                label: const Text('Empty'),
                selected: _viewState == NorthstarDataTableViewState.empty,
                onSelected: (_) => setState(
                    () => _viewState = NorthstarDataTableViewState.empty),
              ),
              FilterChip(
                label: const Text('Checkboxes'),
                selected: _showCheckboxes,
                onSelected: (bool v) => setState(() => _showCheckboxes = v),
              ),
              FilterChip(
                label: const Text('Reorder rows'),
                selected: _enableReorder,
                onSelected: (bool v) => setState(() => _enableReorder = v),
              ),
              FilterChip(
                label: const Text('Fixed widths + resize'),
                selected: _useFixedWidths,
                onSelected: (bool v) => setState(() => _useFixedWidths = v),
              ),
              FilterChip(
                label: const Text('Zebra'),
                selected: _zebra,
                onSelected: (bool v) => setState(() => _zebra = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Columns (visibility)',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final _ColDef c in _allColDefs)
                FilterChip(
                  label: Text(c.label),
                  selected: _visibleColIds.contains(c.id),
                  onSelected: (bool v) => setState(() {
                    if (v) {
                      _visibleColIds.add(c.id);
                      if (!_columnOrder.contains(c.id)) {
                        _columnOrder.add(c.id);
                      }
                    } else {
                      _visibleColIds.remove(c.id);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          NorthstarDataTableSelectionBanner(
            selectedCount: _selectedKeys.length,
            totalInDataset: _data.length,
            selectingBusy: _selectBusy,
            onSelectAllInDataset: () {
              setState(() {
                _selectBusy = true;
                _selectedKeys
                  ..clear()
                  ..addAll(_data.map((e) => e.id));
              });
              Future<void>.delayed(const Duration(milliseconds: 600), () {
                if (mounted) {
                  setState(() => _selectBusy = false);
                }
              });
            },
            onClearDatasetSelection: () =>
                setState(() => _selectedKeys.clear()),
            actions: <Widget>[
              IconButton(
                tooltip: 'Export',
                onPressed: _selectedKeys.isEmpty ? null : () {},
                icon: const Icon(Icons.download_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: _selectedKeys.isEmpty ? null : () {},
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarDataTable(
            automationId: 'catalog_data_table',
            columns: columns,
            rows: rows,
            viewState: _viewState,
            errorMessage: 'Could not load documents.',
            onErrorRetry: () => setState(() {
              _viewState = NorthstarDataTableViewState.ready;
            }),
            loading: _skeletonLoading,
            sortColumnIndex: displaySortIdx,
            sortStates: displaySorts,
            onSortColumn: onSortDisplay,
            zebraStripe: _zebra,
            showCheckboxColumn: _showCheckboxes,
            selectedRowKeys: _selectedKeys,
            onSelectedRowKeysChanged: (Set<Object> s) =>
                setState(() => _selectedKeys
                  ..clear()
                  ..addAll(s)),
            selectionEnabled: !_selectBusy,
            onReorderRows: _enableReorder ? _onReorderRows : null,
            columnOrder:
                canonical.isNotEmpty ? _tableColumnOrderPermutation() : null,
            onColumnOrderChanged:
                canonical.isNotEmpty ? _applyTableColumnOrder : null,
            columnWidths:
                _useFixedWidths && defs.isNotEmpty ? _widthsForVisible() : null,
            onColumnWidthsChanged:
                _useFixedWidths && defs.isNotEmpty ? _onWidthsChanged : null,
          ),
          NorthstarPaginationBar(
            automationId: 'catalog_table_pagination',
            currentPage: _page.clamp(1, _totalPages),
            totalPages: _totalPages,
            totalItems: _data.length,
            pageSize: _pageSize,
            pageSizeOptions: const <int>[2, 3, 6],
            onPageChanged: (int p) => setState(() => _page = p),
            onPageSizeChanged: (int n) => setState(() {
              _pageSize = n;
              _page = 1;
            }),
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          FilledButton.tonal(
            onPressed: () {
              setState(() {
                _data = <_RowModel>[
                  _RowModel(
                    id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                    name: 'New row from action',
                    uploaded: 'Just now',
                    trainer: 'You',
                    bytes: 99,
                  ),
                  ..._data,
                ];
                _dropdownValue[_data.first.id] = 'Pending';
                _noteControllers[_data.first.id] = TextEditingController();
                _page = 1;
              });
              _flashTop();
            },
            child: const Text('Add row (800ms highlight)'),
          ),
        ],
      ),
    );
  }
}
