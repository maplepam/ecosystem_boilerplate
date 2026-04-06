import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Searchable list of [NorthstarTextRole] values from `emp_ai_ds_northstar`
/// (Figma V3 text scale → [ThemeData.textTheme]).
class NorthstarTypographyCatalogPanel extends StatefulWidget {
  const NorthstarTypographyCatalogPanel({super.key});

  @override
  State<NorthstarTypographyCatalogPanel> createState() =>
      _NorthstarTypographyCatalogPanelState();
}

class _NorthstarTypographyCatalogPanelState
    extends State<NorthstarTypographyCatalogPanel> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Keywords for search (role name + Figma / font hints).
  static String _searchBlob(NorthstarTextRole r) {
    return switch (r) {
      NorthstarTextRole.hero =>
        'hero lexend deca 40 lexendHero displayLarge',
      NorthstarTextRole.title =>
        'title lexend deca 24 lexendTitle displayMedium',
      NorthstarTextRole.pageTitle =>
        'pageTitle lexend deca 18 28 lexendPageTitle displaySmall',
      NorthstarTextRole.interPageTitle =>
        'inter page title 18 28 pageTitles headlineLarge',
      NorthstarTextRole.subTitle =>
        'subtitle subTitles inter 16 24 headlineMedium',
      NorthstarTextRole.subheadingRegular =>
        'subheading regular 15 24 w400 headlineSmall',
      NorthstarTextRole.subheadingSemiBold =>
        'subheading semibold 15 24 w600 titleLarge',
      NorthstarTextRole.subheadingBold =>
        'subheading bold 15 24 w700 titleMedium',
      NorthstarTextRole.label =>
        'label labelRegular 14 16 labelLarge',
      NorthstarTextRole.pageDescription =>
        'page description content black 14 24 bodyLarge',
      NorthstarTextRole.headingSubtitle =>
        'heading subtitle section 16 24 headlineMedium',
      NorthstarTextRole.bodyLarge =>
        'body large 14 24 bodyLarge',
      NorthstarTextRole.body =>
        'body standard content gray 12 16 bodyMedium',
      NorthstarTextRole.bodySmall =>
        'body small ids 10 16 bodySmall',
      NorthstarTextRole.smallHeading =>
        'small heading compact 14 16 w600 titleSmall',
    };
  }

  static List<NorthstarTextRole> _filtered(String q) {
    final String needle = q.trim().toLowerCase();
    if (needle.isEmpty) {
      return NorthstarTextRole.values.toList(growable: false);
    }
    return NorthstarTextRole.values
        .where(
          (NorthstarTextRole r) =>
              r.name.toLowerCase().contains(needle) ||
              _searchBlob(r).toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  static String _sampleCode(NorthstarTextRole r) {
    return "Text(\n"
        "  'Sample',\n"
        "  style: NorthstarTextRole.${r.name}.style(context),\n"
        ')';
  }

  void _showSample(BuildContext context, NorthstarTextRole r) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                r.name,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: NorthstarSpacing.space8),
              Text(
                _searchBlob(r),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: NorthstarSpacing.space16),
              Text(
                'Preview',
                style: Theme.of(ctx).textTheme.labelLarge,
              ),
              const SizedBox(height: NorthstarSpacing.space8),
              Text(
                'The quick brown fox jumps over the lazy dog. 0123456789',
                style: r.style(ctx),
              ),
              const SizedBox(height: NorthstarSpacing.space16),
              Text(
                'Code',
                style: Theme.of(ctx).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              SelectableText(
                _sampleCode(r),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
              const SizedBox(height: NorthstarSpacing.space12),
              FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _sampleCode(r)),
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied sample')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy sample'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String q = _controller.text;
    final List<NorthstarTextRole> matches = _filtered(q);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Search by role name, Figma token, or font…',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Text(
          '${matches.length} role${matches.length == 1 ? '' : 's'} · '
          'NorthstarTextRole + Theme.textTheme (emp_ai_ds_northstar)',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: NorthstarSpacing.space8),
        Expanded(
          child: ListView.separated(
            itemCount: matches.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int i) {
              final NorthstarTextRole r = matches[i];
              return ListTile(
                title: Text(
                  r.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: Text(
                  _searchBlob(r),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onTap: () => _showSample(context, r),
              );
            },
          ),
        ),
      ],
    );
  }
}
