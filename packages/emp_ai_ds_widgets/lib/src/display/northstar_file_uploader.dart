import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:emp_ai_ds_widgets/src/display/northstar_button.dart';
import 'package:emp_ai_ds_widgets/src/testing/ds_automation_keys.dart';

/// How the user triggers file selection in [NorthstarFileUploader].
enum NorthstarFileUploaderMode {
  /// Dashed drop zone with “click here” to open the picker.
  dropZone,

  /// Primary “Add file” action ([leadingIcon] supplies the +).
  addButton,
}

/// Row state for an item in [NorthstarFileUploader.files].
enum NorthstarFileUploadStatus {
  /// In progress; [NorthstarFileUploadItem.progress] drives the bar / spinner.
  uploading,

  /// Transient success (e.g. green check); callers often move to [uploaded] after ~2s.
  success,

  /// Done; shows remove control.
  uploaded,

  /// Failed; shows [NorthstarFileUploadItem.errorMessage].
  error,
}

/// One file row shown under the uploader control.
@immutable
class NorthstarFileUploadItem {
  const NorthstarFileUploadItem({
    required this.id,
    required this.name,
    this.status = NorthstarFileUploadStatus.uploaded,
    this.progress = 0,
    this.errorMessage,
  });

  final String id;
  final String name;
  final NorthstarFileUploadStatus status;

  /// 0–1 while [status] is [NorthstarFileUploadStatus.uploading].
  final double progress;
  final String? errorMessage;
}

/// File uploader: label, helper, drop zone or add button, optional global error, file list.
///
/// **Ordering:** Per design, completed rows should appear above in-progress rows. This
/// widget sorts by status ([uploaded]/[success] first, then [uploading], then [error])
/// while preserving relative order within each group.
class NorthstarFileUploader extends StatelessWidget {
  const NorthstarFileUploader({
    super.key,
    this.automationId,
    this.label,
    this.isRequired = false,
    this.helperText,
    this.mode = NorthstarFileUploaderMode.dropZone,
    this.files = const [],
    this.enabled = true,
    this.uploaderErrorText,
    this.addButtonLabel = 'Add File',
    this.onActivate,
    this.onRemove,
    this.dropZoneMinHeight = 120,
  });

  /// Optional stable id for [DsAutomationKeys.part].
  final String? automationId;

  /// Field label (e.g. “Upload files”).
  final String? label;

  /// When true, shows a trailing asterisk on the label.
  final bool isRequired;

  /// Helper under the label (size / format hints).
  final String? helperText;

  final NorthstarFileUploaderMode mode;

  /// Items to render below the control; see class doc for sort order.
  final List<NorthstarFileUploadItem> files;

  final bool enabled;

  /// Validation or control-level error shown under the drop zone / button row.
  final String? uploaderErrorText;

  /// Label for [NorthstarFileUploaderMode.addButton]. The control adds a
  /// leading [Icons.add]; keep the label text without a “+” prefix.
  final String addButtonLabel;

  /// User tapped the drop zone, “click here”, or the add button.
  final VoidCallback? onActivate;

  /// Remove a completed or failed row (and optionally cancel upload in the host).
  final void Function(String id)? onRemove;

  /// Minimum height of the drop zone (default matches compact spec).
  final double dropZoneMinHeight;

