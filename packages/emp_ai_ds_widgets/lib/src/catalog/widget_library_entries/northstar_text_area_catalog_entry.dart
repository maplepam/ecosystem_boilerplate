import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/catalog_preview_snack.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/text_area/northstar_text_area.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarTextAreaCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_text_area',
    title: 'NorthstarTextArea',
    description:
        'Multiline field (8px radius): label, optional `*`, helper, error line, '
        'optional **n/limit** counter (pink at limit). Variants: **standard**, '
        '**chips** (wrap + add hint, max height 256), **richText** (WYSIWYG Quill + '
        '[NorthstarTextAreaRichToolbar]; [onRichHtmlChanged]; undo/redo; light/dark strip).',
    code: '''
  NorthstarTextArea(
    label: 'Profile summary',
    isRequired: true,
    helperText: 'Keep it concise.',
    characterLimit: 500,
    variant: NorthstarTextAreaVariant.standard,
    automationId: 'profile_summary',
    onChanged: (_) {},
  )
  ''',
    preview: (BuildContext context) => const _NorthstarTextAreaCatalogDemo(),
  );
}

class _NorthstarTextAreaCatalogDemo extends StatefulWidget {
  const _NorthstarTextAreaCatalogDemo();

  @override
  State<_NorthstarTextAreaCatalogDemo> createState() =>
      _NorthstarTextAreaCatalogDemoState();
}

