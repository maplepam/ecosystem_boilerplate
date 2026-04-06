import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

import '../testing/ds_automation_keys.dart';

/// Visual treatment for [NorthstarAccordion] (Figma **panel** vs **divider**).
enum NorthstarAccordionStyle {
  /// Standalone surface blocks; leave **≥8** logical px between stacked items.
  panel,

  /// Flat rows; place a [NorthstarDivider] between items so rules do not double up.
  divider,
}

/// Expandable section: heading row + body (Northstar V3 **Accordion**).
///
/// Defaults **collapsed**; chevron **down** collapsed / **up** expanded; entire header
/// is tappable. Titles **wrap** (no low line cap — avoid ellipsis unless unavoidable).
class NorthstarAccordion extends StatefulWidget {
  const NorthstarAccordion({
    super.key,
    required this.title,
    required this.child,
    this.style = NorthstarAccordionStyle.panel,
    this.initiallyExpanded = false,
    this.enabled = true,
    this.onExpansionChanged,
    this.automationId,
  });

  final String title;

  final Widget child;

  final NorthstarAccordionStyle style;

  final bool initiallyExpanded;

  final bool enabled;

  final ValueChanged<bool>? onExpansionChanged;

  final String? automationId;

  @override
  State<NorthstarAccordion> createState() => _NorthstarAccordionState();
}

class _NorthstarAccordionState extends State<NorthstarAccordion> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant NorthstarAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _expanded = widget.initiallyExpanded;
    }
    if (!widget.enabled && _expanded) {
      setState(() => _expanded = false);
    }
  }

  void _toggle() {
    if (!widget.enabled) {
      return;
    }
    setState(() => _expanded = !_expanded);
    widget.onExpansionChanged?.call(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final NorthstarColorTokens? ns =
        theme.extension<NorthstarColorTokens>();
    final Color headerHoverColor =
        (ns?.primaryContainer ?? theme.colorScheme.primaryContainer).withValues(
      alpha: 0.35,
    );

    final Widget header = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.enabled ? _toggle : null,
        mouseCursor:
            widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        hoverColor: widget.enabled ? headerHoverColor : null,
        highlightColor: widget.enabled ? headerHoverColor.withValues(alpha: 0.5) : null,
        splashColor: widget.enabled ? headerHoverColor.withValues(alpha: 0.6) : null,
        borderRadius: _headerInkBorderRadius(theme),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NorthstarSpacing.space16,
            vertical: NorthstarSpacing.space12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: widget.enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                ),
              ),
              const SizedBox(width: NorthstarSpacing.space8),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  Icons.expand_more,
                  key: DsAutomationKeys.part(
                    widget.automationId,
                    DsAutomationKeys.elementAccordionChevron,
                  ),
                  color: widget.enabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final Widget body = AnimatedCrossFade(
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      sizeCurve: Curves.easeInOut,
      duration: const Duration(milliseconds: 220),
      crossFadeState:
          _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: NorthstarSpacing.space16,
            end: NorthstarSpacing.space16,
            bottom: NorthstarSpacing.space16,
          ),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodyMedium,
            child: widget.child,
          ),
        ),
      ),
      secondChild: const SizedBox(width: double.infinity),
    );

    final Widget column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        header,
        body,
      ],
    );

    final Widget decorated = switch (widget.style) {
      NorthstarAccordionStyle.panel => DecoratedBox(
          decoration: BoxDecoration(
            color: ns?.surfaceContainerLow ?? theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ns?.outlineVariant ?? theme.colorScheme.outlineVariant,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: column,
          ),
        ),
      NorthstarAccordionStyle.divider => column,
    };

    Widget result = Opacity(
      opacity: widget.enabled ? 1 : 0.62,
      child: decorated,
    );
    final ValueKey<String>? rootKey = DsAutomationKeys.part(
      widget.automationId,
      DsAutomationKeys.elementAccordion,
    );
    if (rootKey != null) {
      result = KeyedSubtree(key: rootKey, child: result);
    }
    return result;
  }

  BorderRadius? _headerInkBorderRadius(ThemeData theme) {
    return switch (widget.style) {
      NorthstarAccordionStyle.panel => const BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      NorthstarAccordionStyle.divider => BorderRadius.zero,
    };
  }
}
