import 'dart:math' as math;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_pagination.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';
import 'package:flutter/material.dart';

/// Reserved width for the header long-press drag handle when column reorder
/// is enabled; body cells use the same inset so columns align.
const double _kHeaderColumnReorderGutterWidth = 22;

/// Header sort cycle: inactive → ascending → descending → inactive.
enum NorthstarTableColumnSort {
  inactive,
  ascending,
  descending,
}

/// Body state: **ready** shows [NorthstarDataTable.rows]; **loading** skeleton;
/// **error** / **empty** show placeholders.
enum NorthstarDataTableViewState {
  ready,
  loading,
  error,
  empty,
}

/// Column metadata for [NorthstarDataTable].
@immutable
class NorthstarDataTableColumn {
  const NorthstarDataTableColumn({
    required this.label,
    this.sortable = false,
    this.flex = 1,
    this.textAlign = TextAlign.start,
    this.numeric = false,
    this.minWidth = 80,
    /// When non-null, host-built “move column” UIs can show this **1-based**
    /// rank in labels (e.g. `1. Name`). Columns with `null` are omitted from
    /// such menus; header drag reorder still applies when enabled.
    this.reorderMenuRank,
  });

  final String label;
  final bool sortable;
  final int flex;
  final TextAlign textAlign;
  final bool numeric;
  final double minWidth;
  final int? reorderMenuRank;
}

/// One data row for [NorthstarDataTable].
@immutable
class NorthstarDataTableRow {
  const NorthstarDataTableRow({
    required this.cells,
    this.rowKey,
    this.selected = false,
    this.disabled = false,
    this.highlightNew = false,
    this.onTap,
  });

  /// Stable id for checkbox selection across pages.
  final Object? rowKey;

  final List<Widget> cells;
  final bool selected;
  final bool disabled;

  /// Pale yellow flash for newly inserted rows (host clears after ~800ms).
  final bool highlightNew;
  final VoidCallback? onTap;
}

/// Banner when [selectedCount] > 0: count, select-all in dataset, clear, actions.
class NorthstarDataTableSelectionBanner extends StatelessWidget {
  const NorthstarDataTableSelectionBanner({
    super.key,
    required this.selectedCount,
    this.totalInDataset,
    this.selectingBusy = false,
    this.onSelectAllInDataset,
    this.onClearDatasetSelection,
    this.leading,
    this.actions = const <Widget>[],
  });

  final int selectedCount;
  final int? totalInDataset;
  final bool selectingBusy;
  final VoidCallback? onSelectAllInDataset;
  final VoidCallback? onClearDatasetSelection;
  final Widget? leading;
  final List<Widget> actions;

