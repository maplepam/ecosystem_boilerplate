# Contributing to `emp_ai_ds_widgets`

## Automation keys (required)

Every new or updated interactive widget in this package **must** support stable test targeting:

1. Add an optional `automationId` parameter on the public widget when it makes sense for integration or widget tests.
2. Apply [`ValueKey`](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)s via [`DsAutomationKeys.part`](lib/src/testing/ds_automation_keys.dart) for **each meaningful sub-control** (surface, primary label, icons, overflow chip, stacked slots, etc.).
3. Add new `element*` constants to [`DsAutomationKeys`](lib/src/testing/ds_automation_keys.dart) instead of inlining magic strings in widgets.
4. Prefer the key shape: `ds:<automationId>:<elementId>` (already encoded by `DsAutomationKeys.part`).
5. Register a representative example in the widget catalog with `automationId` set so the pattern stays visible to contributors:
   - Add a [`WidgetCatalogEntry`](lib/src/catalog/widget_catalog_entry.dart) to [`NorthstarWidgetLibraryPage.builtInEntries()`](lib/src/catalog/northstar_widget_library_page.dart) (`id`, `title`, `description`, `code`, `preview`).
   - Host apps typically open the catalog via [`NorthstarWidgetLibraryListPage`](lib/src/catalog/northstar_widget_library_list_page.dart) (searchable list) and [`NorthstarWidgetLibraryDetailPage`](lib/src/catalog/northstar_widget_library_detail_page.dart) (live preview + expandable “How to use” code). [`NorthstarWidgetLibraryPage`](lib/src/catalog/northstar_widget_library_page.dart) remains a self-contained **list → push detail** flow for quick local checks without GoRouter.

Skipping keys should be rare (e.g. purely decorative, non-interactive internals). When in doubt, key the root and user-visible children.
