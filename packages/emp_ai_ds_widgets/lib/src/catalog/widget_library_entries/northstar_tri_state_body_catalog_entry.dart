import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_tri_state.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarTriStateBodyCatalogEntry() {
  return WidgetCatalogEntry(
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
    preview: (BuildContext context) => const _NorthstarTriStateCatalogDemo(),
  );
}

class _NorthstarTriStateCatalogDemo extends StatefulWidget {
  const _NorthstarTriStateCatalogDemo();

  @override
  State<_NorthstarTriStateCatalogDemo> createState() =>
      _NorthstarTriStateCatalogDemoState();
}

enum _TriDemoPhase { loading, error, data }

class _NorthstarTriStateCatalogDemoState
    extends State<_NorthstarTriStateCatalogDemo> {
  _TriDemoPhase _phase = _TriDemoPhase.data;

  NorthstarTriState<String> get _state => switch (_phase) {
        _TriDemoPhase.loading => const NorthstarTriLoading<String>(),
        _TriDemoPhase.error =>
          const NorthstarTriError<String>('Sample failure'),
        _TriDemoPhase.data => const NorthstarTriData<String>('Network OK'),
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SegmentedButton<_TriDemoPhase>(
            segments: const <ButtonSegment<_TriDemoPhase>>[
              ButtonSegment<_TriDemoPhase>(
                value: _TriDemoPhase.loading,
                label: Text('Loading'),
              ),
              ButtonSegment<_TriDemoPhase>(
                value: _TriDemoPhase.error,
                label: Text('Error'),
              ),
              ButtonSegment<_TriDemoPhase>(
                value: _TriDemoPhase.data,
                label: Text('Data'),
              ),
            ],
            selected: <_TriDemoPhase>{_phase},
            onSelectionChanged: (Set<_TriDemoPhase> next) {
              setState(() => _phase = next.first);
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: NorthstarTriStateBody<String>(
              state: _state,
              dataBuilder: (_, String s) => Center(child: Text(s)),
            ),
          ),
        ],
      ),
    );
  }
}