  static final Color _bannerTint = NorthstarBaseTokens.light.primaryContainer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (selectedCount <= 0) {
      return const SizedBox.shrink();
    }
    return Material(
      color: _bannerTint,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space12,
          vertical: NorthstarSpacing.space8,
        ),
        child: Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: NorthstarSpacing.space8),
            ],
            Expanded(
              child: Wrap(
                spacing: NorthstarSpacing.space12,
                runSpacing: NorthstarSpacing.space4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    selectingBusy ? 'Selecting…' : '$selectedCount selected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: NorthstarBaseTokens.light.onSurface,
                    ),
                  ),
                  if (selectingBusy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (!selectingBusy &&
                      totalInDataset != null &&
                      onSelectAllInDataset != null &&
                      selectedCount < totalInDataset!)
                    TextButton(
                      onPressed: onSelectAllInDataset,
                      child: Text(
                        'Select all $totalInDataset items',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  if (!selectingBusy && onClearDatasetSelection != null)
                    TextButton(
                      onPressed: onClearDatasetSelection,
                      child: Text(
                        totalInDataset != null &&
                                selectedCount >= totalInDataset!
                            ? 'Clear all $totalInDataset items'
                            : 'Clear selection',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                ],
              ),
            ),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// Northstar data grid: async **view states**, sort, selection (cross-page via
/// [rowKey]), optional row reorder, optional fixed [columnWidths] + resize
/// drag + **shared** horizontal scroll with the body, optional [columnOrder]
/// permutation, optional header **drag reorder** via [onColumnOrderChanged].
/// Place [NorthstarPaginationBar] under the table in a [Column].
class NorthstarDataTable extends StatefulWidget {
  const NorthstarDataTable({
    super.key,
    this.automationId,
    required this.columns,
    required this.rows,
    this.viewState = NorthstarDataTableViewState.ready,
    this.errorMessage,
    this.emptyState,
    this.onErrorRetry,
    this.sortColumnIndex,
    this.sortStates,
    this.onSortColumn,
    this.zebraStripe = false,
    this.loading = false,
    this.loadingRowCount = 5,
    this.showCheckboxColumn = false,
    this.selectedRowKeys = const <Object>{},
    this.onSelectedRowKeysChanged,
    this.selectionEnabled = true,
    this.onReorderRows,
    this.columnWidths,
    this.onColumnWidthsChanged,
    this.columnOrder,
    this.onColumnOrderChanged,
  });

  final String? automationId;
  final List<NorthstarDataTableColumn> columns;
  final List<NorthstarDataTableRow> rows;

  final NorthstarDataTableViewState viewState;
  final String? errorMessage;
  final Widget? emptyState;
  final VoidCallback? onErrorRetry;

  final int? sortColumnIndex;
  final List<NorthstarTableColumnSort>? sortStates;
  final ValueChanged<int>? onSortColumn;

  final bool zebraStripe;
  final bool loading;
  final int loadingRowCount;

  final bool showCheckboxColumn;
  final Set<Object> selectedRowKeys;
  final ValueChanged<Set<Object>>? onSelectedRowKeysChanged;
  final bool selectionEnabled;

  final void Function(int oldIndex, int newIndex)? onReorderRows;

  /// When set (same length as displayed columns after [columnOrder]), uses
  /// horizontal scroll + drag on separators to resize (updates via
  /// [onColumnWidthsChanged]).
  final List<double>? columnWidths;
  final ValueChanged<List<double>>? onColumnWidthsChanged;

  /// Permutation of `0..columns.length-1`; reorders columns and row cells.
  final List<int>? columnOrder;

  /// When set, each column header shows a long-press drag handle to reorder
  /// columns; parent should persist the new permutation in [columnOrder].
  final ValueChanged<List<int>>? onColumnOrderChanged;

  static final Color _headerBg = NorthstarBaseTokens.light.surface;
  static final Color _border = NorthstarBaseTokens.light.outlineVariant;
  static final Color _newRowTint = Color.lerp(
    NorthstarBaseTokens.light.onPrimary,
    NorthstarBaseTokens.light.warning,
    0.14,
  )!;
  static final Color _hoverTint = NorthstarBaseTokens.light.surface;
  static final Color _selectedRowTint =
      NorthstarBaseTokens.light.primaryContainer;

  /// Table body uses a fixed white surface; inherit host [ThemeData] but force
  /// readable text, icons, inputs, and checkboxes (fixes dark-theme hosts).
  static ThemeData _themeForWhiteTableSurface(ThemeData base) {
    const NorthstarColorTokens t = NorthstarBaseTokens.light;
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: t.onSurface,
        displayColor: t.onSurface,
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        bodyColor: t.onSurface,
        displayColor: t.onSurface,
      ),
      iconTheme: base.iconTheme.copyWith(color: t.outline),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: t.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return base.colorScheme.primary;
          }
          if (states.contains(WidgetState.disabled)) {
            return Colors.transparent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(t.onPrimary),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        hintStyle: TextStyle(
          color: t.outline,
          fontSize: base.textTheme.bodySmall?.fontSize,
        ),
      ),
    );
  }

  @override
  State<NorthstarDataTable> createState() => _NorthstarDataTableState();
}

class _NorthstarDataTableState extends State<NorthstarDataTable> {
  ScrollController? _horizontalScrollController;

  bool get _useSharedHorizontalScroll =>
      widget.columnWidths != null &&
      widget.columnWidths!.length == widget.columns.length;

  @override
  void initState() {
    super.initState();
    if (_useSharedHorizontalScroll) {
      _horizontalScrollController = ScrollController();
    }
  }

  @override
  void didUpdateWidget(NorthstarDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool now = _useSharedHorizontalScroll;
    final bool was = oldWidget.columnWidths != null &&
        oldWidget.columnWidths!.length == oldWidget.columns.length;
    if (now && !was) {
      _horizontalScrollController = ScrollController();
    } else if (!now && was) {
      _horizontalScrollController?.dispose();
      _horizontalScrollController = null;
    }
  }

  @override
  void dispose() {
    _horizontalScrollController?.dispose();
    super.dispose();
  }

  NorthstarDataTableViewState _effectiveViewState() {
    if (widget.loading) {
      return NorthstarDataTableViewState.loading;
    }
    if (widget.viewState != NorthstarDataTableViewState.ready) {
      return widget.viewState;
    }
    return NorthstarDataTableViewState.ready;
  }

  List<NorthstarDataTableColumn> _orderedColumns() {
    if (widget.columnOrder == null ||
        widget.columnOrder!.length != widget.columns.length) {
      return widget.columns;
    }
    return widget.columnOrder!.map((int i) => widget.columns[i]).toList();
  }

  List<List<Widget>> _orderedCells() {
    final List<int>? order = widget.columnOrder;
    return widget.rows.map((NorthstarDataTableRow r) {
      if (order == null || order.length != r.cells.length) {
        return r.cells;
      }
      return order.map((int i) => r.cells[i]).toList();
    }).toList();
  }

