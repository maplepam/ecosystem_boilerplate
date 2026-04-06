import '../actions/northstar_button.dart';
import '../display/northstar_avatar.dart';
import '../display/northstar_badge.dart';
import '../display/northstar_chip.dart';
import '../display/northstar_divider.dart';
import '../display/northstar_filter_chip_strip.dart';
import '../display/northstar_linear_progress.dart';
import '../display/northstar_accordion.dart';
import '../display/northstar_banner.dart';
import '../display/northstar_breadcrumb.dart';
import '../display/northstar_search_field.dart';
import '../display/northstar_tri_state.dart';
import '../display/northstar_stacked_avatars.dart';
import '../display/northstar_text_link.dart';
import '../dashboard/dashboard_layout_preset.dart';
import '../dashboard/reorderable_dashboard_slots.dart';
import '../navigation/northstar_drawer_entry.dart';
import '../navigation/northstar_navigation_drawer.dart';
import '../navigation/northstar_scaffold_with_drawer.dart';
import 'northstar_icon_catalog_panel.dart';
import 'northstar_typography_catalog_panel.dart';
import 'northstar_widget_library_detail_page.dart';
import 'northstar_widget_library_list_page.dart';
import 'widget_catalog_entry.dart';
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Developer catalog: every **built-in** `emp_ai_ds_widgets` entry + optional
/// host-registered widgets.
class NorthstarWidgetLibraryPage extends StatelessWidget {
  const NorthstarWidgetLibraryPage({
    super.key,
    this.extraEntries = const <WidgetCatalogEntry>[],
  });

  final List<WidgetCatalogEntry> extraEntries;

