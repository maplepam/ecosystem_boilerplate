import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_snackbar.dart';
import 'package:emp_ai_ds_widgets/src/display/selections/northstar_batch_action_bar.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarSnackbarCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_snackbar',
    title: 'NorthstarSnackbar',
    description:
        'Figma **Snackbars**: **4px** left accent (success / warning / error / neutral), bold message, '
        'optional text **actions** (**24px** gaps), optional **close**. Width **hugs** content between '
        '**272** and **480** logical px. **[NorthstarSnackbarSurfaceVariant.standard]** uses **surface**; '
        '**inverse** uses **inverseSurface** (contrast). In **light** mode that reads as light vs dark bar; '
        'in **dark** mode **surface** is dark and **inverse** is light—labels follow the token, not a fixed '
        'paint color. **[showNorthstarSnackBar]** supports **position** '
        '(top/bottom × left / center / right); default **bottomLeft** uses **88** start and **48** bottom '
        'inset. Top anchors use a short **[OverlayEntry]** because Material snack bars are bottom-only. '
        '**[showNorthstarBulkSnackBar]** hosts **[NorthstarBatchActionBar]** (selection / bulk actions) '
        'anchored **bottom center**; width **hugs** content (capped by viewport margins, no **480** cap). '
        'Optional **[overlayDismissAfter]** removes the overlay after a delay (catalog uses **2s**). '
        '**[duration]** applies only to the scaffold fallback. '
        'Message is **start**-aligned with **ellipsis** when long; actions and close stay **trailing**. '
        'Default **1500ms** auto-dismiss; **[persistUntilDismissed]** when an action is required. '
        'Do not stack—clear before showing the next.',
    code: r'''
  // Transient feedback (auto-dismiss 1500ms), default bottom-left insets:
  showNorthstarSnackBar(
    context,
    message: 'Profile updated',
    kind: NorthstarSnackbarKind.success,
    showClose: false,
  );

  // Placement + inverse surface (e.g. top-center toast):
  showNorthstarSnackBar(
    context,
    message: 'Interview schedule sent to talent',
    kind: NorthstarSnackbarKind.success,
    surfaceVariant: NorthstarSnackbarSurfaceVariant.inverse,
    position: NorthstarSnackbarPosition.topCenter,
    actions: <NorthstarSnackbarAction>[
      NorthstarSnackbarAction(label: 'View details', onPressed: () {}),
    ],
  );

  // Bulk / multi-select bar (always bottom-center on the viewport):
  showNorthstarBulkSnackBar(
    context,
    overlayDismissAfter: const Duration(seconds: 2), // optional; demo / catalog
    child: NorthstarBatchActionBar(
      primaryLine: '4 pending requests selected',
      secondaryLine: '4 request types selected',
      onDeselect: () {},
      actions: <Widget>[/* Reject / Approve buttons */],
    ),
  );

  // With actions + manual close:
  showNorthstarSnackBar(
    context,
    message: 'Batch upload incomplete',
    kind: NorthstarSnackbarKind.warning,
    actions: <NorthstarSnackbarAction>[
      NorthstarSnackbarAction(
        label: 'View details',
        onPressed: () {},
      ),
      NorthstarSnackbarAction(
        label: 'Retry',
        onPressed: () {},
      ),
    ],
    showClose: true,
    automationId: 'upload',
  );

  // Required action — stays until dismissed:
  showNorthstarSnackBar(
    context,
    message: 'New version available',
    kind: NorthstarSnackbarKind.neutral,
    actions: <NorthstarSnackbarAction>[
      NorthstarSnackbarAction(
        label: 'Update now',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ],
    persistUntilDismissed: true,
  );

  // Inline (e.g. custom host / overlay):
  const NorthstarSnackbar(
    message: 'Add talent failed',
    kind: NorthstarSnackbarKind.error,
    actions: <NorthstarSnackbarAction>[
      NorthstarSnackbarAction(label: 'Retry', onPressed: _retry),
    ],
  );
  ''',
    preview: (BuildContext context) => const _NorthstarSnackbarCatalogDemo(),
  );
}

class _NorthstarSnackbarCatalogDemo extends StatefulWidget {
  const _NorthstarSnackbarCatalogDemo();

  @override
  State<_NorthstarSnackbarCatalogDemo> createState() =>
      _NorthstarSnackbarCatalogDemoState();
}