  List<NorthstarTableColumnSort> _orderedSorts(
    List<NorthstarTableColumnSort> sorts,
    List<NorthstarDataTableColumn> orderedCols,
  ) {
    if (widget.columnOrder == null ||
        widget.columnOrder!.length != widget.columns.length) {
      return sorts;
    }
    return widget.columnOrder!.map((int i) => sorts[i]).toList();
  }

  int? _displaySortIndex(int? logicalIndex) {
    if (logicalIndex == null || widget.columnOrder == null) {
      return logicalIndex;
    }
    return widget.columnOrder!.indexOf(logicalIndex);
  }

  void _onSortDisplayColumn(int displayIndex) {
    if (widget.columnOrder == null) {
      widget.onSortColumn?.call(displayIndex);
      return;
    }
    final int logical = widget.columnOrder![displayIndex];
    widget.onSortColumn?.call(logical);
  }

  void _onReorderDisplayColumns(int fromDisplay, int toDisplay) {
    if (widget.onColumnOrderChanged == null) {
      return;
    }
    final int n = widget.columns.length;
    if (fromDisplay == toDisplay || n <= 1) {
      return;
    }
    final List<int> order =
        widget.columnOrder != null && widget.columnOrder!.length == n
            ? List<int>.from(widget.columnOrder!)
            : List<int>.generate(n, (int i) => i);
    final int moved = order.removeAt(fromDisplay);
    final int insertIndex = toDisplay > fromDisplay ? toDisplay - 1 : toDisplay;
    order.insert(insertIndex, moved);
    widget.onColumnOrderChanged!(order);
  }

  bool? _headerCheckboxValue(
    List<NorthstarDataTableRow> visibleRows,
  ) {
    if (!widget.showCheckboxColumn || visibleRows.isEmpty) {
      return false;
    }
    var any = false;
    var all = true;
    for (final NorthstarDataTableRow r in visibleRows) {
      if (r.rowKey == null) {
        continue;
      }
      final bool sel = widget.selectedRowKeys.contains(r.rowKey);
      any = any || sel;
      all = all && sel;
    }
    if (!any) {
      return false;
    }
    if (all) {
      return true;
    }
    return null;
  }

  void _toggleSelectAllVisible(List<NorthstarDataTableRow> visibleRows) {
    if (widget.onSelectedRowKeysChanged == null) {
      return;
    }
    final bool? hv = _headerCheckboxValue(visibleRows);
    final Set<Object> next = Set<Object>.from(widget.selectedRowKeys);
    final List<Object> keys = <Object>[];
    for (final NorthstarDataTableRow r in visibleRows) {
      if (r.rowKey != null) {
        keys.add(r.rowKey!);
      }
    }
    if (hv == true) {
      for (final Object k in keys) {
        next.remove(k);
      }
    } else {
      next.addAll(keys);
    }
    widget.onSelectedRowKeysChanged!(next);
  }

  void _toggleRowKey(Object? key) {
    if (key == null || widget.onSelectedRowKeysChanged == null) {
      return;
    }
    final Set<Object> next = Set<Object>.from(widget.selectedRowKeys);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    widget.onSelectedRowKeysChanged!(next);
  }

