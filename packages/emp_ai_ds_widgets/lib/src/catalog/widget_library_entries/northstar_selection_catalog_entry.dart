import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_chip.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_selection.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarSelectionCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_selection',
    title: 'NorthstarSelection',
    description:
        'Figma **Selection**: [NorthstarCheckboxRow] (incl. **indeterminate**), [NorthstarRadioRow] '
        '(under [NorthstarRadioGroup] / [RadioGroup]), [NorthstarSwitchRow] with **12px** control–label gap '
        'and **4px** / **2px** label–description; '
        '[NorthstarSelectionGroup] (**16px** after legend, **12px** between items, **8px** before error, '
        'optional **n/m** counter). [NorthstarBooleanViewOnly] / [NorthstarSelectionSummaryField] for '
        'read-only. [NorthstarBatchActionBar] for table multi-select (optional [leading] icon + divider). '
        '**States** tab mirrors Figma **selection-base** / **State** (active·disabled × default·selected, '
        'checkbox indeterminate, radio, switch). Filter [NorthstarChip]s support optional [tooltipMessage] '
        '(dark tooltip). Wrap with [NorthstarSelectionControlsTheme] if you compose custom controls.',
    code: r'''
  // --- Scenario: Checkbox / radio / switch (standalone rows) ---
  // Checkbox + radio + switch rows with 12px gap; switch uses 2px label–description gap.
  NorthstarSelectionControlsTheme(
    child: Column(
      children: <Widget>[
        NorthstarCheckboxRow(
          label: 'Label',
          description: 'This is a sample content',
          value: checked,
          onChanged: (bool? v) => setState(() => checked = v == true),
        ),
        NorthstarRadioGroup<String>(
          groupValue: radioValue,
          onChanged: (String? v) => setState(() {
            if (v != null) radioValue = v;
          }),
          children: <Widget>[
            NorthstarRadioRow<String>(label: 'Option A', value: 'a'),
            NorthstarRadioRow<String>(label: 'Option B', value: 'b'),
          ],
        ),
        NorthstarSwitchRow(
          label: 'Wi-Fi',
          description: 'This is a sample content',
          value: wifiOn,
          onChanged: (bool v) => setState(() => wifiOn = v),
        ),
      ],
    ),
  );

  // --- Scenario: Group + counter + error ---
  // Legend, helper, n/m counter (dark text at max), validate → error under list.
  // Counter should count only known option ids so it stays in sync with checkboxes.
  static const List<String> kScheduleIds = ['Early', 'Mid', 'Late', 'Flex'];
  final int picked = kScheduleIds.where(selection.contains).length;
  NorthstarSelectionControlsTheme(
    child: NorthstarSelectionGroup(
      label: 'Work schedule',
      requiredField: true,
      helper: 'Select all applicable schedule',
      counterText: '$picked/$maxPick',
      counterAtMax: picked >= maxPick,
      error: showError ? 'Please select at least one' : null,
      children: <Widget>[
        for (final String id in kScheduleIds)
          NorthstarCheckboxRow(
            label: id,
            value: selection.contains(id),
            onChanged: (bool? v) => updateSelection(id, v == true, maxPick, kScheduleIds),
          ),
      ],
    ),
  );

  // --- Scenario: Indeterminate (table select-all) ---
  NorthstarCheckboxRow(
    label: 'All rows on this page',
    value: allSelected ? true : (someSelected ? null : false),
    onChanged: (bool? v) => setAllRows(v == true),
  );

  // --- Scenario: View only ---
  NorthstarBooleanViewOnly(fieldLabel: 'Notifications', selected: true);
  NorthstarSelectionSummaryField(
    fieldLabel: 'Industry',
    valueText: 'Business development, Marketing & sales',
  );

  // --- Scenario: Chips (choice + multi-select, filter chips) ---
  NorthstarChip(
    useCase: NorthstarChipUseCase.filter,
    label: 'Flexible',
    tooltipMessage:
        'No fixed/definite shift for as long as 9-hr shift rendered',
    ...
  );

  // --- Scenario: Batch bar (table multi-select, Figma bulk bar) ---
  NorthstarBatchActionBar(
    leading: Icon(Icons.description_outlined),
    primaryLine: '4 pending requests selected',
    secondaryLine: '4 request types selected',
    onDeselect: clearSelection,
    actions: <Widget>[/* Reject / Approve */],
  );

  // --- Scenario: State matrix (selection-base component set) ---
  // Active vs Disabled columns; rows: checkbox default/selected/indeterminate, radio, switch.
  // Optional Transform.scale for large vs standard hit target.
  ''',
    preview: (BuildContext context) => const _NorthstarSelectionCatalogDemo(),
  );
}

