import 'package:emp_ai_ds_northstar/emp_ai_ds_northstar.dart';
import 'package:flutter/material.dart';

/// Second emapta-shaped area: knowledge / quick links (policies, help, learning).
/// Replace tiles with deep links or in-app routes wired to your CMS.
class ResourcesHomeScreen extends StatelessWidget {
  const ResourcesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Quick links',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: NorthstarSpacing.space8),
          Text(
            'Pattern copied from products like emapta: a dedicated module for '
            'HR policies, training, and support — not mixed into the home dashboard.',
            style: textTheme.bodyMedium?.copyWith(
              color: NorthstarColorTokens.of(context).onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: NorthstarSpacing.space24),
          _ResourceTile(
            icon: Icons.menu_book_outlined,
            title: 'Policies & handbook',
            subtitle: 'Wire to your document store or web view.',
            onTap: () {},
          ),
          _ResourceTile(
            icon: Icons.school_outlined,
            title: 'Learning',
            subtitle: 'LMS deep links or in-app course list.',
            onTap: () {},
          ),
          _ResourceTile(
            icon: Icons.support_agent_outlined,
            title: 'Support',
            subtitle: 'Chat, ticket portal, or mailto.',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NorthstarSpacing.space12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