class _NorthstarSnackbarCatalogDemoState
    extends State<_NorthstarSnackbarCatalogDemo> {
  _SnackbarDemoScenario _scenario = _SnackbarDemoScenario.successMinimal;
  NorthstarSnackbarPosition _position = NorthstarSnackbarPosition.bottomLeft;
  NorthstarSnackbarSurfaceVariant _surface =
      NorthstarSnackbarSurfaceVariant.standard;

  static void _noop() {}

  void _showForScenario() {
    switch (_scenario) {
      case _SnackbarDemoScenario.successMinimal:
        showNorthstarSnackBar(
          context,
          message: 'Job request deleted',
          kind: NorthstarSnackbarKind.success,
          showClose: false,
          position: _position,
          surfaceVariant: _surface,
        );
      case _SnackbarDemoScenario.warningActions:
        showNorthstarSnackBar(
          context,
          message: 'Batch upload incomplete',
          kind: NorthstarSnackbarKind.warning,
          automationId: 'catalog_snackbar',
          position: _position,
          surfaceVariant: _surface,
          actions: <NorthstarSnackbarAction>[
            NorthstarSnackbarAction(
              label: 'View details',
              onPressed: _noop,
            ),
            NorthstarSnackbarAction(
              label: 'Retry',
              onPressed: _noop,
            ),
          ],
        );
      case _SnackbarDemoScenario.errorActions:
        showNorthstarSnackBar(
          context,
          message: 'Add talent failed',
          kind: NorthstarSnackbarKind.error,
          position: _position,
          surfaceVariant: _surface,
          actions: <NorthstarSnackbarAction>[
            NorthstarSnackbarAction(
              label: 'View details',
              onPressed: _noop,
            ),
            NorthstarSnackbarAction(
              label: 'Retry',
              onPressed: _noop,
            ),
          ],
        );
      case _SnackbarDemoScenario.neutralPersist:
        final ScaffoldMessengerState m = ScaffoldMessenger.of(context);
        showNorthstarSnackBar(
          context,
          message: 'New version available',
          kind: NorthstarSnackbarKind.neutral,
          persistUntilDismissed: true,
          position: _position,
          surfaceVariant: _surface,
          actions: <NorthstarSnackbarAction>[
            NorthstarSnackbarAction(
              label: 'Update now',
              onPressed: () => m.hideCurrentSnackBar(),
            ),
          ],
        );
      case _SnackbarDemoScenario.longMessageOverflow:
        showNorthstarSnackBar(
          context,
          message: _kLongCatalogSnackbarMessage,
          kind: NorthstarSnackbarKind.warning,
          position: _position,
          surfaceVariant: _surface,
          actions: <NorthstarSnackbarAction>[
            NorthstarSnackbarAction(
              label: 'View details',
              onPressed: _noop,
            ),
          ],
        );
      case _SnackbarDemoScenario.inlinePreview:
        break;
    }
  }

  void _showBulkSnackBar() {
    final NorthstarColorTokens ns = NorthstarColorTokens.of(context);
    final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
    showNorthstarBulkSnackBar(
      context,
      overlayDismissAfter: const Duration(seconds: 2),
      child: NorthstarBatchActionBar(
        automationId: 'catalog_bulk_snack',
        leading: Icon(
          Icons.description_outlined,
          color: ns.onInverseSurface,
          size: 22,
        ),
        primaryLine: '4 pending requests selected',
        secondaryLine: '4 request types selected',
        onDeselect: () => messenger?.hideCurrentSnackBar(),
        actions: <Widget>[
          const SizedBox(width: NorthstarSpacing.space8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: ns.error,
              foregroundColor: ns.onError,
            ),
            onPressed: _noop,
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('Reject'),
          ),
          const SizedBox(width: NorthstarSpacing.space8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: ns.success,
              foregroundColor: ns.onSuccess,
            ),
            onPressed: _noop,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Approve'),
          ),
        ],
      ),
    );
  }

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
              for (final _SnackbarDemoScenario s in _SnackbarDemoScenario.values)
                ChoiceChip(
                  label: Text(_label(s)),
                  selected: _scenario == s,
                  onSelected: (_) => setState(() => _scenario = s),
                ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          Text(
            'Placement',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final NorthstarSnackbarPosition p
                  in NorthstarSnackbarPosition.values)
                ChoiceChip(
                  label: Text(_positionLabel(p)),
                  selected: _position == p,
                  onSelected: (_) => setState(() => _position = p),
                ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          Text(
            'Surface',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: Text(
                  Theme.of(context).brightness == Brightness.light
                      ? 'Standard (light surface)'
                      : 'Standard (dark surface)',
                ),
                selected:
                    _surface == NorthstarSnackbarSurfaceVariant.standard,
                onSelected: (_) => setState(
                  () => _surface = NorthstarSnackbarSurfaceVariant.standard,
                ),
              ),
              ChoiceChip(
                label: Text(
                  Theme.of(context).brightness == Brightness.light
                      ? 'Inverse (dark contrast)'
                      : 'Inverse (light contrast)',
                ),
                selected: _surface == NorthstarSnackbarSurfaceVariant.inverse,
                onSelected: (_) => setState(
                  () => _surface = NorthstarSnackbarSurfaceVariant.inverse,
                ),
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space16),
          if (_scenario == _SnackbarDemoScenario.inlinePreview) ...<Widget>[
            const Text(
              'Static preview (min width 272, max 480 — content hugs):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            Align(
              alignment: Alignment.centerLeft,
              child: NorthstarSnackbar(
                surfaceVariant: _surface,
                message: 'Profile updated',
                kind: NorthstarSnackbarKind.success,
                showClose: true,
                onClose: _noop,
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            Align(
              alignment: Alignment.centerLeft,
              child: NorthstarSnackbar(
                surfaceVariant: _surface,
                message:
                    'Interview schedule sent to talent — longer copy to show width cap',
                kind: NorthstarSnackbarKind.success,
                actions: <NorthstarSnackbarAction>[
                  NorthstarSnackbarAction(
                    label: 'View details',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            const Text(
              'Very long message (max 480 width, ellipsis after 8 lines):',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: NorthstarSpacing.space12),
            Align(
              alignment: Alignment.centerLeft,
              child: NorthstarSnackbar(
                surfaceVariant: _surface,
                message: _kLongCatalogSnackbarMessage,
                kind: NorthstarSnackbarKind.warning,
                actions: <NorthstarSnackbarAction>[
                  NorthstarSnackbarAction(
                    label: 'View details',
                    onPressed: _noop,
                  ),
                ],
              ),
            ),
            const SizedBox(height: NorthstarSpacing.space16),
          ],
          FilledButton(
            onPressed: _scenario == _SnackbarDemoScenario.inlinePreview
                ? null
                : _showForScenario,
            child: const Text('Show snackbar (selected scenario)'),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          OutlinedButton(
            onPressed: _showBulkSnackBar,
            child: const Text('Show bulk / batch bar'),
          ),
        ],
      ),
    );
  }

  static String _positionLabel(NorthstarSnackbarPosition p) {
    return switch (p) {
      NorthstarSnackbarPosition.topLeft => 'Top left',
      NorthstarSnackbarPosition.topCenter => 'Top center',
      NorthstarSnackbarPosition.topRight => 'Top right',
      NorthstarSnackbarPosition.bottomLeft => 'Bottom left',
      NorthstarSnackbarPosition.bottomRight => 'Bottom right',
      NorthstarSnackbarPosition.bottomCenter => 'Bottom center',
    };
  }

  static String _label(_SnackbarDemoScenario s) {
    return switch (s) {
      _SnackbarDemoScenario.successMinimal => 'Success · minimal',
      _SnackbarDemoScenario.warningActions => 'Warning · actions + close',
      _SnackbarDemoScenario.errorActions => 'Error · actions',
      _SnackbarDemoScenario.neutralPersist => 'Neutral · persist + action',
      _SnackbarDemoScenario.longMessageOverflow => 'Long text + action',
      _SnackbarDemoScenario.inlinePreview => 'Inline widget',
    };
  }
}

const String _kLongCatalogSnackbarMessage =
    'This is an intentionally long Northstar snackbar message used to verify the '
    '480px max width, minimum 272px width on bottom placements, and ellipsis when '
    'the copy exceeds the available space next to actions and the close control. '
    'Repeat: scheduling, notifications, compliance copy, and edge cases should wrap '
    'or truncate predictably without pushing actions off-screen.';

enum _SnackbarDemoScenario {
  successMinimal,
  warningActions,
  errorActions,
  neutralPersist,
  longMessageOverflow,
  inlinePreview,
}
