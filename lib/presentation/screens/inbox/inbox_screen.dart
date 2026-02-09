import 'package:flutter/material.dart';
import 'package:fidelux/l10n/generated/app_localizations.dart';

/// Placeholder screen for the Inbox tab.
class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = L.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabInbox)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.placeholderScreenTitle(l10n.tabInbox),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
