import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_menu.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarMenuCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_menu',
    title: 'NorthstarMenuField / NorthstarMenuPanel',
    description:
        'Elevated menu (8px radius, list max 320px): optional header, search, '
        'single or multi select, wrapped labels. Field supports summary, '
        'first + N more, chips below, or chips inside.',
    code: '''
  NorthstarMenuField(
    label: 'Language',
    items: items,
    selectedIds: selected,
    onChanged: (next) => setState(() => selected = next),
    selectionMode: NorthstarMenuSelectionMode.multiple,
    closedDisplayMode: NorthstarMenuClosedDisplayMode.firstPlusMore,
    showSearchInMenu: true,
    showCheckboxesInMenu: true,
    automationId: 'demo_menu',
  )
  ''',
    preview: (BuildContext context) => const _NorthstarMenuCatalogDemo(),
  );
}

class _NorthstarMenuCatalogDemo extends StatefulWidget {
  const _NorthstarMenuCatalogDemo();

  @override
  State<_NorthstarMenuCatalogDemo> createState() =>
      _NorthstarMenuCatalogDemoState();
}

class _NorthstarMenuCatalogDemoState extends State<_NorthstarMenuCatalogDemo> {
  NorthstarMenuSelectionMode _mode = NorthstarMenuSelectionMode.single;
  NorthstarMenuClosedDisplayMode _display =
      NorthstarMenuClosedDisplayMode.summary;

  final Set<String> _plainSelected = <String>{};
  final Set<String> _langSelected = <String>{'en_us', 'de'};
  final Set<String> _peopleSelected = <String>{'e1'};
  final Set<String> _longSelected = <String>{};
  String? _iconPanelSelected = 'i2';

  static const List<NorthstarMenuItemData> _plainItems =
      <NorthstarMenuItemData>[
    NorthstarMenuItemData(id: 's1', label: 'Success'),
    NorthstarMenuItemData(id: 's2', label: 'Pending'),
    NorthstarMenuItemData(id: 's3', label: 'Failed'),
    NorthstarMenuItemData(id: 's4', label: 'For approval'),
    NorthstarMenuItemData(id: 's5', label: 'Rejected', enabled: false),
  ];

  static const List<NorthstarMenuItemData> _iconItems = <NorthstarMenuItemData>[
    NorthstarMenuItemData(
      id: 'i1',
      label: 'Add',
      leadingIcon: Icons.add,
    ),
    NorthstarMenuItemData(
      id: 'i2',
      label: 'Edit',
      leadingIcon: Icons.edit_outlined,
    ),
    NorthstarMenuItemData(
      id: 'i3',
      label: 'More information',
      leadingIcon: Icons.info_outline,
    ),
    NorthstarMenuItemData(
      id: 'i4',
      label: 'Archive',
      leadingIcon: Icons.archive_outlined,
    ),
    NorthstarMenuItemData(
      id: 'i5',
      label: 'Delete',
      leadingIcon: Icons.delete_outline,
      destructive: true,
    ),
  ];

  static const List<NorthstarMenuItemData> _languageItems =
      <NorthstarMenuItemData>[
    NorthstarMenuItemData(id: 'ar', label: 'Arabic'),
    NorthstarMenuItemData(id: 'en_us', label: 'English (US)'),
    NorthstarMenuItemData(id: 'en_uk', label: 'English (UK)'),
    NorthstarMenuItemData(id: 'fil', label: 'Filipino'),
    NorthstarMenuItemData(id: 'de', label: 'German'),
  ];

  static const List<NorthstarMenuItemData> _longItems = <NorthstarMenuItemData>[
    NorthstarMenuItemData(
      id: 'c1',
      label: 'International Consolidated Airlines Group SA',
    ),
    NorthstarMenuItemData(
      id: 'c2',
      label: 'Muenchener Rueckversicherungs Gesellschaft in Muenchen AG',
    ),
    NorthstarMenuItemData(
      id: 'c3',
      label:
          'Locus International Centre for Entrepreneurship Development and Incubation Services Limited',
    ),
  ];