  static List<NorthstarFileUploadItem> sortedFiles(
    List<NorthstarFileUploadItem> input,
  ) {
    int rank(NorthstarFileUploadStatus s) => switch (s) {
          NorthstarFileUploadStatus.uploaded ||
          NorthstarFileUploadStatus.success =>
            0,
          NorthstarFileUploadStatus.uploading => 1,
          NorthstarFileUploadStatus.error => 2,
        };
    final List<({int i, NorthstarFileUploadItem it})> tagged = [
      for (var i = 0; i < input.length; i++) (i: i, it: input[i]),
    ];
    tagged.sort((a, b) {
      final int c = rank(a.it.status).compareTo(rank(b.it.status));
      return c != 0 ? c : a.i.compareTo(b.i);
    });
    return tagged.map((e) => e.it).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final List<NorthstarFileUploadItem> ordered = sortedFiles(files);

    final bool anyUploading =
        files.any((e) => e.status == NorthstarFileUploadStatus.uploading);
    final double zoneProgress = _aggregateProgress(files);

    return Column(
      key: DsAutomationKeys.part(
        automationId,
        DsAutomationKeys.elementFileUploader,
      ),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          Text.rich(
            TextSpan(
              style: textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: label),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: scheme.error),
                  ),
              ],
            ),
          ),
          if (helperText != null && helperText!.isNotEmpty)
            const SizedBox(height: 8),
        ],
        if (helperText != null && helperText!.isNotEmpty)
          Text(
            helperText!,
            style: textTheme.bodySmall?.copyWith(
              color: Color.alphaBlend(
                scheme.onSurface.withValues(alpha: 0.76),
                scheme.surface,
              ),
            ),
          ),
        if ((label != null && label!.isNotEmpty) ||
            (helperText != null && helperText!.isNotEmpty))
          const SizedBox(height: 12),
        if (mode == NorthstarFileUploaderMode.dropZone)
          _NorthstarFileDropZone(
            automationId: automationId,
            enabled: enabled,
            minHeight: dropZoneMinHeight,
            hasError: uploaderErrorText != null && uploaderErrorText!.isNotEmpty,
            showProgress: anyUploading,
            progress: zoneProgress,
            onTap: enabled ? onActivate : null,
          )
        else
          Align(
            alignment: Alignment.centerLeft,
            child: KeyedSubtree(
              key: DsAutomationKeys.part(
                automationId,
                DsAutomationKeys.elementFileUploaderAddButton,
              ),
              child: NorthstarButton(
                automationId: automationId != null
                    ? '${automationId}_${DsAutomationKeys.elementFileUploaderAddButton}'
                    : null,
                label: addButtonLabel,
                variant: NorthstarButtonVariant.primary,
                leadingIcon: Icons.add,
                onPressed: enabled ? onActivate : null,
              ),
            ),
          ),
        if (uploaderErrorText != null && uploaderErrorText!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            uploaderErrorText!,
            key: DsAutomationKeys.part(
              automationId,
              DsAutomationKeys.elementFileUploaderGlobalError,
            ),
            style: textTheme.bodySmall?.copyWith(
              color: scheme.error,
            ),
          ),
        ],
        if (ordered.isNotEmpty) const SizedBox(height: 24),
        for (var i = 0; i < ordered.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _NorthstarFileUploadRow(
            automationId: automationId,
            item: ordered[i],
            enabled: enabled,
            onRemove: onRemove,
          ),
        ],
      ],
    );
  }

  static double _aggregateProgress(List<NorthstarFileUploadItem> list) {
    final Iterable<NorthstarFileUploadItem> up = list.where(
      (e) => e.status == NorthstarFileUploadStatus.uploading,
    );
    if (up.isEmpty) {
      return 0;
    }
    var sum = 0.0;
    var n = 0;
    for (final NorthstarFileUploadItem e in up) {
      sum += e.progress.clamp(0.0, 1.0);
      n++;
    }
    return n == 0 ? 0 : sum / n;
  }
}

class _NorthstarFileDropZone extends StatefulWidget {
  const _NorthstarFileDropZone({
    required this.enabled,
    required this.minHeight,
    required this.hasError,
    required this.showProgress,
    required this.progress,
    this.onTap,
    this.automationId,
  });

  final String? automationId;
  final bool enabled;
  final double minHeight;
  final bool hasError;
  final bool showProgress;
  final double progress;
  final VoidCallback? onTap;

  @override
  State<_NorthstarFileDropZone> createState() => _NorthstarFileDropZoneState();
}

class _NorthstarFileDropZoneState extends State<_NorthstarFileDropZone> {
  bool _hover = false;
  late final TapGestureRecognizer _linkTap;

  @override
  void initState() {
    super.initState();
    _linkTap = TapGestureRecognizer()..onTap = _handleActivate;
  }

  void _handleActivate() {
    if (widget.enabled) {
      widget.onTap?.call();
    }
  }

  @override
  void didUpdateWidget(covariant _NorthstarFileDropZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    _linkTap.onTap = widget.enabled ? _handleActivate : null;
  }

