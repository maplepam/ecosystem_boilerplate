import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Gradient “product strip” at the top of the wide shell rail when labels are
/// visible; collapses to a single icon + [tooltip] when the rail is narrow.
class ShellNavRailBranding extends StatelessWidget {
  const ShellNavRailBranding({
    super.key,
    required this.showExpandedChrome,
    required this.tokens,
    required this.title,
    required this.subtitle,
    this.tooltip,
    this.collapsedIcon = Icons.auto_awesome_rounded,
  });

  final bool showExpandedChrome;
  final NorthstarColorTokens tokens;
  final String title;
  final String subtitle;
  final String? tooltip;
  final IconData collapsedIcon;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String tip = tooltip ?? title;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        showExpandedChrome ? 20 : 10,
        showExpandedChrome ? 28 : 12,
        showExpandedChrome ? 20 : 10,
        showExpandedChrome ? 20 : 12,
      ),
      child: showExpandedChrome
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    tokens.primaryContainer,
                    tokens.surfaceContainerHigh,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: tokens.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: tokens.onPrimaryContainer.withValues(alpha: 0.85),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Tooltip(
                message: tip,
                child: Icon(
                  collapsedIcon,
                  color: tokens.primary,
                  size: 28,
                ),
              ),
            ),
    );
  }
}