class _NorthstarSelectionCatalogDemo extends StatefulWidget {
  const _NorthstarSelectionCatalogDemo();

  @override
  State<_NorthstarSelectionCatalogDemo> createState() =>
      _NorthstarSelectionCatalogDemoState();
}

enum _SelectionCatalogTab {
  checkboxRadioSwitch,
  selectionStates,
  groupErrorCounter,
  indeterminate,
  viewOnly,
  chips,
  batchBar,
}

class _NorthstarSelectionCatalogDemoState
    extends State<_NorthstarSelectionCatalogDemo> {
  static const List<String> _kWorkScheduleIds = <String>[
    'Early',
    'Mid',
    'Late',
    'Flex',
  ];

  _SelectionCatalogTab _tab = _SelectionCatalogTab.checkboxRadioSwitch;

  bool _cb1 = true;
  bool _cb2 = false;
  String _radio = 'b';
  bool _sw1 = true;
  bool _sw2 = false;

  /// Keys are only `_kWorkScheduleIds` values so the counter matches visible checkboxes.
  final Set<String> _groupSet = <String>{'Early', 'Mid'};
  bool _showGroupError = false;

  int get _workSchedulePickCount =>
      _kWorkScheduleIds.where(_groupSet.contains).length;

  bool _rowA = true;
  bool _rowB = false;
  bool _rowC = true;

  final Set<String> _chipSingle = <String>{'30d'};
  final Set<String> _chipMulti = <String>{'mid', 'flex'};

  bool _stateMatrixLarge = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

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
              for (final _SelectionCatalogTab t in _SelectionCatalogTab.values)
                ChoiceChip(
                  label: Text(_tabLabel(t)),
                  selected: _tab == t,
                  onSelected: (_) => setState(() => _tab = t),
                ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          switch (_tab) {
            _SelectionCatalogTab.checkboxRadioSwitch => _buildBasic(textTheme),
            _SelectionCatalogTab.selectionStates => _buildStateMatrix(textTheme),
            _SelectionCatalogTab.groupErrorCounter => _buildGroup(textTheme),
            _SelectionCatalogTab.indeterminate => _buildIndeterminate(textTheme),
            _SelectionCatalogTab.viewOnly => _buildViewOnly(textTheme),
            _SelectionCatalogTab.chips => _buildChips(textTheme),
            _SelectionCatalogTab.batchBar => _buildBatch(textTheme),
          },
        ],
      ),
    );
  }

  Widget _scaleStateControl(Widget child) {
    if (!_stateMatrixLarge) {
      return child;
    }
    return Transform.scale(
      scale: 1.18,
      alignment: AlignmentDirectional.centerStart,
      child: child,
    );
  }

  Widget _buildStateMatrix(TextTheme textTheme) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    Widget cell(Widget w) => _scaleStateControl(w);

    return NorthstarSelectionControlsTheme(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Selection base · states',
            style: textTheme.titleSmall,
          ),
          Text(
            'Figma **selection-base** / **State**: Active vs Disabled × Default vs Selected; '
            'checkbox includes indeterminate. Toggle **Large** for size-large-style targets.',
            style: textTheme.bodySmall?.copyWith(color: ns.onSurfaceVariant),
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          Row(
            children: <Widget>[
              Text(
                'Large size',
                style: textTheme.labelLarge,
              ),
              const SizedBox(width: NorthstarSpacing.space12),
              Switch(
                value: _stateMatrixLarge,
                onChanged: (bool v) => setState(() => _stateMatrixLarge = v),
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 120,
                child: Text(
                  '',
                  style: textTheme.labelSmall,
                ),
              ),
              Expanded(
                child: Text(
                  'Active',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Disabled',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _stateMatrixRow(
            textTheme,
            'Checkbox · default',
            cell(
              NorthstarCheckboxRow(
                label: 'Label',
                description: 'This is a sample content',
                value: false,
                onChanged: (_) => setState(() {}),
              ),
            ),
            cell(
              const NorthstarCheckboxRow(
                label: 'Label',
                description: 'This is a sample content',
                value: false,
                enabled: false,
                onChanged: null,
              ),
            ),
          ),
          _stateMatrixRow(
            textTheme,
            'Checkbox · selected',
            cell(
              NorthstarCheckboxRow(
                label: 'Label',
                description: 'This is a sample content',
                value: true,
                onChanged: (_) => setState(() {}),
              ),
            ),
            cell(
              const NorthstarCheckboxRow(
                label: 'Label',
                description: 'This is a sample content',
                value: true,
                enabled: false,
                onChanged: null,
              ),
            ),
          ),
          _stateMatrixRow(
            textTheme,
            'Checkbox · indeterminate',
            cell(
              NorthstarCheckboxRow(
                label: 'Label',
                description: 'This is a sample content',
                value: null,
                onChanged: (_) => setState(() {}),
              ),
            ),
            cell(
              const NorthstarCheckboxRow(
                label: 'Label',
                description: 'This is a sample content',
                value: null,
                enabled: false,
                onChanged: null,
              ),
            ),
          ),
          _stateMatrixRow(
            textTheme,
            'Radio · default',
            cell(
              NorthstarRadioGroup<String>(
                groupValue: 'b',
                onChanged: (_) => setState(() {}),
                children: const <Widget>[
                  NorthstarRadioRow<String>(
                    value: 'a',
                    label: 'Label',
                    description: 'This is a sample content',
                  ),
                ],
              ),
            ),
            cell(
              IgnorePointer(
                child: NorthstarRadioGroup<String>(
                  groupValue: 'b',
                  onChanged: (_) {},
                  children: const <Widget>[
                    NorthstarRadioRow<String>(
                      value: 'a',
                      label: 'Label',
                      description: 'This is a sample content',
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _stateMatrixRow(
            textTheme,
            'Radio · selected',
            cell(
              NorthstarRadioGroup<String>(
                groupValue: 'a',
                onChanged: (_) => setState(() {}),
                children: const <Widget>[
                  NorthstarRadioRow<String>(
                    value: 'a',
                    label: 'Label',
                    description: 'This is a sample content',
                  ),
                ],
              ),
            ),
            cell(
              IgnorePointer(
                child: NorthstarRadioGroup<String>(
                  groupValue: 'a',
                  onChanged: (_) {},
                  children: const <Widget>[
                    NorthstarRadioRow<String>(
                      value: 'a',
                      label: 'Label',
                      description: 'This is a sample content',
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _stateMatrixRow(
            textTheme,
            'Switch · off',
            cell(
              NorthstarSwitchRow(
                label: 'Label',
                description: 'This is a sample content',
                value: false,
                onChanged: (_) => setState(() {}),
              ),
            ),
            cell(
              const NorthstarSwitchRow(
                label: 'Label',
                description: 'This is a sample content',
                value: false,
                enabled: false,
                onChanged: null,
              ),
            ),
          ),
          _stateMatrixRow(
            textTheme,
            'Switch · on',
            cell(
              NorthstarSwitchRow(
                label: 'Label',
                description: 'This is a sample content',
                value: true,
                onChanged: (_) => setState(() {}),
              ),
            ),
            cell(
              const NorthstarSwitchRow(
                label: 'Label',
                description: 'This is a sample content',
                value: true,
                enabled: false,
                onChanged: null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateMatrixRow(
    TextTheme textTheme,
    String rowTitle,
    Widget active,
    Widget disabled,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NorthstarSpacing.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              rowTitle,
              style: textTheme.bodySmall?.copyWith(
                color: NorthstarColorTokens.of(context).onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: active),
          Expanded(child: disabled),
        ],
      ),
    );
  }

  Widget _buildBasic(TextTheme textTheme) {
    return NorthstarSelectionControlsTheme(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Standalone rows', style: textTheme.titleSmall),
          const SizedBox(height: NorthstarSpacing.space12),
          NorthstarCheckboxRow(
            automationId: 'demo_cb1',
            label: 'Label',
            description: 'This is a sample content',
            value: _cb1,
            onChanged: (bool? v) => setState(() => _cb1 = v == true),
          ),
          NorthstarCheckboxRow(
            label: 'Second option',
            description: 'Toggle independently',
            value: _cb2,
            onChanged: (bool? v) => setState(() => _cb2 = v == true),
          ),
          NorthstarCheckboxRow(
            label: 'Disabled',
            description: 'Greyed out',
            value: false,
            enabled: false,
            onChanged: (_) {},
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          NorthstarRadioGroup<String>(
            groupValue: _radio,
            onChanged: (String? v) => setState(() {
              if (v != null) {
                _radio = v;
              }
            }),
            children: <Widget>[
              NorthstarRadioRow<String>(
                label: 'Option A',
                description: 'This is a sample content',
                value: 'a',
              ),
              NorthstarRadioRow<String>(
                label: 'Option B',
                value: 'b',
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          NorthstarSwitchRow(
            label: 'Label',
            description: 'This is a sample content',
            value: _sw1,
            onChanged: (bool v) => setState(() => _sw1 = v),
          ),
          NorthstarSwitchRow(
            label: 'Another switch',
            value: _sw2,
            onChanged: (bool v) => setState(() => _sw2 = v),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(TextTheme textTheme) {
    const int maxPick = 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Group + counter + error', style: textTheme.titleSmall),
        const SizedBox(height: NorthstarSpacing.space12),
        NorthstarSelectionControlsTheme(
          child: NorthstarSelectionGroup(
            automationId: 'demo_group',
            label: 'Work schedule',
            requiredField: true,
            helper: 'Select all applicable schedule',
            counterText: '$_workSchedulePickCount/$maxPick',
            counterAtMax: _workSchedulePickCount >= maxPick,
            error: _showGroupError ? 'Please select at least one' : null,
            children: <Widget>[
              for (final String id in _kWorkScheduleIds)
                NorthstarCheckboxRow(
                  label: id,
                  value: _groupSet.contains(id),
                  onChanged: (bool? v) {
                    setState(() {
                      _groupSet.removeWhere(
                        (String e) => !_kWorkScheduleIds.contains(e),
                      );
                      if (v == true) {
                        if (_workSchedulePickCount < maxPick) {
                          _groupSet.add(id);
                        }
                      } else {
                        _groupSet.remove(id);
                      }
                      _showGroupError = false;
                    });
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space12),
        OutlinedButton(
          onPressed: () => setState(() {
            _showGroupError = _groupSet.isEmpty;
          }),
          child: const Text('Validate (empty → error)'),
        ),
      ],
    );
  }

  bool? get _parentTri {
    final int n = [_rowA, _rowB, _rowC].where((bool e) => e).length;
    if (n == 0) {
      return false;
    }
    if (n == 3) {
      return true;
    }
    return null;
  }

  Widget _buildIndeterminate(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Parent checkbox (select all / partial)', style: textTheme.titleSmall),
        const SizedBox(height: NorthstarSpacing.space12),
        NorthstarSelectionControlsTheme(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              NorthstarCheckboxRow(
                label: 'All rows on this page',
                value: _parentTri,
                onChanged: (bool? v) {
                  setState(() {
                    final bool on = v == true;
                    _rowA = _rowB = _rowC = on;
                  });
                },
              ),
              const SizedBox(height: NorthstarSpacing.space12),
              NorthstarCheckboxRow(
                label: 'Row A',
                value: _rowA,
                onChanged: (bool? v) => setState(() => _rowA = v == true),
              ),
              NorthstarCheckboxRow(
                label: 'Row B',
                value: _rowB,
                onChanged: (bool? v) => setState(() => _rowB = v == true),
              ),
              NorthstarCheckboxRow(
                label: 'Row C',
                value: _rowC,
                onChanged: (bool? v) => setState(() => _rowC = v == true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewOnly(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('View-only summaries', style: textTheme.titleSmall),
        const SizedBox(height: NorthstarSpacing.space16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: NorthstarBooleanViewOnly(
                fieldLabel: 'Notifications',
                selected: true,
              ),
            ),
            Expanded(
              child: NorthstarBooleanViewOnly(
                fieldLabel: 'Marketing',
                selected: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: NorthstarSpacing.space24),
        NorthstarSelectionSummaryField(
          fieldLabel: 'Industry',
          valueText: 'Business development, Marketing & sales, Product development',
        ),
        const SizedBox(height: NorthstarSpacing.space16),
        NorthstarSelectionSummaryField(
          fieldLabel: 'Availability',
          valueText: '30 days',
        ),
      ],
    );
  }

  Widget _buildChips(TextTheme textTheme) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    const List<String> avail = <String>['14 days', '30 days', '60 days', '90 days'];
    const List<String> sched = <String>['Early', 'Mid', 'Late', 'Flex', 'Remote'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Choice & multi-select chips (filter pattern)', style: textTheme.titleSmall),
        const SizedBox(height: NorthstarSpacing.space12),
        Text(
          'Availability *',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          'Select one',
          style: textTheme.bodySmall?.copyWith(
            color: ns.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space12),
        Wrap(
          spacing: NorthstarSpacing.space8,
          runSpacing: NorthstarSpacing.space8,
          children: <Widget>[
            for (final String id in avail)
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: id,
                selected: _chipSingle.contains(id),
                onSelected: (_) {
                  setState(() {
                    _chipSingle
                      ..clear()
                      ..add(id);
                  });
                  catalogPreviewSnack(context, 'Availability: $id');
                },
              ),
          ],
        ),
        const SizedBox(height: NorthstarSpacing.space24),
        Text(
          'Work schedule *',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          'Select all applicable',
          style: textTheme.bodySmall?.copyWith(
            color: ns.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space12),
        Wrap(
          spacing: NorthstarSpacing.space8,
          runSpacing: NorthstarSpacing.space8,
          children: <Widget>[
            for (final String id in sched)
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: id,
                leadingIcon:
                    _chipMulti.contains(id) ? null : Icons.add_rounded,
                tooltipMessage: id == 'Flex'
                    ? 'No fixed/definite shift for as long as 9-hr shift rendered'
                    : null,
                selected: _chipMulti.contains(id),
                onSelected: (_) {
                  setState(() {
                    if (_chipMulti.contains(id)) {
                      _chipMulti.remove(id);
                    } else {
                      _chipMulti.add(id);
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBatch(TextTheme textTheme) {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Batch action bar', style: textTheme.titleSmall),
        const SizedBox(height: NorthstarSpacing.space12),
        NorthstarBatchActionBar(
          automationId: 'demo_batch',
          leading: const Icon(Icons.description_outlined),
          primaryLine: '4 pending requests selected',
          secondaryLine: '4 request types selected',
          onDeselect: () => catalogPreviewSnack(context, 'Deselect all'),
          actions: <Widget>[
            const SizedBox(width: NorthstarSpacing.space8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ns.error,
                foregroundColor: ns.onError,
              ),
              onPressed: () => catalogPreviewSnack(context, 'Reject'),
              child: const Text('Reject'),
            ),
            const SizedBox(width: NorthstarSpacing.space8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ns.success,
                foregroundColor: ns.onSuccess,
              ),
              onPressed: () => catalogPreviewSnack(context, 'Approve'),
              child: const Text('Approve'),
            ),
          ],
        ),
      ],
    );
  }

  static String _tabLabel(_SelectionCatalogTab t) {
    return switch (t) {
      _SelectionCatalogTab.checkboxRadioSwitch => 'Checkbox / radio / switch',
      _SelectionCatalogTab.selectionStates => 'States matrix',
      _SelectionCatalogTab.groupErrorCounter => 'Group + counter',
      _SelectionCatalogTab.indeterminate => 'Indeterminate',
      _SelectionCatalogTab.viewOnly => 'View only',
      _SelectionCatalogTab.chips => 'Chips',
      _SelectionCatalogTab.batchBar => 'Batch bar',
    };
  }
}