  @override
  void dispose() {
    _linkTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final Color primary = scheme.primary;
    final Color error = scheme.error;

    final Color baseFill = scheme.surfaceContainerLowest;
    final Color secondaryOnZone = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.78),
      baseFill,
    );
    Color borderColor = scheme.outlineVariant;
    Color fill = baseFill;
    if (!widget.enabled) {
      borderColor = scheme.outline.withValues(alpha: 0.35);
      fill = baseFill.withValues(alpha: 0.5);
    } else if (widget.hasError) {
      borderColor = error.withValues(alpha: 0.85);
      fill = error.withValues(alpha: 0.06);
    } else if (_hover) {
      borderColor = primary.withValues(alpha: 0.65);
      fill = primary.withValues(alpha: 0.06);
    }

    final Widget body = widget.showProgress
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.progress > 0 && widget.progress < 1
                        ? widget.progress
                        : null,
                    minHeight: 6,
                    backgroundColor: scheme.surfaceContainerHigh,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(widget.progress * 100).clamp(0, 100).round()}%',
                      style: textTheme.labelMedium?.copyWith(
                        color: secondaryOnZone,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text.rich(
                TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: widget.enabled
                        ? secondaryOnZone
                        : secondaryOnZone.withValues(alpha: 0.55),
                  ),
                  children: [
                    const TextSpan(text: 'Drop files here or '),
                    TextSpan(
                      text: 'click here',
                      style: textTheme.bodyMedium?.copyWith(
                        color: widget.enabled
                            ? primary
                            : primary.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: widget.enabled
                            ? primary
                            : primary.withValues(alpha: 0.4),
                      ),
                      recognizer:
                          widget.enabled ? _linkTap : null,
                    ),
                    const TextSpan(text: ' to upload'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(color: fill),
                ),
                CustomPaint(
                  painter: _DashedRoundedRectPainter(
                    color: borderColor,
                    strokeWidth: 1.5,
                    radius: 8,
                    dashLength: 6,
                    gapLength: 4,
                  ),
                  child: SizedBox(
                    key: DsAutomationKeys.part(
                      widget.automationId,
                      DsAutomationKeys.elementFileUploaderDropZone,
                    ),
                    width: double.infinity,
                    height: math.max(widget.minHeight, 100),
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  _DashedRoundedRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final Path outline = Path()..addRRect(rrect);
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final PathMetric metric in outline.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}

class _NorthstarFileUploadRow extends StatelessWidget {
  const _NorthstarFileUploadRow({
    required this.item,
    required this.enabled,
    this.onRemove,
    this.automationId,
  });

  final String? automationId;
  final NorthstarFileUploadItem item;
  final bool enabled;
  final void Function(String id)? onRemove;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isError = item.status == NorthstarFileUploadStatus.error;
    final Color rowSecondary = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.78),
      scheme.surfaceContainerLow,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: isError
                ? Border.all(color: scheme.error.withValues(alpha: 0.85))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              key: DsAutomationKeys.part(
                automationId,
                '${DsAutomationKeys.elementFileUploaderRow}_${item.id}',
              ),
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 22,
                  color: rowSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: item.status == NorthstarFileUploadStatus.uploading
                      ? Text(
                          'Uploading file…',
                          style: textTheme.bodyMedium?.copyWith(
                            color: rowSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Tooltip(
                          message: item.name,
                          child: Text(
                            item.name,
                            style: textTheme.bodyMedium?.copyWith(
                              color: rowSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                _trailing(context),
              ],
            ),
          ),
        ),
        if (isError &&
            item.errorMessage != null &&
            item.errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            item.errorMessage!,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
          ),
        ],
      ],
    );
  }

  Widget _trailing(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    switch (item.status) {
      case NorthstarFileUploadStatus.uploading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
            if (enabled && onRemove != null) ...[
              const SizedBox(width: 4),
              IconButton(
                key: DsAutomationKeys.part(
                  automationId,
                  '${DsAutomationKeys.elementFileUploaderRemove}_${item.id}',
                ),
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => onRemove!(item.id),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ],
        );
      case NorthstarFileUploadStatus.success:
        return Icon(
          Icons.check_circle,
          color: NorthstarColorTokens.of(context).success,
          size: 24,
        );
      case NorthstarFileUploadStatus.uploaded:
        return IconButton(
          key: DsAutomationKeys.part(
            automationId,
            '${DsAutomationKeys.elementFileUploaderRemove}_${item.id}',
          ),
          icon: const Icon(Icons.close, size: 20),
          onPressed: enabled && onRemove != null ? () => onRemove!(item.id) : null,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        );
      case NorthstarFileUploadStatus.error:
        return Icon(
          Icons.error_outline,
          color: scheme.error,
          size: 22,
        );
    }
  }
}
