import '../../tokens/northstar_spacing.dart';
import '../../tokens/northstar_text_role.dart';
import 'package:flutter/material.dart';

/// Organism: page title + optional description (design-system chrome).
class NorthstarPageHeader extends StatelessWidget {
  const NorthstarPageHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NorthstarSpacing.space16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: NorthstarTextRole.pageTitle.style(context),
                ),
                if (description != null) ...[
                  const SizedBox(height: NorthstarSpacing.space4),
                  Text(
                    description!,
                    style: NorthstarTextRole.pageDescription.style(context)
                        .copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
