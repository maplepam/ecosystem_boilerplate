import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_filter_dropdown.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarFilterDropdownCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_filter_dropdown',
    title: 'NorthstarFilterDropdown · All filters · Group',
    description:
        'Figma **Filter** bar: [NorthstarFilterDropdown] (required [leadingIcon], '
        '[placeholder], optional [valueLabel], [additionalSelectionCount] **+N** '
        'badge, chevron; **8** radius; label cap [labelMaxCharacters] default **20** '
        'and [maxLabelWidth] default **124** with ellipsis). '
        '[NorthstarAllFiltersButton] — filter icon, label, [activeFilterCount] badge. '
        '[NorthstarFilterGroup] — **8** gap, **16** padding. Parent owns menus / sheets. '
        'Catalog preview is **live**: pick users/roles from [showMenu], locations from a '
        'multi-select sheet, **All filters** summarizes and can clear.',
    code: r'''
  // --- Options: your list (constants, API, enums mapped to labels) -------------
  static const List<String> roleOptions = [
    'Data Engineer', 'Designer', 'Manager',
  ];
  
  // --- State: update in setState / Riverpod / Bloc -----------------------------
  String? selectedRole;           // null → placeholder on chip
  final List<String> cities = []; // multi-select
  final GlobalKey roleFilterKey = GlobalKey();
  
  // --- 1) Single-select filter dropdown + anchored menu ------------------------
  NorthstarFilterDropdown(
    key: roleFilterKey,
    leadingIcon: Icons.badge_outlined,
    placeholder: 'Role',
    valueLabel: selectedRole,
    onTap: () async {
      final String? picked = await showNorthstarFilterMenu<String>(
  context: context,
  anchorKey: roleFilterKey,
  items: [
    const PopupMenuItem(value: '', child: Text('Any')),
    for (final String r in roleOptions)
      PopupMenuItem(value: r, child: Text(r)),
  ],
      );
      if (!context.mounted || picked == null) return;
      setState(() => selectedRole = picked.isEmpty ? null : picked);
    },
  );
  
  // --- 2) Multi-select: first row + "+N" ---------------------------------------
  NorthstarFilterDropdown(
    leadingIcon: Icons.place_outlined,
    placeholder: 'Location',
    valueLabel: cities.isEmpty ? null : cities.first,
    additionalSelectionCount: cities.length > 1 ? cities.length - 1 : 0,
    onTap: () => showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
  // CheckboxListTile rows; on Apply: setState(() => cities.assign…);
  return const SizedBox.shrink();
      },
    ),
  );
  
  // --- 3) Disabled chip ----------------------------------------------------------
  NorthstarFilterDropdown(
    leadingIcon: Icons.lock_outline,
    placeholder: 'Unavailable',
    enabled: false,
    onTap: null,
  );
  
  // --- 4) All filters button (overflow / summary) -------------------------------
  NorthstarAllFiltersButton(
    label: 'All filters',
    activeFilterCount:
  (selectedRole != null ? 1 : 0) + (cities.isNotEmpty ? 1 : 0),
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => const SizedBox.shrink(),
    ),
  );
  
  // --- 5) Toolbar row (8px gap, 16px padding) ------------------------------------
  NorthstarFilterGroup(
    padding: const EdgeInsets.all(NorthstarSpacing.space16),
    children: [
      NorthstarSearchField(hintText: 'Search…'),
      /* …up to ~3 NorthstarFilterDropdown… */
      NorthstarAllFiltersButton(activeFilterCount: 3, onPressed: () {}),
    ],
  );
  ''',
    preview: (BuildContext context) =>
        const _NorthstarFilterDropdownCatalogDemo(),
  );
}

class _NorthstarFilterDropdownCatalogDemo extends StatefulWidget {
  const _NorthstarFilterDropdownCatalogDemo();

  @override
  State<_NorthstarFilterDropdownCatalogDemo> createState() =>
      _NorthstarFilterDropdownCatalogDemoState();
}