class _NorthstarTextAreaCatalogDemoState
    extends State<_NorthstarTextAreaCatalogDemo> {
  NorthstarTextAreaVariant _variant = NorthstarTextAreaVariant.standard;
  bool _showLabel = true;
  bool _required = true;
  bool _showHelper = true;
  bool _showError = false;
  bool _disabled = false;
  bool _readOnly = false;
  int? _limit = 200;

  final TextEditingController _standard = TextEditingController();
  List<String> _skills = <String>['Figma', 'UX Research'];
  String _richParagraphLabel = 'Normal text';

  static const Map<String, String> _paragraphStyleLabels = <String, String>{
    'style_normal': 'Normal text',
    'style_h1': 'Heading 1',
    'style_h2': 'Heading 2',
    'style_quote': 'Quote',
  };

  @override
  void dispose() {
    _standard.dispose();
    super.dispose();
  }

  void _toast(BuildContext context, String msg) {
    catalogPreviewSnack(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Configure',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          SegmentedButton<NorthstarTextAreaVariant>(
            segments: const <ButtonSegment<NorthstarTextAreaVariant>>[
              ButtonSegment<NorthstarTextAreaVariant>(
                value: NorthstarTextAreaVariant.standard,
                label: Text('Standard'),
              ),
              ButtonSegment<NorthstarTextAreaVariant>(
                value: NorthstarTextAreaVariant.chips,
                label: Text('Chips'),
              ),
              ButtonSegment<NorthstarTextAreaVariant>(
                value: NorthstarTextAreaVariant.richText,
                label: Text('Rich'),
              ),
            ],
            selected: <NorthstarTextAreaVariant>{_variant},
            onSelectionChanged: (Set<NorthstarTextAreaVariant> next) {
              setState(() => _variant = next.first);
            },
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          Wrap(
            spacing: NorthstarSpacing.space12,
            runSpacing: NorthstarSpacing.space8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              FilterChip(
                label: const Text('Label'),
                selected: _showLabel,
                onSelected: (bool v) => setState(() => _showLabel = v),
              ),
              FilterChip(
                label: const Text('Required *'),
                selected: _required,
                onSelected: (bool v) => setState(() => _required = v),
              ),
              FilterChip(
                label: const Text('Helper'),
                selected: _showHelper,
                onSelected: (bool v) => setState(() => _showHelper = v),
              ),
              FilterChip(
                label: const Text('Error'),
                selected: _showError,
                onSelected: (bool v) => setState(() => _showError = v),
              ),
              FilterChip(
                label: const Text('Disabled'),
                selected: _disabled,
                onSelected: (bool v) => setState(() => _disabled = v),
              ),
              FilterChip(
                label: const Text('Read-only'),
                selected: _readOnly,
                onSelected: (bool v) => setState(() => _readOnly = v),
              ),
            ],
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Row(
            children: <Widget>[
              Text(
                'Character limit',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(width: NorthstarSpacing.space12),
              DropdownButton<int?>(
                value: _limit,
                items: const <DropdownMenuItem<int?>>[
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 50,
                    child: Text('50'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 200,
                    child: Text('200'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 500,
                    child: Text('500'),
                  ),
                ],
                onChanged: _variant == NorthstarTextAreaVariant.chips
                    ? null
                    : (int? v) => setState(() => _limit = v),
              ),
            ],
          ),
          if (_variant == NorthstarTextAreaVariant.chips)
            Padding(
              padding: const EdgeInsets.only(top: NorthstarSpacing.space4),
              child: Text(
                'Limit applies to standard / rich only.',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          const SizedBox(height: NorthstarSpacing.space24),
          Text(
            'Live preview',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: NorthstarSpacing.space12),
          if (_variant == NorthstarTextAreaVariant.standard)
            NorthstarTextArea(
              label: _showLabel ? 'Profile summary' : null,
              isRequired: _required,
              showInfoIcon: _showLabel,
              onInfoTap: () => _toast(context, 'Info tapped'),
              helperText: _showHelper
                  ? 'Shown below the label (4px gap); 12px before the field.'
                  : null,
              errorText: _showError ? 'Error message under the field.' : null,
              enabled: !_disabled,
              readOnly: _readOnly,
              characterLimit: _limit,
              controller: _standard,
              variant: NorthstarTextAreaVariant.standard,
              placeholder: 'Start typing here…',
              automationId: 'catalog_text_area_std',
              onChanged: (_) => setState(() {}),
            ),
          if (_variant == NorthstarTextAreaVariant.chips)
            NorthstarTextArea(
              label: _showLabel ? 'Skills' : null,
              isRequired: _required,
              helperText: _showHelper
                  ? 'Type and press Enter to add a chip. Max area height 256px.'
                  : null,
              errorText: _showError ? 'Pick at least one skill.' : null,
              enabled: !_disabled,
              readOnly: _readOnly,
              variant: NorthstarTextAreaVariant.chips,
              chips: _skills,
              onChipsChanged: (_disabled || _readOnly)
                  ? null
                  : (List<String> v) => setState(() => _skills = v),
              chipInputHint: 'Add skills',
              automationId: 'catalog_text_area_chips',
            ),
          if (_variant == NorthstarTextAreaVariant.richText)
            NorthstarTextArea(
              label: _showLabel ? 'Notes' : null,
              isRequired: _required,
              helperText: _showHelper
                  ? 'WYSIWYG toolbar (bold, lists, headings, alignment, etc.). '
                      'Plain text length drives the counter; onRichHtmlChanged receives HTML. '
                      '“More” still shows a snack hint.'
                  : null,
              errorText: _showError ? 'Something went wrong.' : null,
              enabled: !_disabled,
              readOnly: _readOnly,
              characterLimit: _limit,
              variant: NorthstarTextAreaVariant.richText,
              richParagraphStyleLabel: _richParagraphLabel,
              automationId: 'catalog_text_area_rich',
              onRichToolbarAction: (String id) {
                final String? nextLabel = _paragraphStyleLabels[id];
                if (nextLabel != null) {
                  setState(() => _richParagraphLabel = nextLabel);
                }
                if (id == 'more') {
                  _toast(
                    context,
                    'Overflow menu: host app would open a dialog or extra actions here.',
                  );
                }
              },
              onChanged: (_) => setState(() {}),
            ),
        ],
      ),
    );
  }
}