  static const List<NorthstarMenuItemData> _peopleItems =
      <NorthstarMenuItemData>[
    NorthstarMenuItemData(
      id: 'e1',
      label: 'Ellie Williams',
      subtitle: 'Web Developer',
      avatarInitials: 'EW',
    ),
    NorthstarMenuItemData(
      id: 'e2',
      label: 'Joel Miller',
      subtitle: 'Engineering lead',
      avatarInitials: 'JM',
    ),
    NorthstarMenuItemData(
      id: 'e3',
      label: 'Tommy Miller',
      subtitle: 'Designer',
      avatarInitials: 'TM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Configure demo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          SegmentedButton<NorthstarMenuSelectionMode>(
            segments: const <ButtonSegment<NorthstarMenuSelectionMode>>[
              ButtonSegment<NorthstarMenuSelectionMode>(
                value: NorthstarMenuSelectionMode.single,
                label: Text('Single'),
              ),
              ButtonSegment<NorthstarMenuSelectionMode>(
                value: NorthstarMenuSelectionMode.multiple,
                label: Text('Multi'),
              ),
            ],
            selected: <NorthstarMenuSelectionMode>{_mode},
            onSelectionChanged: (Set<NorthstarMenuSelectionMode> next) {
              setState(() {
                _mode = next.first;
                if (_mode == NorthstarMenuSelectionMode.single) {
                  if (_langSelected.length > 1) {
                    final String keep = _langSelected.first;
                    _langSelected
                      ..clear()
                      ..add(keep);
                  }
                  if (_peopleSelected.length > 1) {
                    final String keep = _peopleSelected.first;
                    _peopleSelected
                      ..clear()
                      ..add(keep);
                  }
                }
              });
            },
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          SegmentedButton<NorthstarMenuClosedDisplayMode>(
            segments: const <ButtonSegment<NorthstarMenuClosedDisplayMode>>[
              ButtonSegment<NorthstarMenuClosedDisplayMode>(
                value: NorthstarMenuClosedDisplayMode.summary,
                label: Text('Summary'),
              ),
              ButtonSegment<NorthstarMenuClosedDisplayMode>(
                value: NorthstarMenuClosedDisplayMode.firstPlusMore,
                label: Text('+N more'),
              ),
              ButtonSegment<NorthstarMenuClosedDisplayMode>(
                value: NorthstarMenuClosedDisplayMode.chipsBelowField,
                label: Text('Chips below'),
              ),
              ButtonSegment<NorthstarMenuClosedDisplayMode>(
                value: NorthstarMenuClosedDisplayMode.chipsInsideField,
                label: Text('Chips in'),
              ),
            ],
            selected: <NorthstarMenuClosedDisplayMode>{_display},
            onSelectionChanged: (Set<NorthstarMenuClosedDisplayMode> next) {
              setState(() => _display = next.first);
            },
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Plain list (single-select closes menu)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarMenuField(
            label: 'Status',
            items: _plainItems,
            selectedIds: _plainSelected,
            onChanged: (Set<String> v) => setState(() {
              _plainSelected
                ..clear()
                ..addAll(v);
            }),
            selectionMode: NorthstarMenuSelectionMode.single,
            closedDisplayMode: NorthstarMenuClosedDisplayMode.summary,
            placeholder: 'Select',
            showSearchInMenu: false,
            automationId: 'catalog_menu_plain',
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Icon + text (includes destructive row)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarMenuPanel(
            filteredItems: _iconItems,
            selectionMode: NorthstarMenuSelectionMode.single,
            selectedIds: _iconPanelSelected == null
                ? <String>{}
                : <String>{_iconPanelSelected!},
            onItemTap: (NorthstarMenuItemData item) {
              setState(() => _iconPanelSelected = item.id);
            },
            minWidth: 220,
            maxWidth: 280,
            automationId: 'catalog_menu_panel_static',
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Languages — search + checkboxes when multi',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarMenuField(
            label: 'Language',
            items: _languageItems,
            selectedIds: _langSelected,
            onChanged: (Set<String> v) => setState(() {
              _langSelected
                ..clear()
                ..addAll(v);
            }),
            selectionMode: _mode,
            closedDisplayMode: _display,
            placeholder: 'Select languages',
            showSearchInMenu: true,
            searchHint: 'Search for language',
            showCheckboxesInMenu: _mode == NorthstarMenuSelectionMode.multiple,
            menuHeader: NorthstarMenuHeaderData(
              title: 'Header',
              onBack: () {},
            ),
            automationId: 'catalog_menu_lang',
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Long labels (wrap, leading top-aligned)',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarMenuField(
            label: 'Client name',
            items: _longItems,
            selectedIds: _longSelected,
            onChanged: (Set<String> v) => setState(() {
              _longSelected
                ..clear()
                ..addAll(v);
            }),
            selectionMode: NorthstarMenuSelectionMode.multiple,
            closedDisplayMode: NorthstarMenuClosedDisplayMode.summary,
            placeholder: 'Select',
            showSearchInMenu: true,
            searchHint: 'Search for keyword',
            showCheckboxesInMenu: true,
            automationId: 'catalog_menu_long',
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Supervisor — avatar + subtitle',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarMenuField(
            label: 'Immediate supervisor',
            items: _peopleItems,
            selectedIds: _peopleSelected,
            onChanged: (Set<String> v) => setState(() {
              _peopleSelected
                ..clear()
                ..addAll(v);
            }),
            selectionMode: _mode,
            closedDisplayMode: _display,
            placeholder: 'Select',
            showSearchInMenu: true,
            searchHint: 'Search for name',
            showCheckboxesInMenu: _mode == NorthstarMenuSelectionMode.multiple,
            automationId: 'catalog_menu_people',
          ),
        ],
      ),
    );
  }
}
