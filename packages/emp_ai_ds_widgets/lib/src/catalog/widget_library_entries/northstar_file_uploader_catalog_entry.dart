import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:emp_ai_ds_widgets/src/catalog/widget_catalog_entry.dart';
import 'package:emp_ai_ds_widgets/src/display/northstar_file_uploader.dart';
import 'package:flutter/material.dart';

WidgetCatalogEntry northstarFileUploaderCatalogEntry() {
  return WidgetCatalogEntry(
    id: 'northstar_file_uploader',
    title: 'NorthstarFileUploader',
    description:
        'Label, helper, dashed drop zone or “+ Add File” button, optional '
        'global error, and file rows (uploading with progress in the zone, '
        'transient success check, uploaded with remove, per-file error). '
        'Host owns the file list and pickers; items sort with completed rows '
        'above in-progress rows.',
    code: '''
  NorthstarFileUploader(
    automationId: 'profile_photo',
    label: 'Upload profile picture',
    isRequired: true,
    helperText: 'Max file size: 1MB. Supported format: JPG, PNG, PDF',
    mode: NorthstarFileUploaderMode.dropZone,
    files: items,
    uploaderErrorText: fieldError,
    onActivate: () => openFilePicker(context),
    onRemove: (id) => setState(() => items.removeWhere((e) => e.id == id)),
  )
  ''',
    preview: (BuildContext context) =>
        const _NorthstarFileUploaderCatalogDemo(),
  );
}

/// Interactive demo: mode toggle, global error, disabled, simulate upload/fail,
/// clear list, activate control → new upload; success → uploaded after 2s.
class _NorthstarFileUploaderCatalogDemo extends StatefulWidget {
  const _NorthstarFileUploaderCatalogDemo();

  @override
  State<_NorthstarFileUploaderCatalogDemo> createState() =>
      _NorthstarFileUploaderCatalogDemoState();
}

class _NorthstarFileUploaderCatalogDemoState
    extends State<_NorthstarFileUploaderCatalogDemo> {
  NorthstarFileUploaderMode _mode = NorthstarFileUploaderMode.dropZone;
  bool _enabled = true;
  bool _globalError = false;
  int _seq = 0;
  final List<NorthstarFileUploadItem> _files = <NorthstarFileUploadItem>[];

  void _remove(String id) {
    setState(
        () => _files.removeWhere((NorthstarFileUploadItem e) => e.id == id));
  }

  void _addSimulated({required bool fail}) {
    final String id = 'f${_seq++}';
    final String name = fail
        ? 'rejected.exe'
        : 'very_long_filename_that_truncates_with_ellipsis_in_the_list_view_$_seq.pdf';
    setState(() {
      _files.add(
        NorthstarFileUploadItem(
          id: id,
          name: name,
          status: NorthstarFileUploadStatus.uploading,
          progress: 0,
        ),
      );
    });
    _runUploadSimulation(id, fail: fail);
  }

  void _runUploadSimulation(String id, {required bool fail}) {
    void step(int n) {
      Future<void>.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) {
          return;
        }
        final int i =
            _files.indexWhere((NorthstarFileUploadItem e) => e.id == id);
        if (i < 0) {
          return;
        }
        if (fail && n >= 14) {
          setState(() {
            _files[i] = NorthstarFileUploadItem(
              id: id,
              name: _files[i].name,
              status: NorthstarFileUploadStatus.error,
              errorMessage: 'Upload failed',
            );
          });
          return;
        }
        final double p = ((n + 1) / 28).clamp(0.0, 1.0);
        if (p >= 1.0) {
          setState(() {
            _files[i] = NorthstarFileUploadItem(
              id: id,
              name: _files[i].name,
              status: NorthstarFileUploadStatus.success,
              progress: 1,
            );
          });
          Future<void>.delayed(const Duration(seconds: 2), () {
            if (!mounted) {
              return;
            }
            setState(() {
              final int j =
                  _files.indexWhere((NorthstarFileUploadItem e) => e.id == id);
              if (j >= 0 &&
                  _files[j].status == NorthstarFileUploadStatus.success) {
                _files[j] = NorthstarFileUploadItem(
                  id: id,
                  name: _files[j].name,
                  status: NorthstarFileUploadStatus.uploaded,
                  progress: 1,
                );
              }
            });
          });
          return;
        }
        setState(() {
          _files[i] = NorthstarFileUploadItem(
            id: id,
            name: _files[i].name,
            status: NorthstarFileUploadStatus.uploading,
            progress: p,
          );
        });
        step(n + 1);
      });
    }

    step(0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(NorthstarSpacing.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SegmentedButton<NorthstarFileUploaderMode>(
                segments: const <ButtonSegment<NorthstarFileUploaderMode>>[
                  ButtonSegment<NorthstarFileUploaderMode>(
                    value: NorthstarFileUploaderMode.dropZone,
                    label: Text('Drop zone'),
                  ),
                  ButtonSegment<NorthstarFileUploaderMode>(
                    value: NorthstarFileUploaderMode.addButton,
                    label: Text('Add button'),
                  ),
                ],
                selected: <NorthstarFileUploaderMode>{_mode},
                onSelectionChanged: (Set<NorthstarFileUploaderMode> next) {
                  setState(() => _mode = next.first);
                },
              ),
              FilterChip(
                label: const Text('Global error'),
                selected: _globalError,
                onSelected: (bool v) => setState(() => _globalError = v),
              ),
              FilterChip(
                label: const Text('Disabled'),
                selected: !_enabled,
                onSelected: (bool _) => setState(() => _enabled = !_enabled),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                onPressed: () => _addSimulated(fail: false),
                child: const Text('Simulate upload'),
              ),
              OutlinedButton(
                onPressed: () => _addSimulated(fail: true),
                child: const Text('Simulate fail'),
              ),
              TextButton(
                onPressed: () => setState(_files.clear),
                child: const Text('Clear list'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NorthstarFileUploader(
            automationId: 'catalog_file_uploader',
            label: 'Upload files',
            isRequired: true,
            helperText: 'Max file size: 5MB. Supported formats: JPG, PNG, PDF',
            mode: _mode,
            enabled: _enabled,
            files: _files,
            uploaderErrorText:
                _globalError ? 'Please choose a supported file type.' : null,
            onActivate: () => _addSimulated(fail: false),
            onRemove: _remove,
          ),
        ],
      ),
    );
  }
}
