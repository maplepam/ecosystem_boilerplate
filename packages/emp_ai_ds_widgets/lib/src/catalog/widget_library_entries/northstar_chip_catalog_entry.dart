import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_chip.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarChipCatalogEntry() {
  return WidgetCatalogEntry(
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
  );
}

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