class _NorthstarFilterDropdownCatalogDemoState
    extends State<_NorthstarFilterDropdownCatalogDemo> {
  final GlobalKey _userKey = GlobalKey();
  final GlobalKey _roleKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();

  static const List<String> _userChoices = <String>[
    'Any',
    'Alice Chen',
    'Bob Smith',
    'Carol Diaz',
  ];

  static const List<String> _roleChoices = <String>[
    'Data Engineer',
    'Product Designer',
    'Engineering Manager',
    'People Partner',
  ];

  static const List<String> _cityChoices = <String>[
    'Sydney',
    'Melbourne',
    'Brisbane',
    'Perth',
    'Adelaide',
  ];

  /// `null` or `'Any'` → empty filter (placeholder).
  String? _user;
  String? _role;
  final Set<String> _locations = <String>{};

  int get _activeFilterCount {
    int n = 0;
    if (_user != null && _user != 'Any') {
      n++;
    }
    if (_role != null) {
      n++;
    }
    if (_locations.isNotEmpty) {
      n++;
    }
    return n;
  }

  Future<void> _showStringMenu({
    required GlobalKey anchorKey,
    required List<String> choices,
    required ValueChanged<String> onPick,
  }) async {
    final String? picked = await showNorthstarFilterMenu<String>(
      context: context,
      anchorKey: anchorKey,
      items: <PopupMenuEntry<String>>[
        for (final String c in choices)
          PopupMenuItem<String>(value: c, child: Text(c)),
      ],
    );
    if (picked != null && mounted) {
      onPick(picked);
    }
  }

  Future<void> _openLocationSheet() async {
    final Set<String> draft = Set<String>.from(_locations);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext ctx, void Function(void Function()) setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(NorthstarSpacing.space16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Locations (multi-select)',
                      style: Theme.of(ctx).textTheme.titleSmall,
                    ),
                    const SizedBox(height: NorthstarSpacing.space12),
                    for (final String city in _cityChoices)
                      CheckboxListTile(
                        value: draft.contains(city),
                        onChanged: (bool? v) {
                          setModal(() {
                            if (v ?? false) {
                              draft.add(city);
                            } else {
                              draft.remove(city);
                            }
                          });
                        },
                        title: Text(city),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    const SizedBox(height: NorthstarSpacing.space8),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        setState(() {
                          _locations
                            ..clear()
                            ..addAll(draft);
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openAllFiltersSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(NorthstarSpacing.space16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Active filters',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: NorthstarSpacing.space12),
                Text(
                  _user == null || _user == 'Any' ? 'User: —' : 'User: $_user',
                ),
                Text(_role == null ? 'Role: —' : 'Role: $_role'),
                Text(
                  _locations.isEmpty
                      ? 'Locations: —'
                      : 'Locations: ${_locations.join(', ')}',
                ),
                const SizedBox(height: NorthstarSpacing.space16),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    setState(() {
                      _user = null;
                      _role = null;
                      _locations.clear();
                    });
                  },
                  child: const Text('Clear all'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? userLabel = (_user != null && _user != 'Any') ? _user : null;
    final String? roleLabel = _role;

    final List<String> locList = _locations.toList();
    locList.sort();
    final String? locationPrimary = locList.isEmpty ? null : locList.first;
    final int locationExtra = locList.length > 1 ? locList.length - 1 : 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: NorthstarFilterGroup(
        padding: const EdgeInsets.all(NorthstarSpacing.space16),
        children: <Widget>[
          NorthstarFilterDropdown(
            key: _userKey,
            leadingIcon: Icons.person_outline,
            placeholder: 'User',
            valueLabel: userLabel,
            onTap: () => _showStringMenu(
              anchorKey: _userKey,
              choices: _userChoices,
              onPick: (String v) => setState(() => _user = v),
            ),
            automationId: 'cat_filter_user',
          ),
          NorthstarFilterDropdown(
            key: _roleKey,
            leadingIcon: Icons.badge_outlined,
            placeholder: 'Role',
            valueLabel: roleLabel,
            onTap: () => _showStringMenu(
              anchorKey: _roleKey,
              choices: _roleChoices,
              onPick: (String v) => setState(() => _role = v),
            ),
            automationId: 'cat_filter_role',
          ),
          NorthstarFilterDropdown(
            key: _locationKey,
            leadingIcon: Icons.place_outlined,
            placeholder: 'Location',
            valueLabel: locationPrimary,
            additionalSelectionCount: locationExtra,
            onTap: _openLocationSheet,
            automationId: 'cat_filter_loc',
          ),
          NorthstarAllFiltersButton(
            activeFilterCount: _activeFilterCount,
            onPressed: _openAllFiltersSheet,
            automationId: 'cat_all_filters',
          ),
        ],
      ),
    );
  }
}

/// Live chip catalog: [onSelected] demo + [NorthstarChipInteractionPreview] rows.