  /// Width of header + body row content when [columnWidths] drive layout
  /// (resize separators and optional row-reorder handle included).
  double _sharedHorizontalTableExtent(int columnCount) {
    final List<double>? w = widget.columnWidths;
    if (w == null || w.length != columnCount) {
      return 0;
    }
    const double edgePadding = NorthstarSpacing.space8 * 2;
    double base = edgePadding;
    if (widget.showCheckboxColumn) {
      base += 40;
    }
    for (final double cw in w) {
      base += cw;
    }
    double header = base;
    if (widget.onColumnWidthsChanged != null && columnCount > 1) {
      header += 6 * (columnCount - 1);
    }
    double body = base;
    if (widget.onReorderRows != null) {
      body += 30;
    }
    return math.max(header, body);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final NorthstarDataTableViewState vs = _effectiveViewState();
    final List<NorthstarDataTableColumn> orderedCols = _orderedColumns();
    final List<List<Widget>> orderedCells = _orderedCells();

    final List<NorthstarTableColumnSort> base = widget.sortStates ??
        List<NorthstarTableColumnSort>.filled(
          widget.columns.length,
          NorthstarTableColumnSort.inactive,
        );
    final List<NorthstarTableColumnSort> sorts =
        List<NorthstarTableColumnSort>.generate(
      widget.columns.length,
      (int i) => i < base.length ? base[i] : NorthstarTableColumnSort.inactive,
    );
    final List<NorthstarTableColumnSort> displaySorts =
        _orderedSorts(sorts, orderedCols);
    final int? displaySortIndex = _displaySortIndex(widget.sortColumnIndex);

    final void Function(int from, int to)? reorderDisplay =
        widget.onColumnOrderChanged != null ? _onReorderDisplayColumns : null;

    final Widget body = switch (vs) {
      NorthstarDataTableViewState.loading => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (var r = 0; r < widget.loadingRowCount; r++)
              _ShimmerRow(
                key: ValueKey<String>('shimmer_$r'),
                columns: orderedCols,
                checkboxGap: widget.showCheckboxColumn,
                columnWidths: widget.columnWidths,
                columnReorderLeadingGutter: widget.onColumnOrderChanged != null
                    ? _kHeaderColumnReorderGutterWidth
                    : 0,
              ),
          ],
        ),
      NorthstarDataTableViewState.error => _ErrorBody(
          message: widget.errorMessage ?? 'Something went wrong.',
          onRetry: widget.onErrorRetry,
        ),
      NorthstarDataTableViewState.empty =>
        widget.emptyState ?? const _DefaultEmptyBody(),
      NorthstarDataTableViewState.ready => _buildRowsSection(
          context,
          scheme,
          textTheme,
          orderedCols,
          orderedCells,
          displaySorts,
          displaySortIndex,
        ),
    };

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (vs != NorthstarDataTableViewState.loading)
          _HeaderRow(
            automationId: widget.automationId,
            columns: orderedCols,
            sortColumnIndex: displaySortIndex,
            sortStates: displaySorts,
            onSortColumn:
                widget.onSortColumn != null ? _onSortDisplayColumn : null,
            textTheme: textTheme,
            scheme: scheme,
            showCheckboxColumn: widget.showCheckboxColumn,
            headerCheckboxValue: _headerCheckboxValue(widget.rows),
            onHeaderCheckbox: widget.showCheckboxColumn &&
                    widget.selectionEnabled &&
                    widget.onSelectedRowKeysChanged != null
                ? () => _toggleSelectAllVisible(widget.rows)
                : null,
            selectionEnabled: widget.selectionEnabled,
            columnWidths: widget.columnWidths,
            onColumnWidthsChanged: widget.onColumnWidthsChanged,
            useSharedHorizontalScroll: _useSharedHorizontalScroll,
            onReorderDisplayColumns: reorderDisplay,
          ),
        body,
      ],
    );

    // Horizontal scroll gives unbounded width on the scroll axis; use an
    // explicit table width (not [IntrinsicWidth]) so [ReorderableListView]
    // and nested rows lay out reliably.
    final Widget tableCore = _useSharedHorizontalScroll
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double tableW = _sharedHorizontalTableExtent(
                orderedCols.length,
              );
              final double childW = math.max(constraints.maxWidth, tableW);
              return SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: SizedBox(
                    width: childW,
                    child: column,
                  ),
                ),
              );
            },
          )
        : column;

    return DecoratedBox(
      key: DsAutomationKeys.part(
        widget.automationId,
        DsAutomationKeys.elementDataTable,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: NorthstarDataTable._border),
        borderRadius: BorderRadius.circular(8),
        color: NorthstarBaseTokens.light.onPrimary,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Theme(
          data: NorthstarDataTable._themeForWhiteTableSurface(theme),
          child: tableCore,
        ),
      ),
    );
  }

  Widget _buildRowsSection(
    BuildContext context,
    ColorScheme scheme,
    TextTheme textTheme,
    List<NorthstarDataTableColumn> orderedCols,
    List<List<Widget>> orderedCells,
    List<NorthstarTableColumnSort> displaySorts,
    int? displaySortIndex,
  ) {
    final List<NorthstarDataTableRow> displayRows = <NorthstarDataTableRow>[
      for (var i = 0; i < widget.rows.length; i++)
        NorthstarDataTableRow(
          rowKey: widget.rows[i].rowKey,
          cells: orderedCells[i],
          selected: widget.rows[i].selected ||
              (widget.rows[i].rowKey != null &&
                  widget.selectedRowKeys.contains(widget.rows[i].rowKey)),
          disabled: widget.rows[i].disabled,
          highlightNew: widget.rows[i].highlightNew,
          onTap: widget.rows[i].onTap,
        ),
    ];

    if (widget.onReorderRows != null) {
      return ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        onReorder: widget.onReorderRows!,
        children: <Widget>[
          for (var i = 0; i < displayRows.length; i++)
            _BodyRow(
              key: ValueKey<Object>(
                displayRows[i].rowKey ?? i,
              ),
              automationId: widget.automationId,
              rowIndex: i,
              columns: orderedCols,
              row: displayRows[i],
              zebraStripe: widget.zebraStripe,
              stripeOn: i.isOdd,
              scheme: scheme,
              textTheme: textTheme,
              showCheckboxColumn: widget.showCheckboxColumn,
              selectionEnabled: widget.selectionEnabled,
              checkboxSelected: displayRows[i].rowKey != null &&
                  widget.selectedRowKeys.contains(displayRows[i].rowKey),
              onCheckboxChanged: () => _toggleRowKey(displayRows[i].rowKey),
              columnWidths: widget.columnWidths,
              useSharedHorizontalScroll: _useSharedHorizontalScroll,
              columnReorderLeadingGutter: widget.onColumnOrderChanged != null
                  ? _kHeaderColumnReorderGutterWidth
                  : 0,
              reorderListIndex: i,
            ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < displayRows.length; i++)
          _BodyRow(
            key: ValueKey<Object>(displayRows[i].rowKey ?? i),
            automationId: widget.automationId,
            rowIndex: i,
            columns: orderedCols,
            row: displayRows[i],
            zebraStripe: widget.zebraStripe,
            stripeOn: i.isOdd,
            scheme: scheme,
            textTheme: textTheme,
            showCheckboxColumn: widget.showCheckboxColumn,
            selectionEnabled: widget.selectionEnabled,
            checkboxSelected: displayRows[i].rowKey != null &&
                widget.selectedRowKeys.contains(displayRows[i].rowKey),
            onCheckboxChanged: () => _toggleRowKey(displayRows[i].rowKey),
            columnWidths: widget.columnWidths,
            useSharedHorizontalScroll: _useSharedHorizontalScroll,
            columnReorderLeadingGutter: widget.onColumnOrderChanged != null
                ? _kHeaderColumnReorderGutterWidth
                : 0,
          ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space24,
          vertical: NorthstarSpacing.space40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: NorthstarBaseTokens.light.onSurface,
              ),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: NorthstarSpacing.space16),
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DefaultEmptyBody extends StatelessWidget {
  const _DefaultEmptyBody();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NorthstarSpacing.space32,
          vertical: NorthstarSpacing.space40,
        ),
        child: Text(
          'No results',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: NorthstarPaginationTokens.specTextSecondary,
              ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.sortColumnIndex,
    required this.sortStates,
    required this.onSortColumn,
    required this.textTheme,
    required this.scheme,
    this.automationId,
    this.showCheckboxColumn = false,
    this.headerCheckboxValue,
    this.onHeaderCheckbox,
    this.selectionEnabled = true,
    this.columnWidths,
    this.onColumnWidthsChanged,
    this.useSharedHorizontalScroll = false,
    this.onReorderDisplayColumns,
  });

  final List<NorthstarDataTableColumn> columns;
  final int? sortColumnIndex;
  final List<NorthstarTableColumnSort> sortStates;
  final ValueChanged<int>? onSortColumn;
  final TextTheme textTheme;
  final ColorScheme scheme;
  final String? automationId;
  final bool showCheckboxColumn;
  final bool? headerCheckboxValue;
  final VoidCallback? onHeaderCheckbox;
  final bool selectionEnabled;
  final List<double>? columnWidths;
  final ValueChanged<List<double>>? onColumnWidthsChanged;
  final bool useSharedHorizontalScroll;
  final void Function(int from, int to)? onReorderDisplayColumns;

  @override
  Widget build(BuildContext context) {
    final Widget headerContent =
        columnWidths != null && columnWidths!.length == columns.length
            ? _FixedWidthHeader(
                columns: columns,
                widths: columnWidths!,
                sortColumnIndex: sortColumnIndex,
                sortStates: sortStates,
                onSortColumn: onSortColumn,
                textTheme: textTheme,
                scheme: scheme,
                automationId: automationId,
                showCheckbox: showCheckboxColumn,
                headerCheckboxValue: headerCheckboxValue,
                onHeaderCheckbox: onHeaderCheckbox,
                selectionEnabled: selectionEnabled,
                onColumnWidthsChanged: onColumnWidthsChanged,
                onReorderDisplayColumns: onReorderDisplayColumns,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NorthstarSpacing.space8,
                  vertical: NorthstarSpacing.space12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (showCheckboxColumn) ...<Widget>[
                      SizedBox(
                        width: 40,
                        child: Checkbox(
                          key: DsAutomationKeys.part(
                            automationId,
                            DsAutomationKeys.elementDataTableHeaderSelectAll,
                          ),
                          value: headerCheckboxValue,
                          tristate: true,
                          onChanged:
                              selectionEnabled && onHeaderCheckbox != null
                                  ? (_) => onHeaderCheckbox!()
                                  : null,
                        ),
                      ),
                    ],
                    for (var c = 0; c < columns.length; c++)
                      Expanded(
                        flex: columns[c].flex,
                        child: _HeaderColumnDragShell(
                          displayIndex: c,
                          automationId: automationId,
                          onReorderDisplayColumns: onReorderDisplayColumns,
                          child: _HeaderCell(
                            key: DsAutomationKeys.part(
                              automationId,
                              '${DsAutomationKeys.elementDataTableHeader}_$c',
                            ),
                            column: columns[c],
                            sort: sortStates[c],
                            isActiveSortKey: sortColumnIndex == c,
                            textTheme: textTheme,
                            scheme: scheme,
                            onTap: columns[c].sortable && onSortColumn != null
                                ? () => onSortColumn!(c)
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: NorthstarDataTable._headerBg,
        border: Border(
          bottom: BorderSide(color: NorthstarDataTable._border),
        ),
      ),
      child: columnWidths != null && !useSharedHorizontalScroll
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: headerContent,
            )
          : headerContent,
    );
  }
}

class _FixedWidthHeader extends StatefulWidget {
  const _FixedWidthHeader({
    required this.columns,
    required this.widths,
    required this.sortColumnIndex,
    required this.sortStates,
    required this.onSortColumn,
    required this.textTheme,
    required this.scheme,
    this.automationId,
    this.showCheckbox = false,
    this.headerCheckboxValue,
    this.onHeaderCheckbox,
    this.selectionEnabled = true,
    this.onColumnWidthsChanged,
    this.onReorderDisplayColumns,
  });

  final List<NorthstarDataTableColumn> columns;
  final List<double> widths;
  final int? sortColumnIndex;
  final List<NorthstarTableColumnSort> sortStates;
  final ValueChanged<int>? onSortColumn;
  final TextTheme textTheme;
  final ColorScheme scheme;
  final String? automationId;
  final bool showCheckbox;
  final bool? headerCheckboxValue;
  final VoidCallback? onHeaderCheckbox;
  final bool selectionEnabled;
  final ValueChanged<List<double>>? onColumnWidthsChanged;
  final void Function(int from, int to)? onReorderDisplayColumns;

  @override
  State<_FixedWidthHeader> createState() => _FixedWidthHeaderState();
}

class _FixedWidthHeaderState extends State<_FixedWidthHeader> {
  int? _draggingSeparator;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cells = <Widget>[];
    if (widget.showCheckbox) {
      cells.add(
        SizedBox(
          width: 40,
          child: Checkbox(
            key: DsAutomationKeys.part(
              widget.automationId,
              DsAutomationKeys.elementDataTableHeaderSelectAll,
            ),
            value: widget.headerCheckboxValue,
            tristate: true,
            onChanged:
                widget.selectionEnabled && widget.onHeaderCheckbox != null
                    ? (_) => widget.onHeaderCheckbox!()
                    : null,
          ),
        ),
      );
    }
    for (var c = 0; c < widget.columns.length; c++) {
      cells.add(
        SizedBox(
          width: widget.widths[c],
          child: _HeaderColumnDragShell(
            displayIndex: c,
            automationId: widget.automationId,
            onReorderDisplayColumns: widget.onReorderDisplayColumns,
            child: _HeaderCell(
              key: DsAutomationKeys.part(
                widget.automationId,
                '${DsAutomationKeys.elementDataTableHeader}_$c',
              ),
              column: widget.columns[c],
              sort: widget.sortStates[c],
              isActiveSortKey: widget.sortColumnIndex == c,
              textTheme: widget.textTheme,
              scheme: widget.scheme,
              onTap: widget.columns[c].sortable && widget.onSortColumn != null
                  ? () => widget.onSortColumn!(c)
                  : null,
            ),
          ),
        ),
      );
      if (c < widget.columns.length - 1 &&
          widget.onColumnWidthsChanged != null) {
        cells.add(
          MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) =>
                  setState(() => _draggingSeparator = c),
              onHorizontalDragUpdate: (DragUpdateDetails d) {
                final List<double> next = List<double>.from(widget.widths);
                final double delta = d.delta.dx;
                final double minW = widget.columns[c].minWidth;
                final double minW2 = widget.columns[c + 1].minWidth;
                if (next[c] + delta >= minW && next[c + 1] - delta >= minW2) {
                  next[c] += delta;
                  next[c + 1] -= delta;
                  widget.onColumnWidthsChanged!(next);
                }
              },
              onHorizontalDragEnd: (_) =>
                  setState(() => _draggingSeparator = null),
              child: Container(
                width: 6,
                height: 40,
                color: _draggingSeparator == c
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.25)
                    : Colors.transparent,
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: 24,
                  decoration: BoxDecoration(
                    color: NorthstarDataTable._border,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NorthstarSpacing.space8,
        vertical: NorthstarSpacing.space12,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: cells),
    );
  }
}

/// Long-press the drag grip to move a column; drop on another header to insert.
class _HeaderColumnDragShell extends StatelessWidget {
  const _HeaderColumnDragShell({
    required this.displayIndex,
    required this.child,
    this.automationId,
    this.onReorderDisplayColumns,
  });

  final int displayIndex;
  final Widget child;
  final String? automationId;
  final void Function(int from, int to)? onReorderDisplayColumns;

  @override
  Widget build(BuildContext context) {
    if (onReorderDisplayColumns == null) {
      return child;
    }

    final ThemeData theme = Theme.of(context);
    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> d) =>
          d.data != displayIndex,
      onAcceptWithDetails: (DragTargetDetails<int> d) {
        onReorderDisplayColumns!(d.data, displayIndex);
      },
      builder: (
        BuildContext context,
        List<Object?> candidateData,
        List<dynamic> rejected,
      ) {
        final bool highlight = candidateData.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            border: highlight
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: _kHeaderColumnReorderGutterWidth,
                child: Align(
                  alignment: Alignment.center,
                  child: LongPressDraggable<int>(
                    data: displayIndex,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NorthstarSpacing.space12,
                          vertical: NorthstarSpacing.space8,
                        ),
                        child: Icon(
                          Icons.view_column_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    childWhenDragging: const SizedBox(
                      width: 22,
                      height: 22,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.grab,
                      child: Icon(
                        key: DsAutomationKeys.part(
                          automationId,
                          '${DsAutomationKeys.elementDataTableHeaderColumnDrag}_$displayIndex',
                        ),
                        Icons.drag_indicator_rounded,
                        size: 18,
                        color: NorthstarPaginationTokens.specTextSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    super.key,
    required this.column,
    required this.sort,
    required this.isActiveSortKey,
    required this.textTheme,
    required this.scheme,
    this.onTap,
  });

  final NorthstarDataTableColumn column;
  final NorthstarTableColumnSort sort;
  final bool isActiveSortKey;
  final TextTheme textTheme;
  final ColorScheme scheme;
  final VoidCallback? onTap;

  IconData _icon() {
    if (!isActiveSortKey || sort == NorthstarTableColumnSort.inactive) {
      return Icons.unfold_more_rounded;
    }
    if (sort == NorthstarTableColumnSort.ascending) {
      return Icons.arrow_upward_rounded;
    }
    return Icons.arrow_downward_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: NorthstarBaseTokens.light.onSurface,
    );
    final Widget label = Text(
      column.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: column.numeric ? TextAlign.end : column.textAlign,
      style: labelStyle,
    );

    if (onTap == null) {
      return Align(
        alignment:
            column.numeric ? Alignment.centerRight : Alignment.centerLeft,
        child: label,
      );
    }

    final bool active =
        isActiveSortKey && sort != NorthstarTableColumnSort.inactive;
    return Material(
      color: active
          ? NorthstarBaseTokens.light.outlineVariant.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NorthstarSpacing.space8,
            vertical: NorthstarSpacing.space4,
          ),
          child: Row(
            mainAxisAlignment: column.numeric
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: <Widget>[
              Flexible(child: label),
              const SizedBox(width: 4),
              Icon(
                _icon(),
                size: 18,
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyRow extends StatefulWidget {
  const _BodyRow({
    super.key,
    required this.rowIndex,
    required this.columns,
    required this.row,
    required this.zebraStripe,
    required this.stripeOn,
    required this.scheme,
    required this.textTheme,
    this.automationId,
    this.showCheckboxColumn = false,
    this.selectionEnabled = true,
    this.checkboxSelected = false,
    this.onCheckboxChanged,
    this.columnWidths,
    this.useSharedHorizontalScroll = false,
    this.columnReorderLeadingGutter = 0,
    this.reorderListIndex,
  });

  final int rowIndex;
  final List<NorthstarDataTableColumn> columns;
  final NorthstarDataTableRow row;
  final bool zebraStripe;
  final bool stripeOn;
  final ColorScheme scheme;
  final TextTheme textTheme;
  final String? automationId;
  final bool showCheckboxColumn;
  final bool selectionEnabled;
  final bool checkboxSelected;
  final VoidCallback? onCheckboxChanged;
  final List<double>? columnWidths;
  final bool useSharedHorizontalScroll;
  final double columnReorderLeadingGutter;
  final int? reorderListIndex;

  @override
  State<_BodyRow> createState() => _BodyRowState();
}

class _BodyRowState extends State<_BodyRow> {
  bool _hover = false;

  Color _backgroundColor() {
    final NorthstarDataTableRow r = widget.row;
    if (r.highlightNew) {
      return NorthstarDataTable._newRowTint;
    }
    if (r.disabled) {
      return NorthstarBaseTokens.light.onPrimary;
    }
    if (r.selected || (widget.showCheckboxColumn && widget.checkboxSelected)) {
      return NorthstarDataTable._selectedRowTint;
    }
    if (_hover) {
      return NorthstarDataTable._hoverTint;
    }
    if (widget.zebraStripe && widget.stripeOn) {
      return NorthstarBaseTokens.light.surface;
    }
    return NorthstarBaseTokens.light.onPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final NorthstarDataTableRow r = widget.row;
    final bool fixedLayout = widget.columnWidths != null &&
        widget.columnWidths!.length == widget.columns.length;
    final Widget cells = Opacity(
      opacity: r.disabled ? 0.45 : 1,
      child: fixedLayout
          ? (widget.useSharedHorizontalScroll
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _fixedCells(),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _fixedCells(),
                  ),
                ))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _flexCells(),
            ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        key: DsAutomationKeys.part(
          widget.automationId,
          '${DsAutomationKeys.elementDataTableRow}_${widget.rowIndex}',
        ),
        color: _backgroundColor(),
        child: InkWell(
          onTap: r.disabled ? null : r.onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: NorthstarDataTable._border),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: NorthstarSpacing.space8,
              vertical: NorthstarSpacing.space12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.reorderListIndex != null)
                  ReorderableDragStartListener(
                    index: widget.reorderListIndex!,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 22,
                        color: NorthstarPaginationTokens.specTextSecondary,
                      ),
                    ),
                  ),
                Expanded(child: cells),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _fixedCells() {
    final List<Widget> out = <Widget>[];
    if (widget.showCheckboxColumn) {
      out.add(
        SizedBox(
          width: 40,
          child: Checkbox(
            value: widget.checkboxSelected,
            onChanged:
                widget.selectionEnabled && widget.onCheckboxChanged != null
                    ? (_) => widget.onCheckboxChanged!()
                    : null,
          ),
        ),
      );
    }
    for (var c = 0; c < widget.columns.length; c++) {
      Widget cell = c < widget.row.cells.length
          ? widget.row.cells[c]
          : const SizedBox.shrink();
      if (widget.columnReorderLeadingGutter > 0) {
        cell = Padding(
          padding: EdgeInsets.only(left: widget.columnReorderLeadingGutter),
          child: cell,
        );
      }
      out.add(
        SizedBox(
          width: widget.columnWidths![c],
          child: Align(
            alignment: widget.columns[c].numeric
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: cell,
            ),
          ),
        ),
      );
    }
    return out;
  }

  List<Widget> _flexCells() {
    final List<Widget> out = <Widget>[];
    if (widget.showCheckboxColumn) {
      out.add(
        SizedBox(
          width: 40,
          child: Checkbox(
            value: widget.checkboxSelected,
            onChanged:
                widget.selectionEnabled && widget.onCheckboxChanged != null
                    ? (_) => widget.onCheckboxChanged!()
                    : null,
          ),
        ),
      );
    }
    for (var c = 0; c < widget.columns.length; c++) {
      Widget cell = c < widget.row.cells.length
          ? widget.row.cells[c]
          : const SizedBox.shrink();
      if (widget.columnReorderLeadingGutter > 0) {
        cell = Padding(
          padding: EdgeInsets.only(left: widget.columnReorderLeadingGutter),
          child: cell,
        );
      }
      out.add(
        Expanded(
          flex: widget.columns[c].flex,
          child: Align(
            alignment: widget.columns[c].numeric
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: cell,
          ),
        ),
      );
    }
    return out;
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow({
    super.key,
    required this.columns,
    this.checkboxGap = false,
    this.columnWidths,
    this.columnReorderLeadingGutter = 0,
  });

  final List<NorthstarDataTableColumn> columns;
  final bool checkboxGap;
  final List<double>? columnWidths;
  final double columnReorderLeadingGutter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: NorthstarDataTable._border),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: NorthstarSpacing.space8,
        vertical: NorthstarSpacing.space12,
      ),
      child: Row(
        children: <Widget>[
          if (checkboxGap) const SizedBox(width: 40),
          for (var i = 0; i < columns.length; i++)
            columnWidths != null && columnWidths!.length == columns.length
                ? SizedBox(
                    width: columnWidths![i],
                    child: columnReorderLeadingGutter > 0
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: columnReorderLeadingGutter,
                            ),
                            child: _shimmerBar(),
                          )
                        : _shimmerBar(),
                  )
                : Expanded(
                    flex: columns[i].flex,
                    child: columnReorderLeadingGutter > 0
                        ? Padding(
                            padding: EdgeInsets.only(
                              left: columnReorderLeadingGutter,
                            ),
                            child: _shimmerBar(),
                          )
                        : _shimmerBar(),
                  ),
        ],
      ),
    );
  }

  Widget _shimmerBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 14,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: NorthstarBaseTokens.light.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Returns updated sort states and active column after one header tap
/// (inactive → ascending → descending → inactive).
({List<NorthstarTableColumnSort> sorts, int? activeColumn})
    northstarTableCycleSortOnColumn({
  required int columnIndex,
  required List<NorthstarTableColumnSort> sortStates,
}) {
  final List<NorthstarTableColumnSort> next =
      List<NorthstarTableColumnSort>.from(sortStates);
  final NorthstarTableColumnSort cur = next[columnIndex];
  for (var i = 0; i < next.length; i++) {
    if (i != columnIndex) {
      next[i] = NorthstarTableColumnSort.inactive;
    }
  }
  switch (cur) {
    case NorthstarTableColumnSort.inactive:
      next[columnIndex] = NorthstarTableColumnSort.ascending;
      return (sorts: next, activeColumn: columnIndex);
    case NorthstarTableColumnSort.ascending:
      next[columnIndex] = NorthstarTableColumnSort.descending;
      return (sorts: next, activeColumn: columnIndex);
    case NorthstarTableColumnSort.descending:
      next[columnIndex] = NorthstarTableColumnSort.inactive;
      return (sorts: next, activeColumn: null);
  }
}