  static List<WidgetCatalogEntry> builtInEntries() {
    return <WidgetCatalogEntry>[
      WidgetCatalogEntry(
        id: 'northstar_button',
        title: 'NorthstarButton',
        description:
            'Single configurable action control: primary / secondary / tertiary / '
            'icon-only; tones standard / positive / negative; optional '
            'backgroundColor / foregroundColor; leading/trailing icons; padding, '
            'margin, width, loading. Matches Northstar Figma matrices.',
        code: '''
NorthstarButton(
  variant: NorthstarButtonVariant.primary,
  tone: NorthstarButtonTone.positive,
  label: 'Confirm',
  trailingIcon: Icons.check,
  automationId: 'confirm_cta',
  onPressed: () {},
)

NorthstarButton(
  variant: NorthstarButtonVariant.primary,
  label: 'Saving…',
  isLoading: true,
  loadingStyle: NorthstarButtonLoadingStyle.labelWithSpinner,
  automationId: 'save_action',
  onPressed: () {},
)

NorthstarButton(
  variant: NorthstarButtonVariant.primary,
  tone: NorthstarButtonTone.negative,
  label: 'Delete',
  onPressed: () {},
)

NorthstarButton(
  variant: NorthstarButtonVariant.secondary,
  tone: NorthstarButtonTone.standard,
  label: 'Secondary',
  leadingIcon: Icons.download_outlined,
  width: 200,
  onPressed: () {},
)

NorthstarButton(
  variant: NorthstarButtonVariant.primary,
  label: 'Custom',
  backgroundColor: NorthstarColorTokens.of(context).secondary,
  foregroundColor: NorthstarColorTokens.of(context).onSecondary,
  onPressed: () {},
)
''',
        preview: _northstarButtonCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_avatar',
        title: 'NorthstarAvatar',
        description:
            'Configurable avatar: user (circle) vs entity (rounded square); '
            'image → initials → icon; optional border and status badge; optional '
            'label row with hover / press surface and tooltip.',
        code: '''
NorthstarAvatar(
  persona: NorthstarAvatarPersona.user,
  size: 40,
  initials: 'AL',
  showBorder: true,
  statusBadgeColor: NorthstarColorTokens.of(context).success,
  automationId: 'header_user',
)

NorthstarAvatar(
  persona: NorthstarAvatarPersona.entity,
  size: 40,
  showBorder: true,
  initials: 'A',
  automationId: 'org',
)

NorthstarAvatar(
  title: 'Aaron Leyte',
  subtitle: 'Engineering',
  showExpandChevron: true,
  tooltip: 'Open profile',
  initials: 'AL',
  automationId: 'nav_user',
  onTap: () {},
)
''',
        preview: _northstarAvatarCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_stacked_avatars',
        title: 'NorthstarStackedAvatars',
        description:
            'Overlapping avatars (−20 px gap). Behaviors: show up to five; '
            'four + remainder chip (total−4, e.g. 80→76; 103→99; >103→99+); '
            'four + ellipsis.',
        code: '''
NorthstarStackedAvatars(
  behavior: NorthstarStackedAvatarsBehavior.showAllMaxFive,
  automationId: 'team',
  avatars: [
    NorthstarAvatar(showBorder: true, initials: 'A', automationId: 'team_m1'),
    NorthstarAvatar(showBorder: true, initials: 'B', automationId: 'team_m2'),
  ],
)

NorthstarStackedAvatars(
  behavior: NorthstarStackedAvatarsBehavior.overflowNumeric,
  totalMemberCount: 48,
  avatars: [ /* four NorthstarAvatar */ ],
)
// total 48 → chip shows 44 (48 − 4). total 103 → 99. total 104+ → 99+.

NorthstarStackedAvatars(
  behavior: NorthstarStackedAvatarsBehavior.overflowIndeterminate,
  avatars: [ /* four+ */ ],
)
''',
        preview: _northstarStackedAvatarsCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_chip',
        title: 'NorthstarChip',
        description:
            'One widget for Assist (outlined action), Filter (select + check), '
            'Input (32px, close, active state), and Status (semantic + soft). '
            '[onSelected] matches [FilterChip] for filter toggles. '
            '[interactionPreview] for catalog screenshots. Optional colors, '
            '[onTap], [disabled], [isDragged], leading icon or image, trailing '
            'icon; [DsAutomationKeys] for tests.',
        code: '''
NorthstarChip(
  useCase: NorthstarChipUseCase.assist,
  label: 'Add to calendar',
  leadingIcon: Icons.event_outlined,
  onTap: () {},
  automationId: 'assist_cal',
)

// bool remoteSelected = …; in State
NorthstarChip(
  useCase: NorthstarChipUseCase.filter,
  label: 'Remote',
  selected: remoteSelected,
  onSelected: (bool next) => setState(() => remoteSelected = next),
  automationId: 'filter_remote',
)

NorthstarChip(
  useCase: NorthstarChipUseCase.input,
  label: 'maria@acme.com',
  selected: true,
  onClose: () {},
  automationId: 'chip_email',
)

NorthstarChip(
  useCase: NorthstarChipUseCase.status,
  label: 'in progress',
  statusSemantic: NorthstarChipStatusSemantic.pending,
  trailingIcon: Icons.expand_more,
)
''',
        preview: (BuildContext context) => const _NorthstarChipCatalogDemo(),
      ),
      WidgetCatalogEntry(
        id: 'northstar_divider',
        title: 'NorthstarDivider',
        description:
            'Horizontal or vertical hairline with **fullWidth**, **inset** '
            '(start / top), or **middleInset**. Optional [color], [thickness], '
            '[inset] amount, [margin], [padding], [automationId].',
        code: '''
NorthstarDivider(
  style: NorthstarDividerStyle.fullWidth,
  automationId: 'row_sep',
)

NorthstarDivider(
  style: NorthstarDividerStyle.inset,
  inset: 16,
)

NorthstarDivider(
  style: NorthstarDividerStyle.middleInset,
  margin: EdgeInsets.symmetric(vertical: 8),
)

NorthstarDivider(
  orientation: NorthstarDividerOrientation.vertical,
  style: NorthstarDividerStyle.middleInset,
  padding: EdgeInsets.only(left: 4),
)
''',
        preview: _northstarDividerCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_badge',
        title: 'NorthstarBadge',
        description:
            'Single widget for Figma **Badge** variants: **status** dot, **icon** '
            'circle (glyph on semantic fill), **digits** (1–2, circular), **label** '
            'pill (10px type, 3+ chars). Semantics: positive / negative / warning / '
            'info / neutral ([NorthstarColorTokens]). Optional contrasting **border** '
            'when overlapping surfaces. [NorthstarBadged] supports **inset** vs '
            '**centered-on-corner** top-end placement.',
        code: '''
NorthstarBadge.status(
  semantic: NorthstarBadgeSemantic.positive,
  showBorder: true,
  automationId: 'live_dot',
)

NorthstarBadge.icon(
  semantic: NorthstarBadgeSemantic.negative,
  icon: Icons.priority_high,
  automationId: 'alert_icon',
)

NorthstarBadge.digits(
  semantic: NorthstarBadgeSemantic.info,
  value: '12',
  showBorder: true,
  automationId: 'notif_count',
)

NorthstarBadge.label(
  semantic: NorthstarBadgeSemantic.warning,
  text: 'NEW',
  automationId: 'pill_new',
)

NorthstarBadged(
  placement: NorthstarBadgePlacement.centeredOnCornerTopEnd,
  badge: NorthstarBadge.digits(
    semantic: NorthstarBadgeSemantic.negative,
    value: '3',
    showBorder: true,
  ),
  child: Icon(Icons.notifications_outlined, size: 28),
)
''',
        preview: _northstarBadgeCatalogPreview,
      ),
      WidgetCatalogEntry(
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
        preview: (BuildContext context) =>
            const _NorthstarTextLinkCatalogDemo(),
      ),
      WidgetCatalogEntry(
        id: 'northstar_breadcrumb',
        title: 'NorthstarBreadcrumb',
        description:
            'Hierarchical **breadcrumb** trail with `/` separators: [primary] links '
            '(hover underline, press darkens), bold **current** page, optional '
            '**overflow** (`…` menu) when more than three links precede the current '
            'page, and **24**-char truncation with tooltip. **Small** (~14) and '
            '**Large** (~16) sizes. Uses [NorthstarColorTokens] only — no raw hex.',
        code: '''
NorthstarBreadcrumb(
  size: NorthstarBreadcrumbSize.small,
  automationId: 'page_trail',
  items: <NorthstarBreadcrumbItem>[
    NorthstarBreadcrumbItem(label: 'Home', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'Components', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'Breadcrumb'),
  ],
)

NorthstarBreadcrumb(
  size: NorthstarBreadcrumbSize.large,
  items: <NorthstarBreadcrumbItem>[
    NorthstarBreadcrumbItem(label: 'Home', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'A', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'B', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'C', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'D', onTap: () {}),
    NorthstarBreadcrumbItem(label: 'Current'),
  ],
)
''',
        preview: _northstarBreadcrumbCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_linear_progress',
        title: 'NorthstarLinearProgress',
        description:
            'Thin horizontal bar (**square** caps): determinate [value] **0–1**, '
            'or indeterminate when [value] is null. Default height **3**; optional '
            '[trackColor] / [color]; [automationId]. Fits app bar bottom edge.',
        code: '''
NorthstarLinearProgress(value: 0.75, automationId: 'save_job')

NorthstarLinearProgress(value: null) // indeterminate

NorthstarLinearProgress(
  value: 0.4,
  height: 4,
  trackColor: NorthstarColorTokens.of(context).surfaceContainerHigh,
  color: NorthstarColorTokens.of(context).primary,
)
''',
        preview: _northstarLinearProgressCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_icon_library',
        title: 'Northstar icons (SVG)',
        description: '**344** Northstar V3 SVGs ship in `emp_ai_ds_northstar` '
            '(`assets/northstar_icons/`). Groups mirror the Figma icon sheet; '
            'search by id, asset path, or section title. Tap an icon for '
            'copy-ready [NorthstarSvgIcon] samples. After replacing assets, run '
            '`dart run tool/generate_northstar_icon_manifest.dart` in that package.',
        code: '''
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';

NorthstarSvgIcon(
  item: NorthstarIconRegistry.tryById('user-time')!,
  size: 24,
)

NorthstarSvgIcon.fromPath(
  relativeAssetPath: 'assets/northstar_icons/Icon=user-time.svg',
  size: 24,
)
''',
        preview: _northstarIconLibraryCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_typography_roles',
        title: 'Northstar typography (text roles)',
        description:
            'Figma V3 text roles from `emp_ai_ds_northstar` ([NorthstarTextRole]): '
            'each maps to a slot on [ThemeData.textTheme] after '
            '[NorthstarTheme.buildThemeData]. Search by role name, Figma label, '
            'or font family; tap a row for a live preview and copy-ready '
            '`NorthstarTextRole.*.style(context)` snippet.',
        code: '''
import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';

Text(
  'Page heading',
  style: NorthstarTextRole.pageTitle.style(context),
)

Text(
  'Supporting copy',
  style: NorthstarTextRole.body.style(context),
)
''',
        preview: _northstarTypographyCatalogPreview,
      ),
      WidgetCatalogEntry(
        id: 'northstar_scaffold_with_drawer',
        title: 'NorthstarScaffoldWithDrawer',
        description:
            'Shell scaffold with [AppBar], openable drawer, and optional FAB. '
            'Same entry model as [NorthstarNavigationDrawer].',
        code: '''
NorthstarScaffoldWithDrawer(
  appBarTitle: const Text('Workspace'),
  drawerHeader: DrawerHeader(child: Text('Brand')),
  entries: [
    NorthstarDrawerRouteEntry(
      location: '/main/home',
      label: 'Home',
      icon: Icons.home_outlined,
    ),
  ],
  body: const Center(child: Text('Page')),
)
''',
        preview: (BuildContext context) {
          return Align(
            alignment: Alignment.topCenter,
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              elevation: 1,
              child: SizedBox(
                width: 360,
                height: 420,
                child: NorthstarScaffoldWithDrawer(
                  appBarTitle: const Text('Workspace'),
                  drawerHeader: DrawerHeader(
                    margin: EdgeInsets.zero,
                    child: Text(
                      'Brand',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  closeDrawerOnNavigate: false,
                  onDrawerNavigate: (_, __) {},
                  entries: const <NorthstarDrawerEntry>[
                    NorthstarDrawerRouteEntry(
                      location: '/x',
                      label: 'Home',
                      icon: Icons.home_outlined,
                    ),
                    NorthstarDrawerRouteEntry(
                      location: '/x/settings',
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                    ),
                  ],
                  body: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(NorthstarSpacing.space16),
                      child: Text(
                        'Open the menu (☰) in the app bar to try the drawer.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      WidgetCatalogEntry(
        id: 'dashboard_layout_builder',
        title: 'DashboardLayoutBuilder',
        description:
            'Responsive presets for dashboard-style pages (1 / 2 / 3 columns). '
            'Pair with host state for tile visibility and order.',
        code: '''
DashboardLayoutBuilder(
  preset: DashboardLayoutPreset.twoColumnAdaptive,
  children: [
    Card(child: SizedBox(height: 120, child: Center(child: Text('A')))),
    Card(child: SizedBox(height: 120, child: Center(child: Text('B')))),
  ],
)
''',
        preview: (BuildContext context) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final double h = (c.maxWidth * 0.42).clamp(260.0, 520.0);
              return SizedBox(
                height: h,
                width: double.infinity,
                child: DashboardLayoutBuilder(
                  preset: DashboardLayoutPreset.twoColumnAdaptive,
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(NorthstarSpacing.space16),
                        child: Center(
                          child: Text(
                            'Tile A',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(NorthstarSpacing.space16),
                        child: Center(
                          child: Text(
                            'Tile B',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      WidgetCatalogEntry(
        id: 'reorderable_dashboard_slot_list',
        title: 'ReorderableDashboardSlotList',
        description:
            'Edit mode: drag-reorder slots and toggle visibility. Persist '
            '`order` and `hidden` in the host (e.g. Riverpod + SharedPreferences).',
        code: '''
ReorderableDashboardSlotList(
  definitions: [
    DashboardSlotDefinition(
      id: 'kpi',
      title: 'KPIs',
      subtitle: 'Headline metrics',
    ),
  ],
  order: ['kpi'],
  hidden: {},
  onReorder: (next) { /* save */ },
  onToggleVisible: (id, visible) { /* save */ },
)
''',
        preview: (BuildContext context) {
          return const _ReorderableDashboardCatalogDemo();
        },
      ),
      WidgetCatalogEntry(
        id: 'northstar_navigation_drawer',
        title: 'NorthstarNavigationDrawer',
        description:
            'Slide-out drawer: flat routes, nested [ExpansionTile] groups, '
            'or arbitrary custom rows (version footer, toggles). Compose '
            'entries in the host app — this package stays presentation-only.',
        code: '''
Scaffold(
  drawer: NorthstarNavigationDrawer(
    header: DrawerHeader(
      child: Text('My app'),
    ),
    entries: [
      NorthstarDrawerRouteEntry(
        location: '/main/home',
        label: 'Home',
        icon: Icons.home_outlined,
      ),
      NorthstarDrawerExpansionEntry(
        label: 'Modules',
        icon: Icons.apps_outlined,
        children: [
          NorthstarDrawerRouteEntry(
            location: '/samples/demo',
            label: 'Samples',
            icon: Icons.science_outlined,
          ),
        ],
      ),
      NorthstarDrawerCustomEntry(
        builder: (context) => const ListTile(
          title: Text('v0.1.0'),
          dense: true,
        ),
      ),
    ],
  ),
  body: ...,
)
''',
        preview: (BuildContext context) {
          return Align(
            alignment: Alignment.topCenter,
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              elevation: 1,
              child: SizedBox(
                width: 360,
                height: 420,
                child: Scaffold(
                  appBar: AppBar(title: const Text('Preview')),
                  drawer: NorthstarNavigationDrawer(
                    header: DrawerHeader(
                      margin: EdgeInsets.zero,
                      child: Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    closeOnNavigate: false,
                    onNavigate: (_, __) {},
                    entries: const <NorthstarDrawerEntry>[
                      NorthstarDrawerRouteEntry(
                        location: '/a',
                        label: 'Route row',
                        icon: Icons.navigation_outlined,
                      ),
                      NorthstarDrawerExpansionEntry(
                        label: 'Expandable',
                        icon: Icons.folder_outlined,
                        initiallyExpanded: true,
                        children: <NorthstarDrawerEntry>[
                          NorthstarDrawerRouteEntry(
                            location: '/b',
                            label: 'Child route',
                          ),
                        ],
                      ),
                      NorthstarDrawerCustomEntry(
                        builder: _versionTile,
                      ),
                    ],
                  ),
                  body: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(NorthstarSpacing.space16),
                      child: Text(
                        'Open the menu (☰) to try routes and expansion.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      WidgetCatalogEntry(
        id: 'northstar_drawer_entry_model',
        title: 'NorthstarDrawerEntry (data)',
        description:
            'Sealed hierarchy for drawer rows — keep navigation shape in the '
            'host as plain data: [NorthstarDrawerRouteEntry] (goRouter path), '
            '[NorthstarDrawerExpansionEntry] (nested routes or more groups), '
            '[NorthstarDrawerCustomEntry] (version, toggles, non-route UI). '
            'Defined in northstar_drawer_entry.dart.',
        code: '''
// Route row → ListTile + context.go(location)
const NorthstarDrawerRouteEntry(
  location: '/settings',
  label: 'Settings',
  icon: Icons.settings_outlined,
);

// Expandable section
const NorthstarDrawerExpansionEntry(
  label: 'Admin',
  icon: Icons.admin_panel_settings_outlined,
  children: [
    NorthstarDrawerRouteEntry(
      location: '/admin/users',
      label: 'Users',
    ),
  ],
);

// Custom (no navigation)
NorthstarDrawerCustomEntry(
  builder: (context) => ListTile(
    dense: true,
    title: Text('v1.2.3', style: Theme.of(context).textTheme.labelSmall),
  ),
);
''',
        preview: (BuildContext context) {
          return Align(
            alignment: Alignment.topCenter,
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              elevation: 1,
              child: SizedBox(
                width: 360,
                height: 420,
                child: Scaffold(
                  appBar: AppBar(title: const Text('Entry shapes')),
                  drawer: NorthstarNavigationDrawer(
                    header: DrawerHeader(
                      margin: EdgeInsets.zero,
                      child: Text(
                        'Route · expansion · custom',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    closeOnNavigate: false,
                    onNavigate: (_, __) {},
                    entries: <NorthstarDrawerEntry>[
                      const NorthstarDrawerRouteEntry(
                        location: '/settings',
                        label: 'NorthstarDrawerRouteEntry',
                        icon: Icons.link,
                      ),
                      const NorthstarDrawerExpansionEntry(
                        label: 'NorthstarDrawerExpansionEntry',
                        icon: Icons.folder_outlined,
                        initiallyExpanded: true,
                        children: <NorthstarDrawerEntry>[
                          NorthstarDrawerRouteEntry(
                            location: '/nested',
                            label: 'Child route',
                          ),
                        ],
                      ),
                      NorthstarDrawerCustomEntry(builder: _versionTile),
                    ],
                  ),
                  body: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(NorthstarSpacing.space16),
                      child: Text(
                        'Open ☰ — same data types as in your host code.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      WidgetCatalogEntry(
        id: 'northstar_search_field',
        title: 'NorthstarSearchField',
        description:
            'Outlined search field with leading icon for list filters and '
            'catalog-style UIs. Optional [automationId] maps to a [ValueKey].',
        code: '''
NorthstarSearchField(
  hintText: 'Search…',
  automationId: 'orders_search',
  onChanged: (v) {},
)
''',
        preview: (BuildContext context) => const Padding(
          padding: EdgeInsets.all(NorthstarSpacing.space16),
          child: NorthstarSearchField(
            hintText: 'Search components…',
          ),
        ),
      ),
      WidgetCatalogEntry(
        id: 'northstar_spacing_scale_table',
        title: 'NorthstarSpacing / NorthstarSpacingScaleTable',
        description:
            'Figma V3 spacing scale (space-2 … space-96) as [NorthstarSpacing] '
            'constants plus [NorthstarSpacingToken] metadata. '
            '[NorthstarSpacingScaleTable] is a reusable token/rem/px/swatch reference.',
        code: '''
const EdgeInsets pad = EdgeInsets.all(NorthstarSpacing.space16);

NorthstarSpacing.scale // List<NorthstarSpacingToken>

const NorthstarSpacingScaleTable()
''',
        preview: (BuildContext context) => const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: NorthstarSpacingScaleTable(
            padding: EdgeInsets.all(NorthstarSpacing.space24),
          ),
        ),
      ),
      WidgetCatalogEntry(
        id: 'northstar_accordion',
        title: 'NorthstarAccordion',
        description:
            'Collapsible section: full header hit target, animated chevron '
            '(down/up), optional [onExpansionChanged]. [NorthstarAccordionStyle.panel] '
            'for card-like rows (leave ≥8 logical px between items); '
            '[NorthstarAccordionStyle.divider] for FAQ-style stacks — insert '
            '[NorthstarDivider] between items so lines do not double. '
            'Default collapsed; [enabled] false for disabled.',
        code: '''
NorthstarAccordion(
  style: NorthstarAccordionStyle.panel,
  title: 'Section title',
  automationId: 'faq_1',
  child: Text('Body…'),
)

NorthstarAccordion(
  style: NorthstarAccordionStyle.divider,
  title: 'Next row',
  child: Text('…'),
)
''',
        preview: _northstarAccordionCatalogPreview,
      ),
      WidgetCatalogEntry(
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
      ),
      WidgetCatalogEntry(
        id: 'northstar_filter_chip_strip',
        title: 'NorthstarFilterChipStrip',
        description:
            'Horizontal scroll of Material [FilterChip]s. Use [value] null for '
            'an “All” option; [selectedValue] compares to each item value.',
        code: '''
NorthstarFilterChipStrip(
  items: const [
    NorthstarFilterChipStripItem(value: null, label: 'All'),
    NorthstarFilterChipStripItem(value: 'a', label: 'A'),
  ],
  selectedValue: null,
  onSelected: (v) {},
)
''',
        preview: (BuildContext context) => Padding(
          padding: const EdgeInsets.all(NorthstarSpacing.space16),
          child: NorthstarFilterChipStrip(
            items: const <NorthstarFilterChipStripItem>[
              NorthstarFilterChipStripItem(value: null, label: 'All'),
              NorthstarFilterChipStripItem(value: 'hr', label: 'HR'),
              NorthstarFilterChipStripItem(value: 'it', label: 'IT'),
            ],
            selectedValue: 'hr',
            onSelected: (_) {},
          ),
        ),
      ),
      WidgetCatalogEntry(
        id: 'northstar_tri_state_body',
        title: 'NorthstarTriState / NorthstarTriStateBody',
        description:
            'Riverpod-free loading / error / data model for enterprise screens. '
            'Map from [AsyncValue] in the host with a one-line extension.',
        code: '''
final NorthstarTriState<User> state = asyncValue.asNorthstarTriState;

NorthstarTriStateBody<User>(
  state: state,
  dataBuilder: (context, user) => Text(user.name),
)
''',
        preview: (BuildContext context) => Padding(
          padding: const EdgeInsets.all(NorthstarSpacing.space16),
          child: NorthstarTriStateBody<String>(
            state: const NorthstarTriData<String>('Network OK'),
            dataBuilder: (_, String s) => Text(s),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<WidgetCatalogEntry> all = <WidgetCatalogEntry>[
      ...NorthstarWidgetLibraryPage.builtInEntries(),
      ...extraEntries,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Widget library'),
      ),
      body: NorthstarWidgetLibraryListPage(
        entries: all,
        subtitle:
            'Pick a component to open its live preview. Ideal for demos and '
            'design reviews.',
        onOpenEntry: (WidgetCatalogEntry e) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext c) => NorthstarWidgetLibraryDetailPage(
                entry: e,
                onBack: () => Navigator.of(c).pop(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Local state so drag-reorder and visibility toggles actually update in Try it.
class _ReorderableDashboardCatalogDemo extends StatefulWidget {
  const _ReorderableDashboardCatalogDemo();

  @override
  State<_ReorderableDashboardCatalogDemo> createState() =>
      _ReorderableDashboardCatalogDemoState();
}

class _ReorderableDashboardCatalogDemoState
    extends State<_ReorderableDashboardCatalogDemo> {
  List<String> _order = <String>['a', 'b'];
  final Set<String> _hidden = <String>{};

  @override
  Widget build(BuildContext context) {
    return ReorderableDashboardSlotList(
      definitions: const <DashboardSlotDefinition>[
        DashboardSlotDefinition(
          id: 'a',
          title: 'Widget A',
          subtitle: 'Drag handle to reorder',
        ),
        DashboardSlotDefinition(
          id: 'b',
          title: 'Widget B',
          subtitle: 'Toggle visibility',
        ),
      ],
      order: _order,
      hidden: _hidden,
      onReorder: (List<String> next) => setState(() => _order = next),
      onToggleVisible: (String id, bool visible) => setState(() {
        if (visible) {
          _hidden.remove(id);
        } else {
          _hidden.add(id);
        }
      }),
    );
  }
}

Widget _versionTile(BuildContext context) {
  return ListTile(
    dense: true,
    title: Text(
      'Custom row (not a route)',
      style: Theme.of(context).textTheme.bodySmall,
    ),
    subtitle: const Text('e.g. build number'),
  );
}

Widget _northstarAvatarCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!;
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Glyphs', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            Row(
              children: <Widget>[
                NorthstarAvatar(
                  persona: NorthstarAvatarPersona.user,
                  initials: 'AL',
                  automationId: 'cat_glyph_user',
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                NorthstarAvatar(
                  persona: NorthstarAvatarPersona.entity,
                  initials: 'A',
                  automationId: 'cat_glyph_entity',
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                NorthstarAvatar(
                  showBorder: true,
                  initials: 'B',
                  automationId: 'cat_glyph_border',
                ),
                const SizedBox(width: NorthstarSpacing.space12),
                NorthstarAvatar(
                  initials: 'S',
                  statusBadgeColor: NorthstarColorTokens.of(context).success,
                  automationId: 'cat_glyph_badge',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(width: NorthstarSpacing.space24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Avatar + labels', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarAvatar(
              title: 'Preview User',
              subtitle: 'Role · Team',
              showExpandChevron: true,
              tooltip: 'Account menu',
              initials: 'PU',
              automationId: 'cat_nav_row',
              onTap: () {},
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _northstarBreadcrumbCatalogPreview(BuildContext context) {
  final TextStyle caption =
      Theme.of(context).textTheme.labelSmall!.copyWith(
            fontWeight: FontWeight.w600,
          );

  return Material(
    color: NorthstarColorTokens.of(context).surface,
    child: Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space12),
      child: SizedBox(
        width: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Small · short trail', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              size: NorthstarBreadcrumbSize.small,
              automationId: 'cat_crumb_small',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label: 'Components',
                  onTap: () {},
                ),
                const NorthstarBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            Text('Large · same trail', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              size: NorthstarBreadcrumbSize.large,
              automationId: 'cat_crumb_large',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label: 'Components',
                  onTap: () {},
                ),
                const NorthstarBreadcrumbItem(label: 'Breadcrumb'),
              ],
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            Text('Overflow · tap … for hidden levels', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              size: NorthstarBreadcrumbSize.small,
              automationId: 'cat_crumb_overflow',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label: 'Hidden A',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label: 'Hidden B',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label: 'Visible Y',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label: 'Visible Z',
                  onTap: () {},
                ),
                const NorthstarBreadcrumbItem(label: 'Current page'),
              ],
            ),
            const SizedBox(height: NorthstarSpacing.space24),
            Text('Truncation · hover for full label', style: caption),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarBreadcrumb(
              maxLabelLength: 24,
              automationId: 'cat_crumb_trunc',
              items: <NorthstarBreadcrumbItem>[
                NorthstarBreadcrumbItem(
                  label: 'Home',
                  onTap: () {},
                ),
                NorthstarBreadcrumbItem(
                  label:
                      'Extraordinarily long workspace name that exceeds limit',
                  onTap: () {},
                ),
                const NorthstarBreadcrumbItem(label: 'Details'),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _northstarLinearProgressCatalogPreview(BuildContext context) {
  Widget row(String label, double? v, String automationSuffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 6),
        NorthstarLinearProgress(
          value: v,
          automationId: 'cat_prog_$automationSuffix',
        ),
      ],
    );
  }

  return SizedBox(
    width: 320,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        row('25%', 0.25, 'p25'),
        const SizedBox(height: 14),
        row('50%', 0.5, 'p50'),
        const SizedBox(height: 14),
        row('75%', 0.75, 'p75'),
        const SizedBox(height: 14),
        row('100%', 1, 'p100'),
        const SizedBox(height: 18),
        row('Indeterminate', null, 'ind'),
      ],
    ),
  );
}

Widget _northstarIconLibraryCatalogPreview(BuildContext context) {
  return const SizedBox(
    height: 520,
    child: NorthstarIconCatalogPanel(),
  );
}

Widget _northstarTypographyCatalogPreview(BuildContext context) {
  return const SizedBox(
    height: 520,
    child: NorthstarTypographyCatalogPanel(),
  );
}

Widget _northstarBadgeCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!;

  IconData iconForSemantic(NorthstarBadgeSemantic s) {
    return switch (s) {
      NorthstarBadgeSemantic.positive => Icons.check,
      NorthstarBadgeSemantic.negative => Icons.priority_high,
      NorthstarBadgeSemantic.warning => Icons.warning_amber_rounded,
      NorthstarBadgeSemantic.info => Icons.info_outline,
      NorthstarBadgeSemantic.neutral => Icons.horizontal_rule,
    };
  }

  Widget semanticRow(
    String title,
    Widget Function(NorthstarBadgeSemantic semantic, int index) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: caption),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          children: <Widget>[
            for (int i = 0; i < NorthstarBadgeSemantic.values.length; i++)
              itemBuilder(NorthstarBadgeSemantic.values[i], i),
          ],
        ),
      ],
    );
  }

  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        semanticRow(
          'Status (dot)',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.status(
            semantic: s,
            automationId: 'cat_badge_st_$i',
          ),
        ),
        const SizedBox(height: 18),
        semanticRow(
          'Icon',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.icon(
            semantic: s,
            icon: iconForSemantic(s),
            automationId: 'cat_badge_ic_$i',
          ),
        ),
        const SizedBox(height: 18),
        semanticRow(
          'Digits (1–2)',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.digits(
            semantic: s,
            value: i == 1 ? '12' : '3',
            automationId: 'cat_badge_dg_$i',
          ),
        ),
        const SizedBox(height: 18),
        semanticRow(
          'Label / multi-character (pill)',
          (NorthstarBadgeSemantic s, int i) => NorthstarBadge.label(
            semantic: s,
            text: 'NEW',
            automationId: 'cat_badge_lb_$i',
          ),
        ),
        const SizedBox(height: 22),
        Text('With border (overlap contrast)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.status(
                semantic: NorthstarBadgeSemantic.positive,
                showBorder: true,
                automationId: 'cat_badge_bd_st',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.icon(
                semantic: NorthstarBadgeSemantic.info,
                icon: Icons.info_outline,
                showBorder: true,
                automationId: 'cat_badge_bd_ic',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.digits(
                semantic: NorthstarBadgeSemantic.negative,
                value: '8',
                showBorder: true,
                automationId: 'cat_badge_bd_dg',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: NorthstarBadge.label(
                semantic: NorthstarBadgeSemantic.warning,
                text: 'BETA',
                showBorder: true,
                automationId: 'cat_badge_bd_lb',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('Corner placement · inside (inset top-end)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarBadged(
          placement: NorthstarBadgePlacement.insetTopEnd,
          inset: const EdgeInsetsDirectional.only(top: 8, end: 8),
          badge: NorthstarBadge.status(
            semantic: NorthstarBadgeSemantic.positive,
            showBorder: true,
            automationId: 'cat_badge_inset_dot',
          ),
          child: Container(
            width: 220,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Section title',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Corner placement · centered on corner (icon + count)',
            style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarBadged(
          placement: NorthstarBadgePlacement.centeredOnCornerTopEnd,
          badge: NorthstarBadge.digits(
            semantic: NorthstarBadgeSemantic.negative,
            value: '12',
            showBorder: true,
            automationId: 'cat_badge_corner_cnt',
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.notifications_outlined, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Avatar + status (inset on image, border)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            NorthstarAvatar(
              persona: NorthstarAvatarPersona.user,
              size: 48,
              showBorder: true,
              initials: 'NS',
              automationId: 'cat_badge_av',
            ),
            PositionedDirectional(
              end: 2,
              bottom: 2,
              child: NorthstarBadge.status(
                semantic: NorthstarBadgeSemantic.positive,
                diameter: 12,
                showBorder: true,
                automationId: 'cat_badge_av_dot',
              ),
            ),
          ],
        ),
      ],
    ),
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

Widget _northstarDividerCatalogPreview(BuildContext context) {
  final TextStyle caption = Theme.of(context).textTheme.labelSmall!;

  Widget hRow(String label, NorthstarDividerStyle style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: caption),
        const SizedBox(height: 6),
        NorthstarDivider(
          style: style,
          automationId: 'cat_div_h_${style.name}',
        ),
      ],
    );
  }

  return SizedBox(
    width: 280,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        hRow('Horizontal · fullWidth', NorthstarDividerStyle.fullWidth),
        const SizedBox(height: NorthstarSpacing.space16),
        hRow('Horizontal · inset', NorthstarDividerStyle.inset),
        const SizedBox(height: NorthstarSpacing.space16),
        hRow('Horizontal · middleInset', NorthstarDividerStyle.middleInset),
        const SizedBox(height: 20),
        Text('Vertical (fixed 72px row)', style: caption),
        const SizedBox(height: NorthstarSpacing.space8),
        SizedBox(
          height: 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Center(
                  child:
                      Text('A', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              NorthstarDivider(
                orientation: NorthstarDividerOrientation.vertical,
                style: NorthstarDividerStyle.fullWidth,
                automationId: 'cat_div_v_full',
              ),
              Expanded(
                child: Center(
                  child:
                      Text('B', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
              NorthstarDivider(
                orientation: NorthstarDividerOrientation.vertical,
                style: NorthstarDividerStyle.middleInset,
                inset: 12,
                automationId: 'cat_div_v_mid',
              ),
              Expanded(
                child: Center(
                  child:
                      Text('C', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _northstarStackedAvatarsCatalogPreview(BuildContext context) {
  NorthstarAvatar face(String initials, String automationId) {
    return NorthstarAvatar(
      showBorder: true,
      initials: initials,
      size: 40,
      automationId: automationId,
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text('≤5 (show all)', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      NorthstarStackedAvatars(
        behavior: NorthstarStackedAvatarsBehavior.showAllMaxFive,
        automationId: 'cat_stack_five',
        tooltip: 'Core team',
        avatars: <Widget>[
          face('A', 'cat_s5_a'),
          face('B', 'cat_s5_b'),
          face('C', 'cat_s5_c'),
        ],
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Text('>4 numeric (48 total → chip 44; 103 → 99; 104+ → 99+)',
          style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      NorthstarStackedAvatars(
        behavior: NorthstarStackedAvatarsBehavior.overflowNumeric,
        totalMemberCount: 48,
        automationId: 'cat_stack_num',
        avatars: <Widget>[
          face('A', 'cat_sn_a'),
          face('B', 'cat_sn_b'),
          face('C', 'cat_sn_c'),
          face('D', 'cat_sn_d'),
        ],
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Text('Indeterminate (…)', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      NorthstarStackedAvatars(
        behavior: NorthstarStackedAvatarsBehavior.overflowIndeterminate,
        totalMemberCount: 120,
        automationId: 'cat_stack_el',
        avatars: <Widget>[
          face('A', 'cat_se_a'),
          face('B', 'cat_se_b'),
          face('C', 'cat_se_c'),
          face('D', 'cat_se_d'),
        ],
      ),
    ],
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
            onPrimaryAction: () {},
            showDismissButton: true,
            onDismiss: () {},
            automationId: 'cat_banner_norm_ok',
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          NorthstarBanner(
            kind: NorthstarBannerKind.normal,
            status: NorthstarBannerStatus.informative,
            label: 'New policy available',
            body: 'Read the updated remote work guidelines.',
            primaryActionLabel: 'Open policy',
            onPrimaryAction: () {},
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
            onPrimaryAction: () {},
            onDismiss: () {},
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
            onPrimaryAction: () {},
            secondaryActionLabel: 'Later',
            onSecondaryAction: () {},
            onDismiss: () {},
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
                        onPrimaryAction: () {},
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
                        onPrimaryAction: () {},
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

Widget _northstarAccordionCatalogPreview(BuildContext context) {
  final TextStyle? sectionLabel =
      Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          );
  return SingleChildScrollView(
    padding: const EdgeInsets.all(NorthstarSpacing.space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text('Panel (≥8 logical px between items)', style: sectionLabel),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.panel,
          title: 'Billing address',
          automationId: 'cat_acc_panel_1',
          child: const Text(
            'Use a card on file or add a new payment method.',
          ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.panel,
          title:
              'Shipping — long titles wrap across lines instead of truncating with ellipsis when possible',
          automationId: 'cat_acc_panel_2',
          child: const Text('Body copy.'),
        ),
        const SizedBox(height: NorthstarSpacing.space24),
        Text('Divider list', style: sectionLabel),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.divider,
          title: 'Question one',
          automationId: 'cat_acc_div_1',
          child: const Text('Answer text.'),
        ),
        const NorthstarDivider(),
        NorthstarAccordion(
          style: NorthstarAccordionStyle.divider,
          title: 'Question two (disabled)',
          enabled: false,
          automationId: 'cat_acc_div_2',
          child: const Text('Tap is ignored when disabled.'),
        ),
      ],
    ),
  );
}

Widget _northstarButtonCatalogPreview(BuildContext context) {
  final ColorScheme scheme = Theme.of(context).colorScheme;
  // Match theme surface so tertiary / icon-only (onSurface ink) stay visible;
  // a fixed light grey behind dark-theme text made default states look “empty”.
  final Color matrixBg = scheme.surfaceContainerLow;
  final TextStyle headerStyle =
      Theme.of(context).textTheme.labelMedium!.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          );
  final TextStyle rowLabelStyle = headerStyle.copyWith(
    color: scheme.onSurfaceVariant,
  );

  Widget cell(Widget child) {
    return Padding(
      padding: const EdgeInsets.only(right: NorthstarSpacing.space16),
      child: child,
    );
  }

  List<Widget> matrixRow({
    required String title,
    required NorthstarButtonVariant variant,
    required String label,
    required NorthstarButtonTone tone,
  }) {
    return <Widget>[
      SizedBox(
        width: 72,
        child: Text(title, style: rowLabelStyle),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          onPressed: () {},
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          interactionPreview: NorthstarButtonInteractionPreview.hovered,
          onPressed: () {},
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          interactionPreview: NorthstarButtonInteractionPreview.pressed,
          onPressed: () {},
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          onPressed: null,
        ),
      ),
      cell(
        NorthstarButton(
          variant: variant,
          tone: tone,
          label: label,
          trailingIcon: Icons.add,
          isLoading: true,
          loadingStyle: variant == NorthstarButtonVariant.iconOnly
              ? NorthstarButtonLoadingStyle.spinnerOnly
              : NorthstarButtonLoadingStyle.labelWithSpinner,
          onPressed: () {},
        ),
      ),
    ];
  }

  List<Widget> iconRowForTone(NorthstarButtonTone tone) {
    return <Widget>[
      const SizedBox(width: 72),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          onPressed: () {},
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          interactionPreview: NorthstarButtonInteractionPreview.hovered,
          onPressed: () {},
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          interactionPreview: NorthstarButtonInteractionPreview.pressed,
          onPressed: () {},
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          onPressed: null,
        ),
      ),
      cell(
        NorthstarButton(
          variant: NorthstarButtonVariant.iconOnly,
          tone: tone,
          trailingIcon: Icons.add,
          semanticLabel: 'Add',
          isLoading: true,
          onPressed: () {},
        ),
      ),
    ];
  }

  List<Widget> matrixForTone(
    BuildContext ctx,
    NorthstarButtonTone tone,
    String title,
  ) {
    return <Widget>[
      const SizedBox(height: 20),
      Text(
        title,
        style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      const SizedBox(height: NorthstarSpacing.space12),
      Row(
        children: matrixRow(
          title: 'Primary',
          variant: NorthstarButtonVariant.primary,
          label: 'Primary',
          tone: tone,
        ),
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Row(
        children: matrixRow(
          title: 'Secondary',
          variant: NorthstarButtonVariant.secondary,
          label: 'Secondary',
          tone: tone,
        ),
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Row(
        children: matrixRow(
          title: 'Tertiary',
          variant: NorthstarButtonVariant.tertiary,
          label: 'Tertiary',
          tone: tone,
        ),
      ),
      const SizedBox(height: NorthstarSpacing.space16),
      Row(children: iconRowForTone(tone)),
    ];
  }

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ColoredBox(
      color: matrixBg,
      child: Padding(
        padding: const EdgeInsets.all(NorthstarSpacing.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const SizedBox(width: 72),
                ...<String>[
                  'Default',
                  'Hover',
                  'Pressed',
                  'Disabled',
                  'Loading',
                ].map(
                  (String h) => cell(
                    SizedBox(
                      width: 112,
                      child: Text(h, style: headerStyle),
                    ),
                  ),
                ),
              ],
            ),
            ...matrixForTone(
              context,
              NorthstarButtonTone.standard,
              'Tone · standard (primary)',
            ),
            ...matrixForTone(
              context,
              NorthstarButtonTone.positive,
              'Tone · positive (success)',
            ),
            ...matrixForTone(
              context,
              NorthstarButtonTone.negative,
              'Tone · negative (error)',
            ),
            const SizedBox(height: 20),
            Text(
              'Custom backgroundColor / foregroundColor',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarButton(
              variant: NorthstarButtonVariant.primary,
              label: 'Custom fill',
              trailingIcon: Icons.add,
              backgroundColor: NorthstarColorTokens.of(context).secondary,
              foregroundColor: NorthstarColorTokens.of(context).onSecondary,
              onPressed: () {},
            ),
            const SizedBox(height: 20),
            Text(
              'Optional width · leading + trailing · margin / padding',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: NorthstarSpacing.space8),
            NorthstarButton(
              variant: NorthstarButtonVariant.primary,
              label: 'Full-width primary',
              trailingIcon: Icons.add,
              width: 280,
              onPressed: () {},
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            NorthstarButton(
              variant: NorthstarButtonVariant.secondary,
              label: 'Leading icon',
              leadingIcon: Icons.arrow_back,
              margin: const EdgeInsets.only(right: NorthstarSpacing.space12),
              onPressed: () {},
            ),
            NorthstarButton(
              variant: NorthstarButtonVariant.tertiary,
              label: 'Both icons',
              leadingIcon: Icons.star_outline,
              trailingIcon: Icons.chevron_right,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ),
  );
}

/// Live chip catalog: [onSelected] demo + [NorthstarChipInteractionPreview] rows.
class _NorthstarChipCatalogDemo extends StatefulWidget {
  const _NorthstarChipCatalogDemo();

  @override
  State<_NorthstarChipCatalogDemo> createState() =>
      _NorthstarChipCatalogDemoState();
}

class _NorthstarChipCatalogDemoState extends State<_NorthstarChipCatalogDemo> {
  bool _filterOffice = false;
  bool _filterRemote = true;
  bool _filterWithIcon = true;

  @override
  Widget build(BuildContext context) {
    final TextStyle caption = Theme.of(context).textTheme.labelSmall!;

    Widget section(String title, List<Widget> children) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: caption),
          const SizedBox(height: NorthstarSpacing.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        ],
      );
    }

    Widget previewRow(String rowTitle, List<Widget> chips) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(rowTitle, style: caption),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: chips,
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          section(
            'Assist',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.assist,
                label: 'Add to calendar',
                leadingIcon: Icons.event_outlined,
                onTap: () {},
                automationId: 'cat_assist',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.assist,
                label: 'Share',
                onTap: () {},
                automationId: 'cat_assist2',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.assist,
                label: 'Disabled',
                disabled: true,
                onTap: () {},
                automationId: 'cat_assist_dis',
              ),
            ],
          ),
          const SizedBox(height: 20),
          section(
            'Filter (onSelected)',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Office',
                selected: _filterOffice,
                onSelected: (bool next) => setState(() => _filterOffice = next),
                automationId: 'cat_f_off',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Remote',
                selected: _filterRemote,
                onSelected: (bool next) => setState(() => _filterRemote = next),
                automationId: 'cat_f_rem',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'With icon',
                leadingIcon: Icons.laptop_mac_outlined,
                selected: _filterWithIcon,
                onSelected: (bool next) =>
                    setState(() => _filterWithIcon = next),
                automationId: 'cat_f_ic',
              ),
            ],
          ),
          const SizedBox(height: 20),
          section(
            'Input',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.input,
                label: 'Recipient',
                onTap: () {},
                onClose: () {},
                automationId: 'cat_in1',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.input,
                label: 'Active',
                selected: true,
                onTap: () {},
                onClose: () {},
                automationId: 'cat_in2',
              ),
            ],
          ),
          const SizedBox(height: 20),
          section(
            'Status',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.status,
                label: 'Published',
                statusSemantic: NorthstarChipStatusSemantic.positive,
                automationId: 'cat_st_p',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.status,
                label: 'Pending',
                statusSemantic: NorthstarChipStatusSemantic.pending,
                trailingIcon: Icons.expand_more,
                onTap: () {},
                automationId: 'cat_st_pe',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.status,
                label: 'Draft',
                statusSemantic: NorthstarChipStatusSemantic.neutral,
                statusEmphasis: NorthstarChipStatusEmphasis.soft,
                automationId: 'cat_st_n',
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Interaction preview (screenshots / docs)',
            style: caption.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          previewRow(
            'Assist',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.assist,
                label: 'Default',
                onTap: () {},
                automationId: 'cat_pv_as_d',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.assist,
                label: 'Hovered',
                onTap: () {},
                interactionPreview: NorthstarChipInteractionPreview.hovered,
                automationId: 'cat_pv_as_h',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.assist,
                label: 'Pressed',
                onTap: () {},
                interactionPreview: NorthstarChipInteractionPreview.pressed,
                automationId: 'cat_pv_as_p',
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          previewRow(
            'Filter · unselected',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Default',
                onSelected: (_) {},
                automationId: 'cat_pv_fu_d',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Hovered',
                onSelected: (_) {},
                interactionPreview: NorthstarChipInteractionPreview.hovered,
                automationId: 'cat_pv_fu_h',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Pressed',
                onSelected: (_) {},
                interactionPreview: NorthstarChipInteractionPreview.pressed,
                automationId: 'cat_pv_fu_p',
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          previewRow(
            'Filter · selected',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Default',
                selected: true,
                onSelected: (_) {},
                automationId: 'cat_pv_fs_d',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Hovered',
                selected: true,
                onSelected: (_) {},
                interactionPreview: NorthstarChipInteractionPreview.hovered,
                automationId: 'cat_pv_fs_h',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.filter,
                label: 'Pressed',
                selected: true,
                onSelected: (_) {},
                interactionPreview: NorthstarChipInteractionPreview.pressed,
                automationId: 'cat_pv_fs_p',
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          previewRow(
            'Input',
            <Widget>[
              NorthstarChip(
                useCase: NorthstarChipUseCase.input,
                label: 'Default',
                onClose: () {},
                automationId: 'cat_pv_in_d',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.input,
                label: 'Hovered',
                onClose: () {},
                interactionPreview: NorthstarChipInteractionPreview.hovered,
                automationId: 'cat_pv_in_h',
              ),
              NorthstarChip(
                useCase: NorthstarChipUseCase.input,
                label: 'Pressed',
                onClose: () {},
                interactionPreview: NorthstarChipInteractionPreview.pressed,
                automationId: 'cat_pv_in_p',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
